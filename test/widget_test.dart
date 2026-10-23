import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_analyzer/main.dart';

void main() {
  testWidgets('Main navigation has four sections', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainScreen()));
    expect(find.text('DP FOOTBALL AI'), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('Analyzer'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
  testWidgets('Navigation switches to Analyzer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainScreen()));
    await tester.tap(find.text('Analyzer').last);
    await tester.pump();
    expect(find.text('Match Analyzer'), findsOneWidget);
  });
}
