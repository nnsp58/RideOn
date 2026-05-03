import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_update_service.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;
  final VoidCallback? onUpdateLater;
  final bool isDismissible;

  const AppUpdateDialog({
    super.key,
    required this.updateInfo,
    this.onUpdateLater,
    this.isDismissible = true,
  });

  static Future<bool?> show(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
    bool isDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => AppUpdateDialog(
        updateInfo: updateInfo,
        isDismissible: isDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.system_update_alt, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Update Available'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version ${updateInfo.version} is available',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (updateInfo.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(
                  updateInfo.releaseNotes,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
          if (updateInfo.isRequired) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This update is required',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!updateInfo.isRequired && isDismissible)
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('skipped_version', updateInfo.version);
              if (context.mounted) {
                Navigator.of(context).pop(false);
              }
              onUpdateLater?.call();
            },
            child: const Text('Remind Later'),
          ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
            await AppUpdateService.instance.downloadAndInstall(updateInfo);
          },
          child: const Text('Download Update'),
        ),
      ],
    );
  }
}

class UpdateShareSheet extends StatelessWidget {
  final String appName;
  final String downloadUrl;
  final String? referralCode;

  const UpdateShareSheet({
    super.key,
    required this.appName,
    required this.downloadUrl,
    this.referralCode,
  });

  static Future<void> show(
    BuildContext context, {
    required String appName,
    required String downloadUrl,
    String? referralCode,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => UpdateShareSheet(
        appName: appName,
        downloadUrl: downloadUrl,
        referralCode: referralCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share App Update',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.link, color: Colors.green),
            title: const Text('Copy Link'),
            onTap: () {
              // Copy to clipboard
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blue),
            title: const Text('Share via Apps'),
            onTap: () {
              AppUpdateService.shareAppUpdate(
                appName: appName,
                downloadUrl: downloadUrl,
                referralCode: referralCode ?? '',
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(4),
              child: const Text('📱'),
            ),
            title: const Text('Share to WhatsApp'),
            onTap: () {
              AppUpdateService.shareViaWhatsApp(
                appName: appName,
                downloadUrl: downloadUrl,
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(4),
              child: const Text('✈️'),
            ),
            title: const Text('Share to Telegram'),
            onTap: () {
              AppUpdateService.shareToSocial(
                platform: 'Telegram',
                appName: appName,
                downloadUrl: downloadUrl,
              );
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}