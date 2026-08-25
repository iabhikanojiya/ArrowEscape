// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../game/engine/puzzle_engine.dart';
import '../../game/widgets/puzzle_board.dart';
import '../../models/level.dart';
import '../../models/puzzle_path.dart';
import '../../models/reward_purpose.dart';
import '../../repositories/generated_level_repository.dart';
import '../../services/admob_service.dart';
import '../../services/audio/audio_service.dart';
import '../../services/economy/economy_service.dart';
import '../../services/haptics/haptic_service.dart';
import '../../services/hints/hint_service.dart';
import '../../services/storage/storage_service.dart';
import '../../services/analytics_service.dart';
import '../../widgets/ad_unavailable_dialog.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/insufficient_coins_dialog.dart';
import '../../widgets/lives_display.dart';
import '../../widgets/out_of_lives_dialog.dart';
import '../../widgets/reward_animation.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;
  final Level? level;

  const GameScreen({super.key, required this.levelNumber, this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  PuzzleEngine? _engine;
  Level? _level;

  PuzzleEngine get _game => _engine!;
  bool _loading = true;

  int _restartToken = 0;
  String? _hintPathId;
  Timer? _hintTimer;
  bool _isShowingCompletion = false;
  bool _isShowingOutOfLives = false;
  Timer? _outOfLivesTimer;
  int _lives = 3;
  bool _completionRewardGranted = false;
  int _lastRewardCoins = 0;
  bool _lastWasFirstCompletion = true;
  bool _isHintRewardLoading = false;
  bool _isHintProcessing = false;
  bool _isLifeRewardLoading = false;
  DateTime? _levelStartTime;

  final HintService _hintService = createHintService();
  final GeneratedLevelRepository _levelRepository = GeneratedLevelRepository();

  @override
  void initState() {
    super.initState();
    if (widget.level != null) {
      _level = widget.level;
      _engine = PuzzleEngine(boardSize: _level!.gridSize)..loadLevel(_level!);
      _loading = false;
      _lives = 3;
      _levelStartTime = DateTime.now();
      AnalyticsService.logLevelStarted(widget.levelNumber);
      AnalyticsService.setCrashlyticsContext(
        level: widget.levelNumber,
        lives: _lives,
      );
      AnalyticsService.logCrashlytics(
        'level_started level=${widget.levelNumber}',
      );
    } else {
      _loadLevel();
    }
    EconomyProvider.instance.init();
  }

  Future<void> _loadLevel() async {
    final level =
        _levelRepository.getLevelSync(widget.levelNumber) ??
        _levelRepository.getLevelSync(1)!;
    if (!mounted) return;
    setState(() {
      _level = level;
      _engine = PuzzleEngine(boardSize: level.gridSize)..loadLevel(level);
      _loading = false;
      _lives = 3;
      _completionRewardGranted = false;
      _isShowingCompletion = false;
      _isShowingOutOfLives = false;
      _levelStartTime = DateTime.now();
    });
    AnalyticsService.logLevelStarted(widget.levelNumber);
    final coins = await _economy.getCoins().catchError((_) => 0);
    AnalyticsService.setCrashlyticsContext(
      level: widget.levelNumber,
      lives: 3,
      coins: coins,
    );
    AnalyticsService.logCrashlytics(
      'level_started level=${widget.levelNumber}',
    );
  }

  void _clearHint({bool notify = true}) {
    _hintTimer?.cancel();
    _hintTimer = null;
    if (_hintPathId == null) return;
    _hintPathId = null;
    if (notify && mounted) setState(() {});
  }

  void _onBoardTap(PuzzlePath path) {
    _clearHint();
  }

  void _onBlockedTap(PuzzlePath path) {
    if (_isShowingOutOfLives || _isShowingCompletion || _isLifeRewardLoading)
      return;
    if (_engine == null) return;
    if (_game.isLevelComplete) return;
    if (_lives <= 0) {
      if (!_isShowingOutOfLives) {
        _outOfLivesTimer?.cancel();
        _outOfLivesTimer = Timer(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          if (_isShowingOutOfLives || _isShowingCompletion) return;
          if (_game.isLevelComplete) return;
          if (_lives != 0) {
            return;
          }
          _showOutOfLivesDialog();
        });
      }
      return;
    }
    setState(() {
      _lives--;
    });
    AnalyticsService.logArrowBlocked(widget.levelNumber);
    AnalyticsService.logLifeLost(widget.levelNumber);
    AnalyticsService.setCrashlyticsContext(
      level: widget.levelNumber,
      lives: _lives,
    );
    AnalyticsService.logCrashlytics(
      'arrow_blocked level=${widget.levelNumber} life_lost lives=$_lives',
    );
    if (_lives <= 0) {
      _lives = 0;
      AnalyticsService.logOutOfLives(widget.levelNumber);
      _outOfLivesTimer?.cancel();
      _outOfLivesTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (_isShowingOutOfLives || _isShowingCompletion) return;
        if (_game.isLevelComplete) return;
        if (_lives != 0) return;
        _showOutOfLivesDialog();
      });
    }
  }

  void _showOutOfLivesDialog() {
    if (_isShowingOutOfLives) return;
    setState(() => _isShowingOutOfLives = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withValues(alpha: 0.88),
      builder: (context) => OutOfLivesDialog(
        onWatchAd: _handleWatchAdForLife,
        onRestart: _handleRestartFromOutOfLives,
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isShowingOutOfLives = false);
      }
    });
  }

  Future<void> _handleWatchAdForLife() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _isShowingOutOfLives = false;
    _isLifeRewardLoading = true;
    if (mounted) setState(() {});
    AnalyticsService.logRewardedAdStarted('extra_life', widget.levelNumber);
    AnalyticsService.logCrashlytics(
      'rewarded_ad_started placement=extra_life level=${widget.levelNumber}',
    );
    final earned = await AdmobService.instance.showRewarded(
      purpose: RewardPurpose.extraLife,
    );
    _isLifeRewardLoading = false;
    if (!mounted) return;
    if (mounted) setState(() {});
    if (earned) {
      AnalyticsService.logRewardedAdCompleted('extra_life', widget.levelNumber);
      AnalyticsService.logExtraLifeEarned(widget.levelNumber, 1);
      AnalyticsService.setCrashlyticsContext(
        level: widget.levelNumber,
        lives: (_lives + 1).clamp(0, 3),
      );
      AnalyticsService.logCrashlytics(
        'rewarded_ad_completed placement=extra_life level=${widget.levelNumber} extra_life_earned',
      );
      setState(() {
        _lives = (_lives + 1).clamp(0, 3);
      });
      HapticService.success();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You got +1 life!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      AnalyticsService.logRewardedAdFailed('extra_life', 'no_ad_available');
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierColor: Colors.white.withValues(alpha: 0.88),
        builder: (context) => AdUnavailableDialog.forLives(
          onRestart: () {
            Navigator.pop(context);
            _restartLevel(reason: 'out_of_lives');
          },
        ),
      );
    }
  }

  void _handleRestartFromOutOfLives() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _isShowingOutOfLives = false;
    _restartLevel();
  }

  void _onMoveCompleted(bool levelJustCompleted) {
    if (!mounted) return;
    if (!levelJustCompleted) {
      AudioService.instance.play(GameSound.exit);
    }
    setState(() {});
    if (levelJustCompleted) {
      _handleLevelComplete();
    }
  }

  Future<void> _handleLevelComplete() async {
    if (_completionRewardGranted) return;
    _completionRewardGranted = true;
    final durationSeconds = _levelStartTime != null
        ? DateTime.now().difference(_levelStartTime!).inSeconds
        : 0;
    await _saveProgress();

    if (!mounted) return;
    setState(() => _isShowingCompletion = true);

    AnalyticsService.logLevelCompleted(
      widget.levelNumber,
      _game.moveCount,
      durationSeconds,
    );
    AnalyticsService.logCoinsEarned(3, 'level_completion', widget.levelNumber);
    final coinsAfter = await _economy.getCoins().catchError((_) => 0);
    AnalyticsService.setCrashlyticsContext(
      level: widget.levelNumber,
      coins: coinsAfter,
    );
    AnalyticsService.logCrashlytics(
      'level_completed level=${widget.levelNumber} moves=${_game.moveCount} duration=$durationSeconds',
    );

    HapticService.success();
    AudioService.instance.play(GameSound.levelComplete);

    if (mounted && _lastRewardCoins > 0) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) RewardOverlay.show(context, _lastRewardCoins);
      });
    }
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted && _isShowingCompletion) _showCompletionDialog();
    });
  }

  Future<void> _saveProgress() async {
    final storage = createStorageService();
    await storage.init();
    await _economy.init();

    final completedBefore = await storage.getCompletedLevels();
    final wasAlreadyCompleted = completedBefore.contains(widget.levelNumber);

    await storage.addCompletedLevel(widget.levelNumber);

    final currentUnlocked = await storage.getUnlockedLevel();
    final nextLevelId = widget.levelNumber + 1;
    if (nextLevelId > currentUnlocked &&
        nextLevelId <= AppConstants.maxLevels) {
      await storage.setUnlockedLevel(nextLevelId);
    }

    await _economy.addCoins(3);
    _lastRewardCoins = 3;
    _lastWasFirstCompletion = !wasAlreadyCompleted;
  }

  EconomyService get _economy => EconomyProvider.instance;

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withValues(alpha: 0.88),
      builder: (context) => _LevelCompleteDialog(
        moveCount: _game.moveCount,
        levelNumber: widget.levelNumber,
        coinsEarned: _lastRewardCoins,
        isFirstCompletion: _lastWasFirstCompletion,
        onNextLevel: _goToNextLevel,
        onReplay: _restartLevel,
        onLevelSelect: _goToLevelSelect,
      ),
    );
  }

  void _goToNextLevel() {
    Navigator.pop(context);
    _isShowingCompletion = false;
    Navigator.pushReplacementNamed(
      context,
      '/game',
      arguments: {'levelNumber': widget.levelNumber + 1},
    );
  }

  void _goToLevelSelect() {
    Navigator.pop(context);
    _isShowingCompletion = false;
    Navigator.pop(context);
  }

  void _restartLevel({String reason = 'manual'}) {
    AnalyticsService.logLevelRestarted(widget.levelNumber, reason);
    AnalyticsService.logCrashlytics(
      'level_restarted level=${widget.levelNumber} reason=$reason',
    );
    AnalyticsService.setCrashlyticsContext(level: widget.levelNumber, lives: 3);
    _levelStartTime = DateTime.now();
    if (_isShowingCompletion) {
      Navigator.pop(context);
      _isShowingCompletion = false;
    }
    if (_isShowingOutOfLives) {
      _isShowingOutOfLives = false;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
    _outOfLivesTimer?.cancel();
    _outOfLivesTimer = null;
    if (_level == null) return;
    HapticService.lightImpact();
    AudioService.instance.play(GameSound.restart);
    setState(() {
      _game.restartLevel(_level!);
      _restartToken++;
      _hintPathId = null;
      _lives = 3;
      _completionRewardGranted = false;
      _isShowingOutOfLives = false;
    });
    _hintTimer?.cancel();
  }

  void _undoMove() {
    if (!_game.canUndo || _isShowingCompletion || _isShowingOutOfLives) return;
    HapticService.lightImpact();
    AudioService.instance.play(GameSound.button);
    _clearHint(notify: false);
    setState(() => _game.undo());
  }

  Future<PuzzlePath?> _findHint() async {
    return await _hintService.getPathHint(_game);
  }

  void _showHintDisplay(PuzzlePath hintPath) {
    // ignore: avoid_print
    if (!mounted) {
      return;
    }
    AudioService.instance.play(GameSound.hint);
    HapticService.selectionClick();
    setState(() {
      _hintPathId = hintPath.id;
    });

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) _clearHint();
    });
  }

  Future<void> _handleHintRewardedFlow() async {
    if (_isHintRewardLoading || _isHintProcessing) return;
    setState(() => _isHintRewardLoading = true);
    debugPrint('[HINT DEBUG] rewarded hint requested');
    AnalyticsService.logRewardedAdStarted('hint', widget.levelNumber);
    AnalyticsService.logCrashlytics(
      'rewarded_ad_started placement=hint level=${widget.levelNumber}',
    );
    // Resolves only after the user returns from the ad.
    final earned = await AdmobService.instance.showRewarded(
      purpose: RewardPurpose.hint,
    );
    debugPrint(
        '[HINT DEBUG] reward callback received | earned = $earned | mounted = $mounted');
    if (!mounted) {
      setState(() => _isHintRewardLoading = false);
      return;
    }
    setState(() => _isHintRewardLoading = false);
    if (earned) {
      debugPrint('[HINT DEBUG] reward confirmed | purpose = hint');
      debugPrint('[HINT DEBUG] current level = ${widget.levelNumber}');
      AnalyticsService.logRewardedAdCompleted('hint', widget.levelNumber);
      AnalyticsService.setCrashlyticsContext(level: widget.levelNumber);
      // Find the hint NOW, against the current puzzle state.
      final hintPath = await _findHint();
      debugPrint('[HINT DEBUG] current hint path = ${hintPath?.id}');
      if (hintPath == null) {
        debugPrint('[HINT DEBUG] no valid hint for current state');
        return;
      }
      if (!mounted) return;
      // Reward = exactly ONE free hint. Coins are NOT touched.
      debugPrint('[HINT DEBUG] displaying hint');
      _showHintDisplay(hintPath);
      debugPrint('[HINT DEBUG] PuzzleBoard rebuild requested');
    } else {
      debugPrint('[HINT DEBUG] ad closed without reward or unavailable');
      AnalyticsService.logRewardedAdFailed('hint', 'no_ad_available');
      if (!mounted) return;
      showDialog(
        context: context,
        barrierColor: Colors.white.withValues(alpha: 0.88),
        builder: (dialogContext) => AdUnavailableDialog.forHint(
          onTryAgain: () {
            Navigator.pop(dialogContext);
            _handleHintRewardedFlow();
          },
          onClose: () => Navigator.pop(dialogContext),
        ),
      );
    }
  }

  Future<void> _showHint() async {
    if (_isHintProcessing || _isHintRewardLoading) {
      return;
    }
    if (_hintPathId != null) {
      return;
    }
    if (_game.isAnimating ||
        _game.isLevelComplete ||
        _isShowingCompletion ||
        _isShowingOutOfLives ||
        !mounted) {
      return;
    }
    _isHintProcessing = true;
    if (mounted) setState(() {});
    try {
      final hintPath = await _findHint();
      if (hintPath == null) {
        _isHintProcessing = false;
        if (mounted) setState(() {});
        return;
      }

      await _economy.init();
      final coins = await _economy.getCoins();
      debugPrint('[HINT DEBUG] coins = $coins');
      if (coins >= 10) {
        debugPrint('[HINT DEBUG] spending 10 coins');
        final spent = await _economy.spendCoins(10);
        if (!spent) {
          _isHintProcessing = false;
          if (mounted) setState(() {});
          return;
        }
        debugPrint('[HINT DEBUG] current hint path = ${hintPath.id}');
        AnalyticsService.logCoinsSpent(10, 'hint', widget.levelNumber);
        AnalyticsService.logHintUsed(widget.levelNumber, 'coins');
        final coinsAfter = await _economy.getCoins().catchError((_) => 0);
        AnalyticsService.setCrashlyticsContext(coins: coinsAfter);
        AnalyticsService.logCrashlytics(
          'hint_used method=coins level=${widget.levelNumber} coins_spent=10 coins=$coinsAfter',
        );
        debugPrint('[HINT DEBUG] displaying hint | PuzzleBoard rebuild requested');
        _showHintDisplay(hintPath);
        _isHintProcessing = false;
        if (mounted) setState(() {});
        return;
      }
      debugPrint('[HINT DEBUG] insufficient coins');

      // Do NOT show the glow yet. The hint is found and displayed only
      // AFTER the rewarded ad confirms the reward.
      _clearHint(notify: false);
      _isHintProcessing = false;
      if (mounted) setState(() {});
      if (!mounted) return;
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierColor: Colors.white.withValues(alpha: 0.88),
        builder: (context) => InsufficientCoinsDialog(
          onWatchAd: () async {
            Navigator.pop(context);
            await _handleHintRewardedFlow();
          },
          onCancel: () => Navigator.pop(context),
        ),
      );
    } catch (_) {
      _isHintProcessing = false;
      if (mounted) setState(() {});
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _outOfLivesTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Center(
                        child: _loading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : PuzzleBoard(
                                engine: _game,
                                restartToken: _restartToken,
                                hintPathId: _hintPathId,
                                onTapPath: _onBoardTap,
                                onBlockedTap: _onBlockedTap,
                                onMoveCompleted: _onMoveCompleted,
                              ),
                      ),
                    ),
                  ),
                  if (!_loading) ...[
                    const SizedBox(height: 2),
                    _buildMovesCaption(),
                  ],
                  _buildBottomControls(),
                  const BannerAdWidget(),
                ],
              ),
              if (_isLifeRewardLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.75),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2),
                          SizedBox(height: 12),
                          Text(
                            'Loading ad...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.subtleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconSize: 18,
                    tooltip: 'Back',
                    onTap: () {
                      HapticService.lightImpact();
                      AudioService.instance.play(GameSound.button);
                      _goBack();
                    },
                  ),
                  const SizedBox(width: 8),
                  _CircleButton(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Restart',
                    onTap: _restartLevel,
                  ),
                ],
              ),
            ),
            Center(
              child: LivesDisplay(lives: _lives)
                  .animate(key: ValueKey(_lives))
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                    duration: 320.ms,
                  ),
            ),
            Align(alignment: Alignment.centerRight, child: _CoinChip()),
          ],
        ),
      ),
    );
  }

  Widget _buildMovesCaption() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text.rich(
        key: ValueKey(_game.moveCount),
        TextSpan(
          text: 'LEVEL ${widget.levelNumber}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: AppTheme.subtleText,
          ),
          children: [
            TextSpan(
              text: '   ·   ',
              style: TextStyle(
                color: AppTheme.dotLavender.withValues(alpha: 0.8),
              ),
            ),
            TextSpan(text: '${_game.moveCount} MOVES'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final canUndo = _game.canUndo && !_isShowingOutOfLives;
    final canHintBase =
        !_game.isAnimating &&
        !_game.isLevelComplete &&
        !_isShowingCompletion &&
        !_isShowingOutOfLives &&
        !_isHintRewardLoading &&
        !_isHintProcessing &&
        _hintPathId == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CircleButton(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            size: 48,
            onTap: canUndo ? _undoMove : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _economy.coinsListenable,
              builder: (context, coins, _) {
                final hasCoins = coins >= 10;
                final canHint = canHintBase;
                if (_isHintRewardLoading) {
                  return _HintPill(
                    enabled: false,
                    onTap: null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.ink.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Loading ad...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.subtleText,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (hasCoins) {
                  return _HintPill(
                    enabled: canHint,
                    onTap: canHint ? _showHint : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 18,
                          color: AppTheme.ink.withValues(
                            alpha: canHint ? 1.0 : 0.28,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Hint',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink.withValues(
                              alpha: canHint ? 1.0 : 0.28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.monetization_on_rounded,
                                size: 12,
                                color: AppTheme.coinGold,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '10',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.ink.withValues(
                                    alpha: canHint ? 1.0 : 0.28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _HintPill(
                  enabled: canHint,
                  onTap: canHint ? _showHint : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 18,
                        color: AppTheme.ink.withValues(
                          alpha: canHint ? 1.0 : 0.28,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Hint',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink.withValues(
                            alpha: canHint ? 1.0 : 0.28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 16,
                        color: AppTheme.accent.withValues(
                          alpha: canHint ? 1.0 : 0.28,
                        ),
                      ),
                      Text(
                        'Watch Ad',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accent.withValues(
                            alpha: canHint ? 1.0 : 0.28,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          _CircleButton(
            icon: Icons.home_outlined,
            tooltip: 'Home',
            size: 48,
            onTap: () {
              HapticService.lightImpact();
              AudioService.instance.play(GameSound.button);
              _goBack();
            },
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const _CircleButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.size = 44,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final button = Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.chipFill,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: iconSize,
              color: AppTheme.ink.withValues(alpha: enabled ? 1.0 : 0.28),
            ),
          ),
        ),
      ),
    );

    return Semantics(button: true, label: tooltip, child: button);
  }
}

class _HintPill extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  const _HintPill({required this.child, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Hint',
      child: Material(
        color: AppTheme.chipFill,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Opacity(opacity: enabled ? 1.0 : 0.6, child: child),
          ),
        ),
      ),
    );
  }
}

class _CoinChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final economy = EconomyProvider.instance;
    return ValueListenableBuilder<int>(
      valueListenable: economy.coinsListenable,
      builder: (context, coins, _) {
        return Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: AppTheme.chipFill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    size: 15,
                    color: AppTheme.coinGold,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
                  ),
                ],
              ),
            )
            .animate(key: ValueKey(coins))
            .scaleXY(
              begin: 0.92,
              end: 1,
              curve: Curves.easeOutBack,
              duration: 260.ms,
            );
      },
    );
  }
}

