import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/screens/settings/settings_screen.dart';

void main() {
  testWidgets('About shows the version from pubspec.yaml', (tester) async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Arrow Escape',
      packageName: 'com.arrow.escape.arrow_escape',
      version: '1.0.2',
      buildNumber: '3',
      buildSignature: '',
    );
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Version'), 200);
    // Rows built by the scroll start delayed entrance animations.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Version'), findsOneWidget);
    // The value comes straight from pubspec.yaml's `version:` line.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final expected = RegExp(r'^version:\s*([^\s#]+)', multiLine: true)
        .firstMatch(pubspec)!
        .group(1)!;
    expect(find.text(expected), findsOneWidget);
    expect(find.text('1.0.0'), findsNothing);
  });
}
