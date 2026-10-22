class FixturePair {
  const FixturePair(this.home, this.away);
  final String home;
  final String away;
  String get label => '$home vs $away';
}

class FixtureParseResult {
  const FixtureParseResult(this.fixtures, this.invalidLines);
  final List<FixturePair> fixtures;
  final List<String> invalidLines;
}

FixtureParseResult parseFixtures(String input) {
  final fixtures = <FixturePair>[];
  final invalid = <String>[];
  final seen = <String>{};
  final separator = RegExp(r'\s+(?:vs\.?|v\.?|versus)\s+|\s+[-–—]\s+', caseSensitive: false);
  for (final raw in input.split(RegExp(r'[\r\n;]+'))) {
    final line = raw.trim().replaceFirst(RegExp(r'^\s*\d+[.)]\s*'), '');
    if (line.isEmpty) continue;
    final match = separator.firstMatch(line);
    if (match == null) { invalid.add(line); continue; }
    final home = line.substring(0, match.start).trim();
    final away = line.substring(match.end).trim();
    if (home.isEmpty || away.isEmpty || home.toLowerCase() == away.toLowerCase()) {
      invalid.add(line);
      continue;
    }
    final key = '${home.toLowerCase()}|${away.toLowerCase()}';
    if (seen.add(key)) fixtures.add(FixturePair(home, away));
  }
  return FixtureParseResult(fixtures, invalid);
}
