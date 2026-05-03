import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_update_service.dart';
import '../widgets/app_update_dialog.dart';

final appUpdateProvider = FutureProvider.autoDispose<AppUpdateInfo?>((ref) async {
  final updateService = AppUpdateService.instance;
  return await updateService.checkForUpdate();
});

class UpdateChecker {
  static Future<void> checkAndPrompt(BuildContext context) async {
    try {
      final updateService = AppUpdateService.instance;
      final updateInfo = await updateService.checkForUpdate();

      if (updateInfo != null && context.mounted) {
        await AppUpdateDialog.show(
          context,
          updateInfo: updateInfo,
          isDismissible: !updateInfo.isRequired,
        );
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static void showShareSheet(
    BuildContext context, {
    required String downloadUrl,
    String? referralCode,
  }) {
    UpdateShareSheet.show(
      context,
      appName: 'RideOn',
      downloadUrl: downloadUrl,
      referralCode: referralCode,
    );
  }
}