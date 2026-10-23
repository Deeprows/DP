import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_analyzer/main.dart';

void main() {
  testWidgets('Analyzer opens without demo content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(),
      ),
    );

    expect(find.text('DP FOOTBALL AI'), findsOneWidget);
    expect(find.text('Analyzer'), findsOneWidget);
    expect(find.text('Fixtures'), findsOneWidget);
  });

  testWidgets('Navigation switches to Fixtures', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainScreen(),
      ),
    );

    await tester.tap(find.text('Fixtures'));
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
