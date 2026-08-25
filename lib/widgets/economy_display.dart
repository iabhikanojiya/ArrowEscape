import 'package:flutter/material.dart';
import '../services/economy/economy_service.dart';
import '../core/constants/app_constants.dart';

class EconomyDisplay extends StatelessWidget {
  final bool compact;
  final bool showHearts;
  final bool showCoins;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onHeartsTap;

  const EconomyDisplay({
    super.key,
    this.compact = false,
    this.showHearts = true,
    this.showCoins = true,
    this.onCoinsTap,
    this.onHeartsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final economy = EconomyProvider.instance;

    return FutureBuilder<void>(
      future: economy.init(),
      builder: (context, snapshot) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHearts) _buildHearts(theme, economy),
            if (showHearts && showCoins) const SizedBox(width: 8),
            if (showCoins) _buildCoins(theme, economy),
          ],
        );
      },
    );
  }

  Widget _buildHearts(ThemeData theme, EconomyService economy) {
    // Use ValueListenableBuilder for reactive updates
    return ValueListenableBuilder<int>(
      valueListenable: economy.heartsListenable,
      builder: (context, hearts, _) {
        return FutureBuilder<int>(
          future: economy.getHearts(),
          builder: (context, snap) {
            final count = snap.data ?? hearts;
            return InkWell(
              onTap: onHeartsTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 12,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: compact ? 16 : 18,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$count/${AppConstants.maxHearts}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCoins(ThemeData theme, EconomyService economy) {
    return ValueListenableBuilder<int>(
      valueListenable: economy.coinsListenable,
      builder: (context, coins, _) {
        return FutureBuilder<int>(
          future: economy.getCoins(),
          builder: (context, snap) {
            final count = snap.data ?? coins;
            return InkWell(
              onTap: onCoinsTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 12,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      size: compact ? 16 : 18,
                      color: const Color(0xFFFFB84D),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$count',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Small heart row for compact display (e.g., in game header)
class HeartsRow extends StatelessWidget {
  final int hearts;
  final int maxHearts;
  final double size;

  const HeartsRow({
    super.key,
    required this.hearts,
    this.maxHearts = 5,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxHearts, (index) {
        final filled = index < hearts;
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 2),
          child: Icon(
            filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: size,
            color: filled ? theme.colorScheme.error : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }
}
