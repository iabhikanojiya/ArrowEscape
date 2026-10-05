import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../services/achievements/achievement_service.dart';

const Color _gold = AppTheme.coinGold;
const Color _goldDeep = Color(0xFFE89B1C);
const Color _lockedFill = Color(0xFFF6F7FC);

/// Per-world accent colours, cycled by world number.
const List<Color> _worldPalette = [
  Color(0xFF5B6FF5),
  Color(0xFF14B8A6),
  Color(0xFF22C55E),
  Color(0xFFF97316),
  Color(0xFFEC4899),
  Color(0xFF8B5CF6),
  Color(0xFF0EA5E9),
];

Color _colorFor(AchievementDef def) {
  if (def.kind == AchievementKind.firstLevel) return _gold;
  final world = int.tryParse(def.id.split('_').last) ?? 1;
  return _worldPalette[(world - 1) % _worldPalette.length];
}

/// Picks an icon from the world title so new worlds still get a fitting one.
IconData _iconFor(AchievementDef def) {
  if (def.kind == AchievementKind.firstLevel) return Icons.flag_rounded;
  final t = def.title.toLowerCase();
  if (t.contains('nature')) return Icons.eco_rounded;
  if (t.contains('animal')) return Icons.pets_rounded;
  if (t.contains('object')) return Icons.lightbulb_rounded;
  if (t.contains('landmark')) return Icons.account_balance_rounded;
  if (t.contains('multi') || t.contains('combination')) {
    return Icons.auto_awesome_mosaic_rounded;
  }
  if (t.contains('pattern')) return Icons.blur_on_rounded;
  if (t.contains('shape')) return Icons.category_rounded;
  if (t.contains('ultimate')) return Icons.diamond_rounded;
  if (t.contains('master')) return Icons.military_tech_rounded;
  if (t.contains('expert')) return Icons.psychology_rounded;
  return Icons.star_rounded;
}

String _levelsLabel(int n) => n == 1 ? '1 level' : '$n levels';

/// Achievements tab of the Level screen. Stateless about storage: the parent
/// loads [achievements] and performs claims through [onClaim].
class AchievementsView extends StatefulWidget {
  final List<AchievementStatus> achievements;
  final Set<String> claimingIds;
  final ValueChanged<AchievementStatus> onClaim;

