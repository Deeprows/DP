import 'package:flutter/material.dart';
import 'screens/analyzer_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/placeholder_screen.dart';
import 'theme.dart';
import 'widgets/common.dart';

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
        appBar: AppBar(
          titleSpacing: 16,
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DP',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Football AI', style: AppText.title),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: Pill('DEMO', color: AppColors.warning)),
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: selected,
            children: const [
              MatchesScreen(),
              AnalyzerScreen(),
              PlaceholderScreen(
                icon: Icons.groups_outlined,
                title: 'Community',
                text: 'Fan discussions and public predictions arrive after Firebase authentication and moderation are connected.',
              ),
              PlaceholderScreen(
                icon: Icons.person_outline,
                title: 'Profile',
                text: 'Accounts, favorites and saved predictions arrive after Firebase integration.',
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (v) => setState(() => selected = v),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.sports_soccer_outlined),
              selectedIcon: Icon(Icons.sports_soccer),
              label: 'Matches',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'Analyzer',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
}
