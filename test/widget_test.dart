import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_analyzer/main.dart';

void main() {
  testWidgets('Analyzer opens without demo content', (tester) async {
    await tester.pumpWidget(const FootballApp());
    expect(find.text('DP FOOTBALL AI'), findsOneWidget);
    expect(find.text('Match Analyzer'), findsOneWidget);
    expect(find.text('Analyze with live data'), findsOneWidget);
    expect(find.text('DEMO'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });
}
