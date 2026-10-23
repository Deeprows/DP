class Match {
  const Match(
    this.home,
    this.away,
    this.league,
    this.kickoff,
    this.homeScore,
    this.awayScore,
  );

  final String home, away, league;
  final DateTime kickoff;
  final int? homeScore, awayScore;

  bool get finished => homeScore != null && awayScore != null;
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Clearly fictional sample fixtures. No live data is connected.
List<Match> demoMatches(DateTime now) {
  DateTime at(int dayOffset, int hour, int minute) =>
      DateTime(now.year, now.month, now.day + dayOffset, hour, minute);

  return [
    Match('Red Athletic', 'Blue FC', 'Demo League', at(-1, 20, 0), 2, 1),
    Match('Harbor Town', 'Valley Rangers', 'Demo Cup', at(-1, 18, 30), 0, 0),
    Match('North City', 'South United', 'Demo League',
        now.add(const Duration(hours: 3)), null, null),
    Match('Eastgate Wanderers', 'Lakeside FC', 'Demo Cup', at(0, 21, 30),
        null, null),
    Match('Coastal FC', 'Capital Rovers', 'Demo Cup', at(1, 18, 0), null, null),
    Match('Metro United', 'Hillside Town', 'Demo League', at(1, 20, 45), null,
        null),
    Match('Redwood City', 'Stonebridge', 'Demo League', at(2, 19, 0), null,
        null),
    Match('Port Albion', 'Kingsford FC', 'Demo Cup', at(3, 17, 30), null, null),
  ];
}
