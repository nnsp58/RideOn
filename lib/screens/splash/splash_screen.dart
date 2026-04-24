import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../services/app_update_service.dart';
import '../../widgets/app_update_dialog.dart';
import '../../core/constants/supabase_constants.dart';

const String appVersion = '1.0.4';
const int appVersionCode = 4;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    await _showUpdateDialog();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      final session = SupabaseService.currentSession;
      if (session != null) {
        final user = await AuthService.getCurrentUserProfile();
        if (!mounted) return;
        
        if (user == null) {
          await AuthService.signOut();
          if (!mounted) return;
          context.go('/welcome');
        } else if (user.setupComplete) {
          context.go('/home');
        } else {
          context.go('/profile-setup');
        }
      } else {
        context.go('/welcome');
      }
    } catch (e) {
      if (!mounted) return;
      context.go('/welcome');
    }
  }

  Future<void> _showUpdateDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSkippedVersion = prefs.getString('skipped_version');
    final lastCheckTime = prefs.getString('last_update_check');

    final now = DateTime.now();
    final lastCheck = lastCheckTime != null ? DateTime.tryParse(lastCheckTime) : null;
    final shouldCheck = lastCheck == null || now.difference(lastCheck).inHours >= 24;

    if (appVersionCode > 0 && (lastSkippedVersion != appVersion || shouldCheck)) {
      final updateInfo = AppUpdateInfo(
        version: '1.0.$appVersionCode',
        versionCode: appVersionCode,
        downloadUrl: SupabaseConstants.appUpdateBaseUrl,
        releaseNotes: 'Download latest version for new features and bug fixes.',
        isRequired: false,
      );

      if (mounted) {
        await AppUpdateDialog.show(
          context,
          updateInfo: updateInfo,
        );
        await prefs.setString('last_update_check', now.toIso8601String());
      }
    }
  }

  Future<void> _showLocalUpdateDialog(SharedPreferences prefs) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 New Update Available!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RideOn app has been updated!'),
            const SizedBox(height: 12),
            const Text('📱 New features:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• Better ride search'),
            const Text('• Improved chat'),
            const Text('• Bug fixes'),
            const SizedBox(height: 12),
            const Text('💡 Share this update with friends:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    await AppUpdateService.shareAppUpdate(
                      appName: 'RideOn',
                      downloadUrl: SupabaseConstants.appUpdateBaseUrl,
                      referralCode: '',
                    );
                  },
                  tooltip: 'Share',
                ),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () {
                    // Copy link logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied!')),
                    );
                  },
                  tooltip: 'Copy Link',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              prefs.setString('app_version', appVersion);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6200EA), // Single color background for smooth feel during animation
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3700B3), Color(0xFF6200EA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.asset(
                            'assets/images/ride_together_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Text Animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'RideOn',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Saath chalein, saath bachayein',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Loading Indicator (Delayed Fade In)
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3.0,
                    ),
                  ),

                  const SizedBox(height: 48),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Version $appVersion',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

