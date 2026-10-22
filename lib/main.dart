import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const FootballApp());

class Match {
  const Match(this.home, this.away, this.league, this.kickoff, this.homeScore, this.awayScore);
  final String home, away, league;
  final DateTime kickoff;
  final int? homeScore, awayScore;
}

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Football AI',
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xffe32936), scaffoldBackgroundColor: const Color(0xff101014)),
    home: const MainScreen(),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selected = 0;
  final matches = [
    Match('North City', 'South United', 'Demo League', DateTime.now().add(const Duration(hours: 3)), null, null),
    Match('Red Athletic', 'Blue FC', 'Demo League', DateTime.now().subtract(const Duration(days: 1)), 2, 1),
    Match('Coastal FC', 'Capital Rovers', 'Demo Cup', DateTime.now().add(const Duration(days: 1)), null, null),
  ];
  @override
  Widget build(BuildContext context) {
    final pages = [
      _fixtures(),
      _analysis(),
      _placeholder('Community', 'Match discussions and predictions will arrive with Firebase integration.'),
      _placeholder('Profile', 'Sign-in, favorite clubs, and notification preferences will arrive with Firebase integration.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('FOOTBALL AI', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [Padding(padding: const EdgeInsets.only(right: 12), child: Center(child: Chip(label: const Text('DEMO DATA'))))]),
      body: SafeArea(child: pages[selected]),
      bottomNavigationBar: NavigationBar(selectedIndex: selected, onDestinationSelected: (v) => setState(() => selected = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'Matches'),
          NavigationDestination(icon: Icon(Icons.auto_graph), label: 'Analyzer'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Community'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ]),
    );
  }
  Widget _fixtures() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Fixtures & Scores', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Sample matches only — live sports API is not connected.', style: TextStyle(color: Colors.orangeAccent)),
    const SizedBox(height: 18),
    ...matches.map((m) => Card(child: ListTile(
      title: Text('${m.home}  vs  ${m.away}', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${m.league} • ${DateFormat('EEE, d MMM • HH:mm').format(m.kickoff)} (device time)'),
      trailing: Text(m.homeScore == null ? 'UPCOMING' : '${m.homeScore} - ${m.awayScore}'),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchScreen(match: m))),
    ))),
  ]);
  Widget _analysis() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('AI Match Analyzer', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    const Text('Choose a sample match. Live statistics and AI predictions require backend integration.'),
    const SizedBox(height: 20),
    ...matches.where((m) => m.homeScore == null).map((m) => Card(child: ListTile(
      leading: const Icon(Icons.analytics_outlined),
      title: Text('${m.home} vs ${m.away}'),
      subtitle: const Text('Demo match • Analysis not available'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchScreen(match: m))),
    ))),
  ]);
  Widget _placeholder(String title, String message) => Center(child: Padding(
    padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.construction, size: 50), const SizedBox(height: 14),
      Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10), Text(message, textAlign: TextAlign.center),
    ])));
}

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key, required this.match});
  final Match match;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Match Details')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(match.league, textAlign: TextAlign.center), const SizedBox(height: 25),
      Text('${match.home}  vs  ${match.away}', textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text(DateFormat('EEEE, d MMMM yyyy • HH:mm').format(match.kickoff), textAlign: TextAlign.center),
      const SizedBox(height: 25),
      const Card(child: Padding(padding: EdgeInsets.all(18), child: Column(children: [
        Text('AI ANALYSIS', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text('Not available in demo mode. This screen will show verified statistics, win/draw/loss probabilities, and uncertainty once the backend is connected.'),
      ]))),
    ]),
  );
}
