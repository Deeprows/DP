import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../theme.dart';
import '../widgets/common.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final m = match;
    return Scaffold(
      appBar: AppBar(title: const Text('Match details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
              child: Column(
                children: [
                  SectionLabel(m.league),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _side(m.home)),
                      SizedBox(width: 92, child: _center(m)),
                      Expanded(child: _side(m.away)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  _InfoRow('Competition', m.league),
                  const Divider(),
                  _InfoRow(
                      'Date', DateFormat('EEE, d MMM yyyy').format(m.kickoff)),
                  const Divider(),
                  _InfoRow('Kickoff',
                      '${DateFormat('HH:mm').format(m.kickoff)} · device time'),
                  const Divider(),
                  _InfoRow('Status', m.finished ? 'Full time' : 'Scheduled'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBox(Icons.auto_awesome),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI match insights', style: AppText.heading),
                        SizedBox(height: 4),
                        Text(
                          'Verified team form, goal probabilities and AI explanations will appear here once the live-data backend is connected. Demo matches have no genuine predictions.',
                          style: AppText.muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _side(String name) => Column(
        children: [
          TeamBadge(name: name, size: 44),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyStrong,
          ),
        ],
      );

  Widget _center(Match m) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          children: [
            Text(
              m.finished
                  ? '${m.homeScore} - ${m.awayScore}'
                  : DateFormat('HH:mm').format(m.kickoff),
              style: TextStyle(
                fontSize: m.finished ? 26 : 22,
                fontWeight: FontWeight.w800,
                color: m.finished ? AppColors.text : AppColors.accent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              m.finished ? 'Full time' : DateFormat('d MMM').format(m.kickoff),
              style: AppText.caption,
            ),
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Text(label, style: AppText.muted),
            const Spacer(),
            Text(value, style: AppText.bodyStrong),
          ],
        ),
      );
}
