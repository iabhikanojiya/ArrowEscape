import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/economy/economy_service.dart';

class CoinChip extends StatelessWidget {
  const CoinChip({super.key});

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
              const Icon(Icons.monetization_on_rounded,
                  size: 15, color: AppTheme.coinGold),
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
        );
      },
    );
  }
}
