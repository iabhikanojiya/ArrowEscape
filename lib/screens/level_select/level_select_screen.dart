import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../game/levels/level_world.dart';
import '../../services/achievements/achievement_service.dart';
import '../../services/audio/audio_service.dart';
import '../../services/haptics/haptic_service.dart';
import '../../services/storage/storage_service.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/circle_button.dart';
import '../../widgets/economy_chips.dart';
import 'achievements_view.dart';

class _Band {
  final String title;
  final int start;
  final int end;

  const _Band(this.title, this.start, this.end);
}

const List<_Band> _bands = [
  _Band('Basic Shapes', 1, 10),
  _Band('Patterns', 11, 20),
  _Band('Nature', 21, 35),
  _Band('Animals', 36, 55),
  _Band('Objects', 56, 75),
  _Band('Landmarks', 76, 95),
  _Band('Combination', 96, 200),
  _Band('Advanced Patterns', 201, 400),
  _Band('Expert', 401, 700),
  _Band('Master', 701, 900),
  _Band('Ultimate', 901, 1000),
  _Band('Master Shapes', 1001, 1100),
  _Band('Complex Patterns', 1101, 1200),
  _Band('Nature Combinations', 1201, 1300),
  _Band('Animal Combinations', 1301, 1400),
  _Band('Object Combinations', 1401, 1500),
  _Band('Landmark Combinations', 1501, 1600),
  _Band('Multi-Shape Puzzles', 1601, 1700),
  _Band('Expert Combinations', 1701, 1800),
  _Band('Master Challenges', 1801, 1900),
  _Band('Ultimate Challenges', 1901, 2000),
];

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _unlockedLevel = 1;
  Set<int> _completedLevels = {};
  bool _isLoading = true;
  int _tab = 0;
  bool _achievementsVisited = false;
  List<AchievementStatus> _achievements = const [];
  final Set<String> _claiming = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final storage = createStorageService();
    await storage.init();
    final unlocked = await storage.getUnlockedLevel();
    final completed = await storage.getCompletedLevels();
    final achievements = await _loadAchievements();
    if (mounted) {
      setState(() {
        _unlockedLevel = unlocked;
        _completedLevels = completed;
        _achievements = achievements;
        _isLoading = false;
      });
    }
  }

  Future<List<AchievementStatus>> _loadAchievements() async {
    try {
      return await AchievementService.instance.load();
    } catch (e) {
      debugPrint('[Achievements] load failed: $e');
      return _achievements;
    }
  }

  void _selectTab(int tab) {
    if (tab == _tab) return;
    HapticService.selectionClick();
    setState(() {
      _tab = tab;
      if (tab == 1) _achievementsVisited = true;
    });
  }

  Future<void> _claim(AchievementStatus achievement) async {
    final id = achievement.def.id;
    if (_claiming.contains(id)) return;
    setState(() => _claiming.add(id));
    int? awarded;
    try {
      awarded = await AchievementService.instance.claim(id);
    } catch (e) {
      debugPrint('[Achievements] claim failed: $e');
    }
    final achievements = await _loadAchievements();
    if (!mounted) return;
    setState(() {
      _claiming.remove(id);
      _achievements = achievements;
    });
    if (awarded == null) return;
    HapticService.success();
    AudioService.instance.play(GameSound.levelComplete);
    AchievementToast.show(
      context,
      title: achievement.def.title,
      coins: awarded,
    );
  }

  void _openLevel(int levelId) {
    HapticService.selectionClick();
    Navigator.pushNamed(
      context,
      '/game',
      arguments: {'levelNumber': levelId},
    ).then((_) => _loadProgress());
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
              child:
                  Row(
                        children: [
                          CircleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            iconSize: 18,
                            tooltip: 'Back',
                            onTap: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: Text(
                                  _tab == 0 ? 'Levels' : 'Achievements',
                                  key: ValueKey(_tab),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.ink,
                                  ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
              child: _TabSwitch(
                selected: _tab,
                claimableCount: _achievements
                    .where((a) => a.state == AchievementState.claimable)
                    .length,
                onSelect: _selectTab,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IndexedStack(
                      index: _tab,
                      children: [
                        _buildLevelsTab(),
                        _achievementsVisited
                            ? AchievementsView(
                                achievements: _achievements,
                                claimingIds: _claiming,
                                onClaim: _claim,
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelsTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 620
            ? 7
            : width >= 480
            ? 5
            : 4;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: _bands.length,
          itemBuilder: (context, index) =>
              _buildSection(_bands[index], index, columns),
        );
      },
    );
  }

  Widget _buildSection(_Band band, int index, int columns) {
    final count = band.end - band.start + 1;
    final done = _completedLevels
        .where((id) => id >= band.start && id <= band.end)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child:
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        band.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.chipFill,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          '$done/$count',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.subtleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: count,
                    itemBuilder: (context, i) =>
                        _buildTile(band.start + i, index, i, columns),
                  ),
                ],
              )
              .animate(delay: (40 * index).ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildTile(int levelId, int bandIndex, int itemIndex, int columns) {
    final isUnlocked =
        AppConstants.unlockAllLevels || levelId <= _unlockedLevel;
    final isCompleted = _completedLevels.contains(levelId);
    final isCurrent = levelId == _unlockedLevel && !isCompleted;

    final delayMs = bandIndex == 0 ? (itemIndex % columns) * 35 + 80 : 0;

    final tile = _buildTileContent(levelId, isUnlocked, isCompleted, isCurrent);

    if (delayMs == 0 || !isUnlocked) return tile;
    return tile
        .animate(delay: delayMs.ms)
        .fadeIn(duration: 280.ms)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: 320.ms,
        );
  }

  Widget _buildTileContent(
    int levelId,
    bool isUnlocked,
    bool isCompleted,
    bool isCurrent,
  ) {
    final Color fill;
    final Color numberColor;

    if (isCurrent) {
      fill = AppTheme.accent;
      numberColor = Colors.white;
    } else if (isUnlocked) {
      fill = Colors.white;
      numberColor = AppTheme.ink;
    } else {
      fill = const Color(0xFFF4F5FB);
      numberColor = const Color(0xFFB4BAD6);
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: isUnlocked ? () => _openLevel(levelId) : null,
        child: Stack(
          children: [
            Center(
              child: isUnlocked
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$levelId',
                          style: TextStyle(
                            fontSize: isCurrent ? 15 : 16,
                            fontWeight: FontWeight.w800,
                            color: numberColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            LevelWorlds.shapeFor(levelId),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: isCurrent
                                  ? Colors.white.withValues(alpha: 0.92)
                                  : AppTheme.subtleText.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      Icons.lock_rounded,
                      size: 17,
                      color: numberColor.withValues(alpha: 0.75),
                    ),
            ),
            if (!isUnlocked)
              Positioned(
                left: 0,
                right: 0,
                bottom: 9,
                child: Text(
                  '$levelId',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: numberColor.withValues(alpha: 0.55),
                  ),
                ),
              ),
            if (isCompleted)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.white : AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 10,
                    color: isCurrent ? AppTheme.accent : Colors.white,
                  ),
                ),
              ),
            if (isCurrent)
              Positioned(
                left: 0,
                right: 0,
                bottom: 9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Container(
                      width: 3.5,
                      height: 3.5,
                      margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    ).decorate(isCurrent: isCurrent);
  }
}

extension _TileShadow on Widget {
  Widget decorate({required bool isCurrent}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? AppTheme.accent.withValues(alpha: 0.32)
                : AppTheme.ink.withValues(alpha: 0.06),
            blurRadius: isCurrent ? 14 : 8,
            offset: Offset(0, isCurrent ? 6 : 3),
          ),
        ],
      ),
      child: this,
    );
  }
}

