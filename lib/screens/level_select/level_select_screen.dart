import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../services/haptics/haptic_service.dart';
import '../../services/storage/storage_service.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/circle_button.dart';
import '../../widgets/economy_chips.dart';

class _Band {
  final String title;
  final int start;
  final int end;

  const _Band(this.title, this.start, this.end);
}

const List<_Band> _bands = [
  _Band('Easy', 1, 10),
  _Band('Medium', 11, 30),
  _Band('Hard', 31, 60),
  _Band('Expert', 61, 120),
  _Band('Master', 121, 1000),
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
    if (mounted) {
      setState(() {
        _unlockedLevel = unlocked;
        _completedLevels = completed;
        _isLoading = false;
      });
    }
  }

  void _openLevel(int levelId) {
    HapticService.selectionClick();
    Navigator.pushNamed(context, '/game', arguments: {'levelNumber': levelId})
        .then((_) => _loadProgress());
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
                        'Levels',
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
                  : LayoutBuilder(
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
                          itemBuilder: (context, index) => _buildSection(
                            _bands[index],
                            index,
                            columns,
                          ),
                        );
                      },
                    ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(_Band band, int index, int columns) {
    final count = band.end - band.start + 1;
    final done = _completedLevels
        .where((id) => id >= band.start && id <= band.end)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    final isUnlocked = levelId <= _unlockedLevel;
    final isCompleted = _completedLevels.contains(levelId);
    final isCurrent = levelId == _unlockedLevel && !isCompleted;

    final delayMs =
        bandIndex == 0 ? (itemIndex % columns) * 35 + 80 : 0;

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
      int levelId, bool isUnlocked, bool isCompleted, bool isCurrent) {
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
                  ? Text(
                      '$levelId',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: numberColor,
                      ),
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
