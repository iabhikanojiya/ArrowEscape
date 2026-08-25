import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const CircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.size = 44,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
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
              color: AppTheme.ink.withValues(alpha: onTap != null ? 1.0 : 0.28),
            ),
          ),
        ),
      ),
    );
  }
}