class _TabSwitch extends StatelessWidget {
  final int selected;
  final int claimableCount;
  final ValueChanged<int> onSelect;

  const _TabSwitch({
    required this.selected,
    required this.claimableCount,
    required this.onSelect,
  });

  static const _duration = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTheme.chipFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Sliding indicator behind the labels.
          AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOutBack,
            alignment: selected == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: AnimatedContainer(
                duration: _duration,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: selected == 0
                        ? const [Color(0xFF6A7CF7), AppTheme.accent]
                        : const [Color(0xFF7B5CF0), Color(0xFF5B6FF5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                _segment(context, 0, 'LEVELS', Icons.grid_view_rounded),
                _segment(
                  context,
                  1,
                  'ACHIEVEMENTS',
                  Icons.emoji_events_rounded,
                  badge: claimableCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    int index,
    String label,
    IconData icon, {
    int badge = 0,
  }) {
    final active = index == selected;
    final color = active ? Colors.white : AppTheme.subtleText;
    Widget? badgeWidget;
    if (badge > 0) {
      badgeWidget = Container(
        constraints: const BoxConstraints(minWidth: 20),
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.coinGold,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          '$badge',
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      );
      // Pulses while rewards are waiting on the other tab.
      if (!active && !MediaQuery.disableAnimationsOf(context)) {
        badgeWidget = badgeWidget
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(
              begin: 1,
              end: 1.18,
              duration: 650.ms,
              curve: Curves.easeInOut,
            );
      }
    }

    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelect(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: active ? 1.12 : 1,
                  duration: _duration,
                  curve: Curves.easeOutBack,
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: _duration,
                      style: TextStyle(
                        fontFamily: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: color,
                      ),
                      child: Text(label, maxLines: 1),
                    ),
                  ),
                ),
                if (badgeWidget != null) ...[
                  const SizedBox(width: 6),
                  badgeWidget,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
