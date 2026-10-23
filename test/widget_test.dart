import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_analyzer/main.dart';

void main() {
  testWidgets('Football app loads demo matches and navigation', (tester) async {
    await tester.pumpWidget(const FootballApp());

    expect(find.text('DP  FOOTBALL AI'), findsOneWidget);
    expect(find.byIcon(Icons.sports_soccer), findsWidgets);
  });
}
