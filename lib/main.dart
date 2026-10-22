import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/fixture_parser.dart';

void main() => runApp(const FootballApp());

const accent = Color(0xffef3346);
const surface = Color(0xff1b1d25);

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
    title: 'DP Football AI',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xff101116),
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark),
      cardTheme: CardThemeData(color: surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
    ),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('DP  FOOTBALL AI', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .5)),
      backgroundColor: const Color(0xff101116),
      actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: Chip(label: Text('DEMO'))))],
    ),
    body: SafeArea(child: IndexedStack(index: selected, children: [
      _fixtures(),
      const AnalyzerScreen(),
      _placeholder('Community', 'Fan discussions and public predictions will be enabled after Firebase authentication and moderation are connected.'),
      _placeholder('Profile', 'Accounts, favorites and saved predictions will be enabled after Firebase integration.'),
    ])),
    bottomNavigationBar: NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (v) => setState(() => selected = v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.sports_soccer_outlined), selectedIcon: Icon(Icons.sports_soccer), label: 'Matches'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Analyzer'),
        NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Community'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ),
  );

  Widget _fixtures() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Fixtures & Scores', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
    const SizedBox(height: 6),
    const Text('Sample fixtures — live scores are not connected.', style: TextStyle(color: Colors.orangeAccent)),
    const SizedBox(height: 20),
    ...matches.map((m) => Card(child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: const CircleAvatar(backgroundColor: Color(0xff343743), child: Icon(Icons.sports_soccer, color: Colors.white)),
      title: Text('${m.home}  vs  ${m.away}', style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Padding(padding: const EdgeInsets.only(top: 7), child: Text('${m.league}\n${DateFormat('EEE, d MMM • HH:mm').format(m.kickoff)} • Device time')),
      isThreeLine: true,
      trailing: Text(m.homeScore == null ? 'SOON' : '${m.homeScore} : ${m.awayScore}', style: const TextStyle(fontWeight: FontWeight.bold, color: accent)),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchScreen(match: m))),
    ))),
  ]);

  Widget _placeholder(String title, String description) => Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.construction_outlined, size: 56, color: accent),
      const SizedBox(height: 14),
      Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(description, textAlign: TextAlign.center),
    ]),
  ));
}

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});
  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  final controller = TextEditingController();
  FixtureParseResult? result;
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  void analyze() {
    FocusScope.of(context).unfocus();
    setState(() => result = parseFixtures(controller.text));
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('AI Analyzer', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
    const SizedBox(height: 6),
    const Text('Paste your upcoming fixtures, one match per line.', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 18),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('MATCH INPUT', style: TextStyle(color: accent, fontWeight: FontWeight.w800, letterSpacing: 1)),
      const SizedBox(height: 12),
      TextField(
        controller: controller,
        minLines: 5, maxLines: 10,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Arsenal vs Chelsea\nReal Madrid vs Barcelona\nInter Milan vs AC Milan', alignLabelWithHint: true),
      ),
      const SizedBox(height: 10),
      const Text('Supports “vs”, “v”, “versus”, or a spaced dash. Separate matches with new lines.', style: TextStyle(fontSize: 12, color: Colors.white60)),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: analyze, icon: const Icon(Icons.auto_awesome), label: const Text('Prepare Match Analysis'),
        style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
      )),
    ]))),
    const SizedBox(height: 12),
    const Card(child: Padding(padding: EdgeInsets.all(14), child: Row(children: [
      Icon(Icons.info_outline, color: Colors.orangeAccent), SizedBox(width: 12),
      Expanded(child: Text('Fixture parsing works offline. Live statistics and AI predictions require the secure backend; no predictions are fabricated.', style: TextStyle(fontSize: 12))),
    ]))),
    if (result != null) ...[
      const SizedBox(height: 18),
      Text('${result!.fixtures.length} fixtures recognized', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      if (result!.fixtures.isEmpty) const Text('No valid fixtures found. Try “Arsenal vs Chelsea”.'),
      ...result!.fixtures.map((fixture) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.sports_soccer, color: accent), const SizedBox(width: 10), Expanded(child: Text(fixture.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))]),
        const SizedBox(height: 12),
        const Wrap(spacing: 8, runSpacing: 8, children: [Chip(label: Text('Fixture identified')), Chip(label: Text('Stats pending'))]),
        const SizedBox(height: 8),
        const Text('Prediction unavailable until the fixture, kickoff and recent team statistics are verified.', style: TextStyle(color: Colors.white70)),
      ])))),
      if (result!.invalidLines.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Could not recognize:', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
        ...result!.invalidLines.map((line) => Text('• $line')),
      ]))),
    ],
  ]);
}

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key, required this.match});
  final Match match;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Match Details')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        Text(match.league, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 20),
        Text('${match.home}  vs  ${match.away}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Text(DateFormat('EEEE, d MMMM yyyy • HH:mm').format(match.kickoff)),
        if (match.homeScore != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text('${match.homeScore} : ${match.awayScore}', style: const TextStyle(fontSize: 30, color: accent, fontWeight: FontWeight.bold))),
      ]))),
      const SizedBox(height: 12),
      const Card(child: Padding(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AI MATCH INSIGHTS', style: TextStyle(fontWeight: FontWeight.bold, color: accent)),
        SizedBox(height: 12),
        Text('Verified team form, goal probabilities and AI explanations will appear here after the live-data backend is connected. Demo matches do not have genuine predictions.'),
      ]))),
    ]),
  );
}
