import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Icon - slides from above first
  late Animation<Offset> _iconSlide;
  late Animation<double> _iconFade;
  late Animation<double> _iconScale;

  // App name - slides from above second
  late Animation<Offset> _nameSlide;
  late Animation<double> _nameFade;

  // Tagline - slides from above third
  late Animation<Offset> _taglineSlide;
  late Animation<double> _taglineFade;

  // Loader at bottom
  late Animation<double> _loaderFade;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.splashDuration,
      vsync: this,
    );

    _iconSlide = Tween<Offset>(
      begin: const Offset(0, -4.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _iconScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutBack),
      ),
    );

    _nameSlide = Tween<Offset>(
      begin: const Offset(0, -8.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.48, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, -10.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.60, curve: Curves.easeOut),
      ),
    );

    _loaderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.92, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    _navigationTimer = Timer(AppConstants.splashDuration, () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Center content - icon + name + tagline (all slide from above)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Icon
                    SlideTransition(
                      position: _iconSlide,
                      child: FadeTransition(
                        opacity: _iconFade,
                        child: ScaleTransition(
                          scale: _iconScale,
                          child: _buildAppIcon(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    SlideTransition(
                      position: _nameSlide,
                      child: FadeTransition(
                        opacity: _nameFade,
                        child: Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            fontSize: 34,
                            height: 1.0,
                            color: isDark ? Colors.white : AppTheme.ink,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          AppConstants.tagline,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppTheme.subtleText,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.15,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading at bottom - only element at bottom
            FadeTransition(
              opacity: _loaderFade,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36, top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accent,
                        ),
                        backgroundColor: AppTheme.accent.withValues(alpha: 0.12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppTheme.subtleText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Image.asset(
        'assets/images/app_icon.png',
        width: 124,
        height: 124,
        fit: BoxFit.cover,
      ),
    );
  }
}
