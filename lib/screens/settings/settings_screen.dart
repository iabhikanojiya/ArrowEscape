import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../models/reward_purpose.dart';
import '../../services/admob_service.dart';
import '../../services/analytics_service.dart';
import '../../services/audio/audio_service.dart';
import '../../services/economy/economy_service.dart';
import '../../services/haptics/haptic_service.dart';
import '../../services/settings/settings_service.dart';
import '../../services/storage/storage_service.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/circle_button.dart';
import '../../widgets/earn_coins_section.dart';
import '../../widgets/economy_chips.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticsEnabled = true;
  bool _soundEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = createSettingsService();
    await settings.init();
    final haptics = await settings.getHapticsEnabled();
    final sound = await settings.getSoundEnabled();
    if (mounted) {
      setState(() {
        _hapticsEnabled = haptics;
        _soundEnabled = sound;
        _isLoading = false;
      });
      await HapticService.initialize(settings);
      await AudioService.instance.initialize(settings: settings);
    }
  }

  Future<void> _toggleHaptics(bool value) async {
    await HapticService.setEnabled(value);
    setState(() => _hapticsEnabled = value);
    if (value) HapticService.selectionClick();
    if (_soundEnabled) AudioService.instance.play(GameSound.button);
  }

  Future<void> _toggleSound(bool value) async {
    await AudioService.instance.setEnabled(value);
    setState(() => _soundEnabled = value);
    if (value) AudioService.instance.play(GameSound.button);
    if (value && _hapticsEnabled) HapticService.selectionClick();
  }

  Future<void> _resetProgress() async {
    final confirm = await _confirmDialog(
      title: 'Reset progress?',
      message:
          'All completed levels will be cleared and your coins will go back to 10. You will start again from level 1.',
      confirmLabel: 'Reset',
    );
    if (confirm && mounted) {
      final storage = createStorageService();
      final economy = EconomyProvider.instance;
      await storage.init();
      await economy.init();
      await storage.resetProgress();
      await economy.reset();
      if (mounted) {
        HapticService.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          _snackbar('Progress reset · back to level 1'),
        );
        setState(() {});
      }
    }
  }

  SnackBar _snackbar(String message) {
    return SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppTheme.subtleText,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.subtleText,
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)),
                    ),
                    child: Text(confirmLabel,
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
              child: Row(
                children: [
                  CircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconSize: 18,
                    tooltip: 'Back',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                  const CoinChip(),
                ],
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.3, end: 0, curve: Curves.easeOut),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      children: [
                        _sectionLabel('Feedback', 0),
                        _group([
                          _ToggleTile(
                            icon: Icons.volume_up_rounded,
                            title: 'Sound',
                            subtitle: 'Clicks, whooshes and chimes',
                            value: _soundEnabled,
                            onChanged: _toggleSound,
                          ),
                          _divider(),
                          _ToggleTile(
                            icon: Icons.vibration_rounded,
                            title: 'Haptics',
                            subtitle: 'Subtle vibration on actions',
                            value: _hapticsEnabled,
                            onChanged: _toggleHaptics,
                          ),
                        ], 0),
                        const SizedBox(height: 26),
                        _sectionLabel('Help', 1),
                        _group([
                          _ActionTile(
                            icon: Icons.school_outlined,
                            title: 'How to play',
                            subtitle: 'Learn the rules in 30 seconds',
                            danger: false,
                            onTap: () {
                              HapticService.lightImpact();
                              AudioService.instance.play(GameSound.button);
                              Navigator.pushNamed(context, '/how_to_play');
                            },
                          ),
                        ], 1),
                        const SizedBox(height: 26),
                        _sectionLabel('Earn Coins', 2),
                        EarnCoinsSection(
                          onWatchAd: () async {
                            AnalyticsService.logRewardedAdStarted(
                                'earn_coins', null);
                            AnalyticsService.logCrashlytics(
                                'rewarded_ad_started placement=earn_coins');
                            final earned = await AdmobService.instance
                                .showRewarded(purpose: RewardPurpose.coins);
                            if (!mounted) return;
                            if (earned) {
                              AnalyticsService.logRewardedAdCompleted(
                                  'earn_coins', null);
                              final economy = EconomyProvider.instance;
                              await economy.init();
                              await economy.addCoins(3);
                              AnalyticsService.logCoinsEarned(
                                  3, 'rewarded_ad', null);
                              final coins =
                                  await economy.getCoins().catchError((_) => 0);
                              AnalyticsService.setCrashlyticsContext(
                                  coins: coins);
                              AnalyticsService.logCrashlytics(
                                  'rewarded_ad_completed placement=earn_coins coins_earned=3');
                              HapticService.success();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.monetization_on_rounded,
                                          size: 18, color: Color(0xFFFFB84D)),
                                      SizedBox(width: 8),
                                      Text('+3 Coins',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              if (mounted) setState(() {});
                            } else {
                              AnalyticsService.logRewardedAdFailed(
                                  'earn_coins', 'no_ad_available');
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Ad isn\'t available right now. Please try again.'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                        ).animate(delay: (60 * 2).ms).fadeIn(duration: 320.ms).slideY(
                            begin: 0.04, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 26),
                        _sectionLabel('Data', 3),
                        _group([
                          _ActionTile(
                            icon: Icons.restart_alt_rounded,
                            title: 'Reset progress',
                            subtitle: 'Back to level 1 · coins reset to 10',
                            danger: true,
                            onTap: _resetProgress,
                          ),
                        ], 3),
                        const SizedBox(height: 26),
                        _sectionLabel('About', 4),
                        _group([
                          const _InfoTile(
                              label: 'Game', value: 'Arrow Escape'),
                          _divider(),
                          const _InfoTile(label: 'Version', value: '1.0.0'),
                        ], 4),
                        const SizedBox(height: 36),
                        Center(
                          child: Text(
                            'Thanks for playing Arrow Escape',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.subtleText
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        )
                            .animate(delay: 250.ms)
                            .fadeIn(duration: 400.ms),
                      ],
                    ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 9),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: AppTheme.subtleText,
        ),
      ),
    )
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }

  Widget _group(List<Widget> children, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAECF6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    )
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: 320.ms)
        .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
  }

  static Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 66,
      color: const Color(0xFFF1F2F9),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.subtleText,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.accent,
              activeTrackColor: AppTheme.accent.withValues(alpha: 0.28),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFDDE0EE),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.chipFill,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 20, color: AppTheme.ink),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.danger,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.danger : AppTheme.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: danger
                    ? AppTheme.danger.withValues(alpha: 0.09)
                    : AppTheme.chipFill,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.subtleText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 22, color: AppTheme.dotLavender),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.subtleText,
            ),
          ),
        ],
      ),
    );
  }
}
