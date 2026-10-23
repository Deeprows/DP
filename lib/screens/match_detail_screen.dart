import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/fixtures_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.fixture});
  final LiveFixture fixture;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Match details')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28), child: Column(children: [
        Text(fixture.competition.toUpperCase(), style: AppText.label),
        const SizedBox(height: 26),
        Row(children: [
          Expanded(child: _team(fixture.home)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('VS', style: TextStyle(fontSize: 23, color: AppColors.accent, fontWeight: FontWeight.w900))),
          Expanded(child: _team(fixture.away)),
        ]),
        const SizedBox(height: 22),
        Pill(fixture.status.replaceAll('_', ' ').toUpperCase(), color: AppColors.accent),
      ]))),
      const SizedBox(height: 14),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
        _info('Competition', fixture.competition),
        const Divider(height: 28),
        _info('Date', DateFormat('EEE, d MMM yyyy').format(fixture.kickoff)),
        const Divider(height: 28),
        _info('Kickoff', '${DateFormat('HH:mm').format(fixture.kickoff)} · local time'),
        const Divider(height: 28),
        _info('Status', fixture.status.replaceAll('_', ' ')),
      ]))),
      const SizedBox(height: 14),
      const Card(child: Padding(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.auto_awesome, color: AppColors.accent), SizedBox(width: 10), Text('AI match insights', style: AppText.heading)]),
        SizedBox(height: 12),
        Text('Team form, verified statistics, scorelines and prediction probabilities will appear here when the relevant data API is connected. No results are fabricated.', style: AppText.muted),
      ]))),
    ]),
  );

  Widget _team(String name) => Column(children: [
    TeamBadge(name: name, size: 66),
    const SizedBox(height: 12),
    Text(name, textAlign: TextAlign.center, style: AppText.heading),
  ]);

  Widget _info(String label, String value) => Row(children: [
    Text(label, style: AppText.muted),
    const SizedBox(width: 12),
    Expanded(child: Text(value, textAlign: TextAlign.end, style: AppText.heading)),
  ]);
}
