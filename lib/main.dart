import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/analyzer_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/community_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FootballApp());
}

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'DP Football AI',
    theme: buildTheme(),
    home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Authentication error: ${snapshot.error}'),
          )));
        }
        return snapshot.data == null ? const AuthScreen() : const MainScreen();
      },
    ),
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
      titleSpacing: 18,
      title: const Row(children: [
        Icon(Icons.auto_graph_rounded, color: AppColors.accent, size: 29),
        SizedBox(width: 10),
        Text('DP FOOTBALL AI', style: AppText.title),
      ]),
      actions: [
        IconButton(
          tooltip: 'Profile',
          onPressed: () => setState(() => selected = 3),
          icon: const Icon(Icons.account_circle_outlined),
        ),
        const SizedBox(width: 6),
      ],
    ),
    body: SafeArea(child: IndexedStack(index: selected, children: const [
      MatchesScreen(), AnalyzerScreen(), CommunityScreen(), ProfileScreen(),
    ])),
    bottomNavigationBar: NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (index) => setState(() => selected = index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.sports_soccer_outlined), selectedIcon: Icon(Icons.sports_soccer), label: 'Matches'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Analyzer'),
        NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Community'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}
