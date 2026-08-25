import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class LivesDisplay extends StatelessWidget {
  final int lives;
  final int maxLives;

  const LivesDisplay({
    super.key,
    required this.lives,
    this.maxLives = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final filled = index < lives;
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
          child: Icon(
            filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 17,
            color: filled
                ? AppTheme.heartRed
                : AppTheme.dotLavender.withValues(alpha: 0.75),
          ),
        );
      }),
    );
  }
}
