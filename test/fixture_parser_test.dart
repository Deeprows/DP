import 'package:flutter_test/flutter_test.dart';
import 'package:football_analyzer/services/fixture_parser.dart';

void main() {
  test('parses several formats and removes duplicates', () {
    final result = parseFixtures('Arsenal vs Chelsea\nReal Madrid v Barcelona\nInter - Milan\nArsenal vs Chelsea');
    expect(result.fixtures.length, 3);
    expect(result.invalidLines, isEmpty);
  });
  test('reports invalid lines without inventing fixtures', () {
    final result = parseFixtures('Invalid\nArsenal vs Chelsea');
    expect(result.fixtures.length, 1);
    expect(result.invalidLines, ['Invalid']);
  });
}
