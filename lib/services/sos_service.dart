import '../models/sos_alert_model.dart';
import '../core/constants/supabase_constants.dart';
import 'supabase_service.dart';
import 'notification_service.dart';

class SOSService {
  /// Trigger SOS alert
  static Future<String> triggerSOS({
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
    String? locationName,
    String? emergencyType,
  }) async {
    try {
      final alertData = {
        'user_id': userId,
        'user_name': userName,
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
        'emergency_type': emergencyType ?? 'general',
        'is_active': true,
      };

      final response = await SupabaseService.client
          .from(SupabaseConstants.sosAlertsTable)
          .insert(alertData)
          .select('id')
          .single();

      final alertId = response['id'] as String;

      // Send push notifications to admin users
      await _sendSOSNotifications(
        userName: userName,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        emergencyType: emergencyType ?? 'general',
        alertId: alertId,
      );

      return alertId;
    } catch (e) {
      throw Exception('Failed to trigger SOS: $e');
    }
  }

  /// Cancel SOS alert
  static Future<void> cancelSOS({
    required String alertId,
  }) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.sosAlertsTable)
          .update({
            'is_active': false,
            'resolved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', alertId);
    } catch (e) {
      throw Exception('Failed to cancel SOS: $e');
    }
  }

  /// Resolve SOS alert (admin only)
  static Future<void> resolveSOS({
    required String alertId,
    required String resolvedBy,
  }) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.sosAlertsTable)
          .update({
            'is_active': false,
            'resolved_at': DateTime.now().toIso8601String(),
            'resolved_by': resolvedBy,
          })
          .eq('id', alertId);
    } catch (e) {
      throw Exception('Failed to resolve SOS: $e');
    }
  }

  /// Get active SOS alerts (for admin)
  static Stream<List<SOSAlertModel>> watchActiveAlerts() {
    return SupabaseService.client
        .from(SupabaseConstants.sosAlertsTable)
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => SOSAlertModel.fromJson(json)).toList());
  }

  /// Get user's SOS alerts
  static Future<List<SOSAlertModel>> getUserAlerts({
    required String userId,
  }) async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConstants.sosAlertsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) => SOSAlertModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get user alerts: $e');
    }
  }

  /// Get SOS alert by ID
  static Future<SOSAlertModel?> getAlertById({
    required String alertId,
  }) async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConstants.sosAlertsTable)
          .select()
          .eq('id', alertId)
          .maybeSingle();

      return response != null ? SOSAlertModel.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to get alert: $e');
    }
  }

  /// Send SOS notifications to admin users
  static Future<void> _sendSOSNotifications({
    required String userName,
    required double latitude,
    required double longitude,
    String? locationName,
    required String emergencyType,
    required String alertId,
  }) async {
    try {
      // Get all admin users with FCM tokens
      final admins = await SupabaseService.client
          .from('users')
          .select('id, fcm_token')
          .eq('role', 'admin');

      List<String> playerIds = [];
      for (final admin in admins) {
        if (admin['fcm_token'] != null) {
          playerIds.add(admin['fcm_token']);
        }
      }

      if (playerIds.isNotEmpty) {
        await NotificationService.sendPushNotification(
          playerIds: playerIds,
          title: '🚨 EMERGENCY: SOS Alert!',
          message: '$userName triggered SOS at $locationName ($latitude, $longitude). Type: $emergencyType',
          additionalData: {
            'type': 'sos_alert',
            'user_name': userName,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'location_name': locationName ?? '',
            'emergency_type': emergencyType,
            'alert_id': alertId,
            'screen': 'sos_monitoring',
          },
        );
      }
    } catch (e) {
      print('Error sending SOS notifications: $e');
    }
  }
}
