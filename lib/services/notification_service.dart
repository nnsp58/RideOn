import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../core/constants/supabase_constants.dart';
import 'supabase_service.dart';

class NotificationService {
  /// Initialize OneSignal
  static Future<void> initializeOneSignal() async {
    try {
      // Set OneSignal app ID
      OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID'] ?? "");
      
      // Request notification permission
      await OneSignal.Notifications.requestPermission(true);
      
      // Set up notification handlers
      OneSignal.Notifications.addClickListener((event) {
        _handleNotificationClick(event);
      });
      
      // Set up foreground notification handler
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        event.notification.display();
      });
      
      // Get and save player ID
      final playerId = await OneSignal.User.getOnesignalId();
      if (playerId != null) {
        await registerFCMToken(userId: SupabaseService.client.auth.currentUser?.id ?? "", fcmToken: playerId);
      }
      
      debugPrint('OneSignal initialized successfully');
    } catch (e) {
      debugPrint('Error initializing OneSignal: $e');
    }
  }

  /// Handle notification clicks
  static void _handleNotificationClick(OSNotificationClickEvent event) {
    final data = event.notification.additionalData;
    if (data != null) {
      final type = data['type'] as String?;
      debugPrint('Notification clicked: type=$type');
      
      // Handle navigation based on notification type
      // This would integrate with your navigation service
    }
  }

  /// Send notification to user
  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? rideId,
    String? bookingId,
  }) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.notificationsTable)
          .insert({
            'user_id': userId,
            'title': title,
            'message': message,
            'type': type,
            'ride_id': rideId,
            'booking_id': bookingId,
          });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  /// Get user's notifications
  static Stream<List<Map<String, dynamic>>> getMyNotifications({
    required String userId,
  }) {
    return SupabaseService.client
        .from(SupabaseConstants.notificationsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data);
  }

  /// Mark notification as read
  static Future<void> markAsRead({
    required String notificationId,
  }) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.notificationsTable)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read for user
  static Future<void> markAllAsRead({
    required String userId,
  }) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.notificationsTable)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete notification
  static Future<void> deleteNotification({
    required String notificationId,
    required String userId,
  }) async {
    try {
      await SupabaseService.client
          .from(SupabaseConstants.notificationsTable)
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Get unread count
  static Future<int> getUnreadCount({
    required String userId,
  }) async {
    try {
      final response = await SupabaseService.client
          .from(SupabaseConstants.notificationsTable)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Send push notification via OneSignal
  static Future<void> sendPushNotification({
    required List<String> playerIds,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    if (playerIds.isEmpty) return;
    
    try {
      final appId = dotenv.env['ONESIGNAL_APP_ID'];
      final restApiKey = dotenv.env['ONESIGNAL_REST_API_KEY'];
      
      if (appId == null || restApiKey == null) {
        debugPrint('OneSignal credentials missing in .env');
        return;
      }

      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $restApiKey',
        },
        body: json.encode({
          'app_id': appId,
          'include_player_ids': playerIds,
          'headings': {'en': title},
          'contents': {'en': message},
          'data': additionalData,
        }),
      );
      
      debugPrint('Push notification sent to ${playerIds.length} users');
    } catch (e) {
      debugPrint('Failed to send push notification: $e');
    }
  }

  /// Register FCM token for user
  static Future<void> registerFCMToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      await SupabaseService.client
          .from('users')
          .update({'fcm_token': fcmToken})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to register FCM token: $e');
    }
  }

  /// Helper: Send booking confirmation notification
  static Future<void> sendBookingConfirmation({
    required String passengerId,
    required String driverName,
    required String rideDetails,
  }) async {
    await sendNotification(
      userId: passengerId,
      title: 'Booking Confirmed! 🎉',
      message: 'Your booking with $driverName for $rideDetails has been confirmed.',
      type: 'booking_confirmed',
    );
  }

  /// Helper: Send booking cancellation notification
  static Future<void> sendBookingCancellation({
    required String userId,
    required String reason,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'Booking Cancelled',
      message: 'Your booking has been cancelled. $reason',
      type: 'booking_cancelled',
    );
  }

  /// Helper: Send new message notification
  static Future<void> sendNewMessage({
    required String userId,
    required String senderName,
  }) async {
    await sendNotification(
      userId: userId,
      title: 'New Message',
      message: 'You have a new message from $senderName',
      type: 'new_message',
    );
  }
}
