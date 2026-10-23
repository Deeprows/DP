import 'package:flutter/material.dart';
import 'screens/analyzer_screen.dart';
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

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          title: const Row(
            children: [
              Icon(Icons.insights_rounded, color: AppColors.accent),
              SizedBox(width: 10),
              Text('DP FOOTBALL AI', style: AppText.title),
            ],
          ),
        ),
        body: const SafeArea(child: AnalyzerScreen()),
      );
}
