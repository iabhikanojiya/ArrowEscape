import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Shown once a flexible Google Play update has finished downloading.
/// Styled like the app's other dialogs (see AdUnavailableDialog).
class UpdateReadyDialog extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onLater;

  const UpdateReadyDialog({
    super.key,
    required this.onRestart,
    required this.onLater,
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
                Icons.system_update_rounded,
                size: 32,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Update Downloaded',
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
              'A new version of Arrow Escape is ready. Restart the app to '
              'finish updating. Your progress is kept.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.subtleText,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  onRestart();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'RESTART',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onLater();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.ink,
                  side: BorderSide(color: AppTheme.ink.withValues(alpha: 0.15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'LATER',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
