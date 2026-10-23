import 'package:flutter/material.dart';
import '../services/fixture_parser.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});
  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  final controller = TextEditingController();
  FixtureParseResult? result;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void analyze() {
    FocusScope.of(context).unfocus();
    setState(() => result = parseFixtures(controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        const Text('AI Analyzer', style: AppText.title),
        const SizedBox(height: 4),
        const Text(
          'Paste your upcoming fixtures, one match per line.',
          style: AppText.muted,
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Match input'),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  minLines: 4,
                  maxLines: 8,
                  style: AppText.body,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Arsenal vs Chelsea\nReal Madrid vs Barcelona\nInter Milan vs AC Milan',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Supports “vs”, “v”, “versus”, or a spaced dash.',
                  style: AppText.caption,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: analyze,
                  icon: const Icon(Icons.auto_awesome, size: 17),
                  label: const Text('Prepare analysis'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const InfoBanner(
          text: 'Fixture parsing works offline. Live statistics and AI predictions need the secure backend; no predictions are fabricated.',
        ),
        if (r != null) ...[
          const SizedBox(height: 18),
          Text(
            '${r.fixtures.length} fixture${r.fixtures.length == 1 ? '' : 's'} recognized',
            style: AppText.heading,
          ),
          const SizedBox(height: 10),
          if (r.fixtures.isEmpty)
            const Text(
              'No valid fixtures found. Try “Arsenal vs Chelsea”.',
              style: AppText.muted,
            ),
          for (final fixture in r.fixtures) ...[
            _FixtureCard(fixture: fixture),
            const SizedBox(height: 6),
          ],
          if (r.invalidLines.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Could not recognize',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final line in r.invalidLines)
                      Text('• $line', style: AppText.muted),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.fixture});
  final FixturePair fixture;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TeamBadge(name: fixture.home, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fixture.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyStrong.copyWith(fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Pill('Stats pending', color: AppColors.warning),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Prediction unavailable until the fixture, kickoff and team statistics are verified.',
                style: AppText.caption,
              ),
            ],
          ),
        ),
      );
}
