import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/services/app_update_service.dart';
import 'package:arrow_escape/widgets/update_ready_dialog.dart';

void main() {
  test('update service is a silent no-op where Play updates are unsupported',
      () async {
    // Tests run in debug mode on the host: start/check/complete must not
    // throw or block.
    AppUpdateService.instance.start(delay: Duration.zero);
    await AppUpdateService.instance.checkForUpdate();
    await AppUpdateService.instance.startFlexibleUpdate();
    await AppUpdateService.instance.completeUpdate();
  });

  testWidgets('update-ready dialog: RESTART and LATER close and call back',
      (tester) async {
    var restarted = 0, later = 0;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => UpdateReadyDialog(
              onRestart: () => restarted++,
              onLater: () => later++,
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Update Downloaded'), findsOneWidget);
    await tester.tap(find.text('LATER'));
    await tester.pumpAndSettle();
    expect(find.text('Update Downloaded'), findsNothing);
    expect(later, 1);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RESTART'));
    await tester.pumpAndSettle();
    expect(restarted, 1);
    expect(find.text('Update Downloaded'), findsNothing);
  });
}
