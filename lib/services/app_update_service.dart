import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final String version;
  final int versionCode;
  final String downloadUrl;
  final String releaseNotes;
  final bool isRequired;

  AppUpdateInfo({
    required this.version,
    required this.versionCode,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.isRequired,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] ?? '',
      versionCode: json['version_code'] ?? 0,
      downloadUrl: json['download_url'] ?? '',
      releaseNotes: json['release_notes'] ?? '',
      isRequired: json['is_required'] ?? false,
    );
  }
}

class AppUpdateService {
  static const String _updateApiUrl = 'https://your-api.com/api/app-version';

  static AppUpdateService? _instance;
  static AppUpdateService get instance => _instance ??= AppUpdateService._();

  String? _cachedUpdateUrl;
  String? get cachedUpdateUrl => _cachedUpdateUrl;

  AppUpdateService._();

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      // Fetch from Supabase app_configs table
      final response = await Supabase.instance.client
          .from('app_configs')
          .select('value')
          .eq('key', 'latest_version')
          .single();

      if (response != null && response['value'] != null) {
        final updateInfo = AppUpdateInfo.fromJson(response['value']);
        
        if (updateInfo.versionCode > currentVersionCode) {
          _cachedUpdateUrl = updateInfo.downloadUrl;
          return updateInfo;
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    return null;
  }

  Future<AppUpdateInfo?> checkForLocalUpdate(String serverVersion, int serverVersionCode, String downloadUrl, {String releaseNotes = '', bool isRequired = false}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

    if (serverVersionCode > currentVersionCode) {
      return AppUpdateInfo(
        version: serverVersion,
        versionCode: serverVersionCode,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
        isRequired: isRequired,
      );
    }
    return null;
  }

  Future<void> downloadAndInstall(AppUpdateInfo updateInfo) async {
    final uri = Uri.parse(updateInfo.downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> shareAppUpdate({
    required String appName,
    required String downloadUrl,
    required String referralCode,
  }) async {
    final message = '''
🚗 RideOn App Update Available!

New version released with improved features and bug fixes.

Download: $downloadUrl

${referralCode.isNotEmpty ? 'Use my referral code: $referralCode\n' : ''}

Share with your friends and save on rides!
''';

    await Share.share(
      message,
      subject: '$appName Update',
    );
  }

  static Future<void> shareViaWhatsApp({
    required String appName,
    required String downloadUrl,
    String? message,
  }) async {
    final text = message ?? '''
🚗 $appName Update Available!

Download: $downloadUrl
''';

    final uri = Uri.parse(
      'whatsapp://send?text=${Uri.encodeComponent(text)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(text)}',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> shareToSocial({
    required String platform,
    required String appName,
    required String downloadUrl,
  }) async {
    final text = '$appName App Update: $downloadUrl';

    switch (platform.toLowerCase()) {
      case 'whatsapp':
        await shareViaWhatsApp(appName: appName, downloadUrl: downloadUrl);
        break;
      case 'telegram':
        final uri = Uri.parse('tg://msg?text=${Uri.encodeComponent(text)}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
        break;
      default:
        await Share.share(text);
    }
  }
}