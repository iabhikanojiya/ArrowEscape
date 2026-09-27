import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../screens/how_to_play/how_to_play_screen.dart' show HowToPlayDemo;

/// Shown once per install, the first time the player taps an arrow that
/// can't escape. Explains the rule; styled like the app's other dialogs.
class BlockedTipDialog extends StatelessWidget {
  const BlockedTipDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
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
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppTheme.chipFill,
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.all(10),
              child: const HowToPlayDemo(variant: HowToPlayDemo.blocked),
            ),
            const SizedBox(height: 18),
            const Text(
              'Blocked!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'An arrow can only leave in the direction its arrowhead '
              'points, and the whole arrow slides out that way. '
              'Another arrow is in its way, so it can\'t move yet, and a '
              'blocked tap costs a heart.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: AppTheme.subtleText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Free the arrows in front first.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