  const AchievementsView({
    super.key,
    required this.achievements,
    required this.claimingIds,
    required this.onClaim,
  });

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> {
  /// Locked worlds shown before the "show more" toggle.
  static const int _lockedPreview = 3;
  bool _showAllLocked = false;

  @override
  Widget build(BuildContext context) {
    final achievements = widget.achievements;
    final ready = <AchievementStatus>[];
    final inProgress = <AchievementStatus>[];
    final locked = <AchievementStatus>[];
    final done = <AchievementStatus>[];
    for (final a in achievements) {
      switch (a.state) {
        case AchievementState.claimable:
          ready.add(a);
        case AchievementState.claimed:
          done.add(a);
        case AchievementState.locked:
          (a.completedLevels > 0 || a.def.kind == AchievementKind.firstLevel
                  ? inProgress
                  : locked)
              .add(a);
      }
    }

    var order = 0;
    Widget appear(Widget child) => child
        .animate(delay: (35 * (order++).clamp(0, 8)).ms)
        .fadeIn(duration: 320.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);

    Widget card(AchievementStatus a) => appear(
      _AchievementCard(
        key: ValueKey(a.def.id),
        status: a,
        claiming: widget.claimingIds.contains(a.def.id),
        onClaim: () => widget.onClaim(a),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        appear(_HeroCard(achievements: achievements)),
        if (ready.isNotEmpty) ...[
          _SectionHeader(
            label: 'READY TO CLAIM',
            count: ready.length,
            color: _goldDeep,
            icon: Icons.redeem_rounded,
          ),
          for (final a in ready) card(a),
        ],
        if (inProgress.isNotEmpty) ...[
          _SectionHeader(
            label: 'IN PROGRESS',
            count: inProgress.length,
            color: AppTheme.accent,
            icon: Icons.trending_up_rounded,
          ),
          for (final a in inProgress) card(a),
        ],
        if (locked.isNotEmpty) ...[
          _SectionHeader(
            label: 'LOCKED',
            count: locked.length,
            color: AppTheme.subtleText,
            icon: Icons.lock_rounded,
          ),
          for (final a in _showAllLocked ? locked : locked.take(_lockedPreview))
            card(a),
          if (locked.length > _lockedPreview)
            _ShowMoreButton(
              expanded: _showAllLocked,
              hiddenCount: locked.length - _lockedPreview,
              onTap: () => setState(() => _showAllLocked = !_showAllLocked),
            ),
        ],
        if (done.isNotEmpty) ...[
          _SectionHeader(
            label: 'COMPLETED',
            count: done.length,
            color: const Color(0xFF22C55E),
            icon: Icons.verified_rounded,
          ),
          for (final a in done) card(a),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final List<AchievementStatus> achievements;

  const _HeroCard({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final total = achievements.length;
    final earned = achievements
        .where((a) => a.state != AchievementState.locked)
        .length;
    final ready = achievements
        .where((a) => a.state == AchievementState.claimable)
        .toList();
    final coinsWaiting = ready.fold<int>(0, (sum, a) => sum + a.def.reward);
    final progress = total == 0 ? 0.0 : earned / total;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B6FF5), Color(0xFF7B5CF0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -14,
            child: Icon(
              Icons.emoji_events_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4.5,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _gold,
                              ),
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              size: 28,
                              color: _gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$earned',
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / $total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            'Achievements unlocked',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (coinsWaiting > 0)
                  _HeroStat(
                    icon: Icons.monetization_on_rounded,
                    iconColor: _gold,
                    text: '$coinsWaiting coins ready to claim',
                    highlight: true,
                  )
                else
                  _HeroStat(
                    icon: Icons.bolt_rounded,
                    iconColor: Colors.white,
                    text: earned == total
                        ? 'Every achievement collected!'
                        : 'Clear a world to earn +${AchievementService.categoryReward}',
                    highlight: false,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final bool highlight;

  const _HeroStat({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: highlight ? Colors.white : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: highlight ? AppTheme.ink : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 24, 2, 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementStatus status;
  final bool claiming;
  final VoidCallback onClaim;

  const _AchievementCard({
    super.key,
    required this.status,
    required this.claiming,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final def = status.def;
    final state = status.state;
    final color = _colorFor(def);
    final ready = state == AchievementState.claimable;
    final claimed = state == AchievementState.claimed;
    final untouched =
        state == AchievementState.locked &&
        status.completedLevels == 0 &&
        def.kind == AchievementKind.category;
    final progress = def.totalLevels == 0
        ? 0.0
        : status.completedLevels / def.totalLevels;

    final doneText = def.kind == AchievementKind.firstLevel
        ? def.description
        : 'All ${_levelsLabel(def.totalLevels)} cleared';
    final caption = def.kind == AchievementKind.firstLevel
        ? 'Your first win'
        : 'World ${def.id.split('_').last}  ·  ${_levelsLabel(def.totalLevels)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: ready ? 14 : (untouched ? 9 : 12),
        ),
        decoration: BoxDecoration(
          color: untouched ? _lockedFill : Colors.white,
          gradient: ready
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFBEF), Colors.white],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: ready
              ? Border.all(color: _gold.withValues(alpha: 0.75), width: 1.6)
              : null,
          boxShadow: untouched
              ? null
              : [
                  BoxShadow(
                    color: ready
                        ? _gold.withValues(alpha: 0.25)
                        : AppTheme.ink.withValues(alpha: 0.06),
                    blurRadius: ready ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            _Medallion(
              icon: _iconFor(def),
              color: color,
              state: state,
              progress: progress,
              untouched: untouched,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    def.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: untouched
                          ? AppTheme.ink.withValues(alpha: 0.5)
                          : AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    claimed || ready ? doneText : caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.subtleText,
                    ),
                  ),
                  if (state == AchievementState.locked && !untouched) ...[
                    const SizedBox(height: 8),
                    _ProgressLine(
                      done: status.completedLevels,
                      total: def.totalLevels,
                      color: untouched ? AppTheme.dotLavender : color,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (ready)
              _ClaimButton(
                reward: def.reward,
                claiming: claiming,
                onTap: onClaim,
              )
            else if (claimed)
              const _ClaimedTag()
            else
              _RewardChip(reward: def.reward, muted: untouched),
          ],
        ),
      ),
    );
  }
}

class _Medallion extends StatelessWidget {
  final IconData icon;
  final Color color;
  final AchievementState state;
  final double progress;
  final bool untouched;

  const _Medallion({
    required this.icon,
    required this.color,
    required this.state,
    required this.progress,
    required this.untouched,
  });

  @override
  Widget build(BuildContext context) {
    final ready = state == AchievementState.claimable;
    final claimed = state == AchievementState.claimed;
    final locked = state == AchievementState.locked;

    final Color fill = ready || claimed
        ? color
        : untouched
        ? const Color(0xFFEDEFF8)
        : color.withValues(alpha: 0.12);
    final Color iconColor = ready || claimed
        ? Colors.white
        : untouched
        ? AppTheme.dotLavender
        : color;

    Widget medal = SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (locked && !untouched)
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          Container(
            width: locked && !untouched ? 42 : 48,
            height: locked && !untouched ? 42 : 48,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              boxShadow: ready
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: 23, color: iconColor),
          ),
          if (untouched || claimed || ready)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: claimed
                      ? const Color(0xFF22C55E)
                      : ready
                      ? _gold
                      : const Color(0xFFC9CDE3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  claimed
                      ? Icons.check_rounded
                      : ready
                      ? Icons.star_rounded
                      : Icons.lock_rounded,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );

    if (ready && !MediaQuery.disableAnimationsOf(context)) {
      medal = medal
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1,
            end: 1.06,
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }
    return medal;
  }
}

class _ProgressLine extends StatelessWidget {
  final int done;
  final int total;
  final Color color;

  const _ProgressLine({
    required this.done,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 6,
              backgroundColor: const Color(0xFFE9EBF5),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$done / $total',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.subtleText,
          ),
        ),
      ],
    );
  }
}

class _RewardChip extends StatelessWidget {
  final int reward;
  final bool muted;

  const _RewardChip({required this.reward, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFEDEFF8) : const Color(0xFFFFF6E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on_rounded,
            size: 14,
            color: muted ? _gold.withValues(alpha: 0.5) : _gold,
          ),
          const SizedBox(width: 3),
          Text(
            '+$reward',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: muted ? AppTheme.subtleText : AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  final int reward;
  final bool claiming;
  final VoidCallback onTap;

  const _ClaimButton({
    required this.reward,
    required this.claiming,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFC94D), _goldDeep],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _goldDeep.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: claiming ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CLAIM',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+$reward',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (claiming || MediaQuery.disableAnimationsOf(context)) {
      return Opacity(opacity: claiming ? 0.6 : 1, child: button);
    }
    return button
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          delay: 1200.ms,
          duration: 1100.ms,
          color: Colors.white.withValues(alpha: 0.55),
        );
  }
}

class _ClaimedTag extends StatelessWidget {
  const _ClaimedTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 14, color: Color(0xFF16A34A)),
          SizedBox(width: 3),
          Text(
            'CLAIMED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}

/// Short, non-blocking "achievement claimed" toast near the top of the screen.
class AchievementToast {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String title,
    required int coins,
  }) {
    _entry?.remove();
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 64,
        left: 24,
        right: 24,
        child: IgnorePointer(
          child: Center(
            child: _ToastCard(title: title, coins: coins)
                .animate()
                .fadeIn(duration: 220.ms)
                .slideY(begin: -0.4, end: 0, curve: Curves.easeOutBack)
                .then(delay: 1500.ms)
                .fadeOut(duration: 300.ms),
          ),
        ),
      ),
    );
    _entry = entry;
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (_entry == entry) {
        entry.remove();
        _entry = null;
      }
    });
  }
}

class _ToastCard extends StatelessWidget {
  final String title;
  final int coins;

  const _ToastCard({required this.title, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.coinGold.withValues(alpha: 0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ink.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppTheme.coinGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACHIEVEMENT CLAIMED',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: AppTheme.subtleText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '+$coins',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.monetization_on_rounded,
              size: 18,
              color: AppTheme.coinGold,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowMoreButton extends StatelessWidget {
  final bool expanded;
  final int hiddenCount;
  final VoidCallback onTap;

  const _ShowMoreButton({
    required this.expanded,
    required this.hiddenCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.accent,
          backgroundColor: AppTheme.chipFill,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(
          expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
          size: 20,
        ),
        label: Text(
          expanded ? 'Show less' : 'Show $hiddenCount more',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
