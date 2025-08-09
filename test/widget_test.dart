// Basic test file for the Handy app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:handy/app.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: HandyApp(),
      ),
    );

    // Wait for the app to finish loading
    await tester.pumpAndSettle();

    // The test passes if no exception is thrown
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
