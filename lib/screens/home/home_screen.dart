import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../repositories/generated_level_repository.dart';
import '../../services/audio/audio_service.dart';
import '../../services/haptics/haptic_service.dart';
import '../../services/play_games_service.dart';
import '../../services/storage/storage_service.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/economy_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;
  int _unlockedLevel = 1;
  int _completedLevels = 0;
  final int _totalLevels = AppConstants.maxLevels;
  bool _isLoading = true;
  final GeneratedLevelRepository _repository = GeneratedLevelRepository();

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_logoController.isAnimating && _logoController.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _logoController.forward();
      });
    }
  }

  Future<void> _loadProgress() async {
    await _repository.init();
    final storage = createStorageService();
    await storage.init();
    final unlocked = await storage.getUnlockedLevel();
    final completed = await storage.getCompletedLevelsCount();
    if (mounted) {
      setState(() {
        _unlockedLevel = unlocked;
        _completedLevels = completed;
        _isLoading = false;
      });
    }
  }

  void _navigateToGame() {
    HapticService.lightImpact();
    AudioService.instance.play(GameSound.button);
    Navigator.pushNamed(context, '/game',
        arguments: {'levelNumber': _unlockedLevel});
  }

  void _navigateToLevelSelect() {
    HapticService.lightImpact();
    AudioService.instance.play(GameSound.button);
    Navigator.pushNamed(context, '/level_select')
        .then((_) => _loadProgress());
  }

  void _navigateToSettings() {
    HapticService.lightImpact();
    AudioService.instance.play(GameSound.button);
    Navigator.pushNamed(context, '/settings').then((_) => _loadProgress());
  }

  Future<void> _openLeaderboard() async {
    HapticService.lightImpact();
    AudioService.instance.play(GameSound.button);
    final opened = await PlayGamesService.instance.showLeaderboards();
    if (opened || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Google Play Games isn\'t available right now. Please try again.'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  _SettingsButton(onTap: _navigateToSettings),
                  const Spacer(),
                  const CoinChip(),
                ],
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.4, end: 0, curve: Curves.easeOut),
            ),
            const Spacer(flex: 5),
            _buildHero(),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildContinueButton(),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SoftAction(
                          icon: Icons.grid_view_rounded,
                          label: 'Levels',
                          onTap: _navigateToLevelSelect,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SoftAction(
                          icon: Icons.leaderboard_rounded,
                          label: 'Leaderboard',
                          onTap: _openLeaderboard,
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _buildProgressFooter(),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: BannerAdWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: AnimatedBuilder(
            animation: _logoController,
            builder: (context, _) => CustomPaint(
              painter: _ArrowPathLogo(progress: _logoController.value),
            ),
          ),
        )
            .animate(delay: 100.ms)
            .fadeIn(duration: 300.ms)
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
              duration: 500.ms,
            ),
        const SizedBox(height: 22),
        Text(
          'Arrow Escape',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppTheme.ink,
                letterSpacing: -0.8,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Slide the paths. Clear the board.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.subtleText,
                fontWeight: FontWeight.w500,
              ),
        ),
      ]
          .animate(delay: 150.ms)
          .fadeIn(duration: 450.ms)
          .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 64,
      child: Material(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: _isLoading ? null : _navigateToGame,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Level $_unlockedLevel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 24, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressFooter() {
    final progress =
        _totalLevels > 0 ? (_completedLevels / _totalLevels).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'PROGRESS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppTheme.subtleText,
              ),
            ),
            const Spacer(),
            Text(
              '$_completedLevels / $_totalLevels',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppTheme.chipFill,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
          ),
        ),
      ],
    )
        .animate(delay: 320.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

class _SoftAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SoftAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: AppTheme.chipFill,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: AppTheme.ink),
                const SizedBox(width: 9),
                // Scales down instead of overflowing on narrow screens or
                // large system font sizes.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact Settings control for the top bar, styled like [_SoftAction].
class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Settings',
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          color: AppTheme.chipFill,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: const Icon(Icons.tune_rounded,
                size: 20, color: AppTheme.ink),
          ),
        ),
      ),
    );
  }
}

class _ArrowPathLogo extends CustomPainter {
  final double progress;

  _ArrowPathLogo({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s * 0.105;

    final path = Path()
      ..moveTo(s * 0.16, s * 0.86)
      ..lineTo(s * 0.16, s * 0.30)
      ..lineTo(s * 0.64, s * 0.30)
      ..lineTo(s * 0.64, s * 0.66)
      ..lineTo(s * 0.84, s * 0.66);

    final metric = path.computeMetrics().first;
    final t = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final visible = metric.extractPath(0, metric.length * t);

    final paint = Paint()
      ..color = AppTheme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(visible, paint);

    final headT = ((progress - 0.82) / 0.18).clamp(0.0, 1.0);
    if (headT > 0) {
      final tip = metric.getTangentForOffset(metric.length)!;
      final paintHead = Paint()
        ..color = AppTheme.accent.withValues(alpha: headT)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.save();
      canvas.translate(tip.position.dx, tip.position.dy);
      canvas.rotate(math.atan2(tip.vector.dy, tip.vector.dx));
      final len = stroke * 2.4;
      final half = stroke * 1.25;
      final scale = 0.5 + 0.5 * headT;
      canvas.scale(scale);
      final head = Path()
        ..moveTo(len * 0.55, 0)
        ..lineTo(-len * 0.45, -half)
        ..lineTo(-len * 0.45, half)
        ..close();
      canvas.drawPath(head, paintHead);
      canvas.restore();
    }

    final dotPaint = Paint()
      ..color = AppTheme.dotLavender.withValues(alpha: 0.35 * headT + 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(s * 0.16, s * 0.86), stroke * 0.62, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPathLogo oldDelegate) =>
      oldDelegate.progress != progress;
}
