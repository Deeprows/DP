import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_analyzer/main.dart';

void main() {
  testWidgets('Football app loads demo matches and navigation', (tester) async {
    await tester.pumpWidget(const FootballApp());

    expect(find.text('Football AI'), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);
    expect(find.byIcon(Icons.sports_soccer), findsWidgets);

    await tester.tap(find.text('Analyzer'));
    await tester.pumpAndSettle();
    expect(find.text('AI Analyzer'), findsOneWidget);
  });
}
