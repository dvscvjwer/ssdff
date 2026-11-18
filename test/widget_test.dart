import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flixora/theme/app_theme.dart';

void main() {
  testWidgets('Flixora dark theme builds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: const Scaffold(
          body: Center(child: Text('Flixora')),
        ),
      ),
    );
    expect(find.text('Flixora'), findsOneWidget);
  });
}
