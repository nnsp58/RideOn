import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Table names
  static const String usersTable = 'users';
  static const String ridesTable = 'rides';
  static const String bookingsTable = 'bookings';
  static const String messagesTable = 'messages';
  static const String chatsTable = 'chats';
  static const String sosAlertsTable = 'sos_alerts';
  static const String roadReportsTable = 'road_reports';
  static const String notificationsTable = 'notifications';

  // Storage buckets
  static const String profilePhotosBucket = 'profile-photos';
  static const String documentsBucket = 'user-documents';
  static const String appUpdatesBucket = 'app-updates';

  // App update URL (GitHub - V1.0.4)
  static const String appUpdateBaseUrl = 'https://github.com/nnsp58/RideOn/releases/download/V1.0.4/RideOn-v1.0.4-Final.apk';
}
