import 'package:flutter/material.dart';
import 'screens/analyzer_screen.dart';
import 'screens/fixtures_screen.dart';
import 'theme.dart';

void main() => runApp(const FootballApp());

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'DP Football AI',
    theme: buildTheme(),
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
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(titleSpacing: 16, title: const Row(children: [
      Icon(Icons.insights_rounded, color: AppColors.accent),
      SizedBox(width: 10),
      Text('DP FOOTBALL AI', style: AppText.title),
    ])),
    body: SafeArea(child: IndexedStack(index: selected, children: const [
      AnalyzerScreen(), FixturesScreen(),
    ])),
    bottomNavigationBar: NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (index) => setState(() => selected = index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Analyzer'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Fixtures'),
      ],
    ),
  );
}