class _LevelCompleteDialog extends StatelessWidget {
  final int moveCount;
  final int levelNumber;
  final int coinsEarned;
  final bool isFirstCompletion;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onLevelSelect;

  const _LevelCompleteDialog({
    required this.moveCount,
    required this.levelNumber,
    this.coinsEarned = 0,
    this.isFirstCompletion = true,
    required this.onNextLevel,
    required this.onReplay,
    required this.onLevelSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ink.withValues(alpha: 0.10),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 34,
                    color: AppTheme.accent,
                  ),
                )
                .animate(delay: 60.ms)
                .scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                  duration: 480.ms,
                ),
            const SizedBox(height: 18),
            Text(
              'Level Complete!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
                letterSpacing: -0.2,
              ),
            ).animate(delay: 140.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: 6),
            Text(
              '$moveCount moves · level $levelNumber',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.subtleText,
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
            if (coinsEarned > 0) ...[
              const SizedBox(height: 16),
              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.coinGold.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          size: 16,
                          color: AppTheme.coinGold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+$coinsEarned${isFirstCompletion ? '' : ' · replay'}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB47F13),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(delay: 280.ms)
                  .fadeIn()
                  .slideY(begin: 0.25, curve: Curves.easeOut, duration: 320.ms),
            ],
            const SizedBox(height: 26),
            Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: onLevelSelect,
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.subtleText,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: const Text(
                          'Levels',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: onNextLevel,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Next Level',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                )
                .animate(delay: 340.ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: 0.15, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
