import 'package:flutter/material.dart';
import '../services/fixture_parser.dart';
import '../services/prediction_service.dart';
import '../theme.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  final input = TextEditingController();
  FixtureParseResult? parsed;
  final results = <String, Map<String, dynamic>>{};
  final errors = <String, String>{};
  bool busy = false;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> analyze() async {
    if (busy) return;
    FocusScope.of(context).unfocus();
    final next = parseFixtures(input.text);
    setState(() {
      parsed = next;
      results.clear();
      errors.clear();
      busy = next.fixtures.isNotEmpty;
    });
    for (final fixture in next.fixtures) {
      if (!mounted) return;
      try {
        final data = await PredictionService.analyze(fixture);
        if (!mounted) return;
        setState(() => results[fixture.label] = data);
      } catch (error) {
        if (!mounted) return;
        setState(() => errors[fixture.label] = error.toString().replaceFirst('Bad state: ', ''));
      }
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          const Text('AI Match Analyzer', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Analyze upcoming football matches with verified data.', style: AppText.muted),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff3a1b27), AppColors.surface]), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)), child: const Row(children: [Icon(Icons.auto_awesome, size: 30, color: AppColors.accent), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('SMART FOOTBALL INSIGHTS', style: AppText.label), SizedBox(height: 5), Text('Team form • Match analysis • Probabilities', style: AppText.heading), SizedBox(height: 4), Text('Predictions appear only when verified statistics are available.', style: AppText.caption)]))])),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('UPCOMING FIXTURES', style: AppText.label),
                const SizedBox(height: 10),
                TextField(
                  controller: input,
                  minLines: 5,
                  maxLines: 9,
                  enabled: !busy,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter a fixture per line:\nHome Team vs Away Team',
                    border: OutlineInputBorder(),
                    helperText: 'Supported competitions and upcoming matches only',
                    helperMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: busy ? null : analyze,
                  icon: busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.analytics_outlined),
                  label: Text(busy ? 'Checking fixtures…' : 'Analyze with live data'),
                ),
              ]),
            ),
          ),
          if (parsed != null) ...[
            const SizedBox(height: 18),
            Text('${parsed!.fixtures.length} recognized fixture(s)', style: AppText.heading),
            const SizedBox(height: 10),
            if (parsed!.fixtures.isEmpty)
              const Text('Enter matches in the format “Home Team vs Away Team”.', style: AppText.muted),
            for (final fixture in parsed!.fixtures) ...[
              _ResultCard(
                fixture: fixture,
                data: results[fixture.label],
                error: errors[fixture.label],
              ),
              const SizedBox(height: 10),
            ],
            if (parsed!.invalidLines.isNotEmpty)
              Card(child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Unrecognized input', style: AppText.heading),
                  for (final line in parsed!.invalidLines) Text(line, style: AppText.muted),
                ]),
              )),
          ],
          const SizedBox(height: 16),
          const Text('Predictions are estimates based on available past results, not guarantees. Fixtures without verified data are not predicted.', style: AppText.caption),
        ],
      );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.fixture, this.data, this.error});
  final FixturePair fixture;
  final Map<String, dynamic>? data;
  final String? error;

  String pct(dynamic value) => value is num ? '${value.toStringAsFixed(1)}%' : '—';

  @override
  Widget build(BuildContext context) {
    final status = data?['status']?.toString();
    final probabilities = data?['probabilities'];
    final probs = probabilities is Map ? probabilities : <String, dynamic>{};
    final marketsValue = data?['markets'];
    final markets = marketsValue is Map ? marketsValue : <String, dynamic>{};
    final goalsValue = data?['expectedGoals'];
    final goals = goalsValue is Map ? goalsValue : <String, dynamic>{};
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(fixture.label, style: AppText.heading),
        const SizedBox(height: 8),
        if (error != null)
          Text(error!, style: const TextStyle(color: AppColors.warning))
        else if (data == null)
          const Text('Checking verified fixture and statistics…', style: AppText.muted)
        else if (status != 'ready')
          Text(data!['message']?.toString() ?? 'Prediction unavailable (${status ?? 'unknown'}).', style: AppText.muted)
        else ...[
          Text(data!['competition']?.toString() ?? 'Verified fixture', style: AppText.muted),
          const SizedBox(height: 12),
          const Text('MATCH OUTCOME', style: AppText.label),
          const SizedBox(height: 6),
          Wrap(spacing: 16, runSpacing: 8, children: [
            _Metric('Home', pct(probs['home'])),
            _Metric('Draw', pct(probs['draw'])),
            _Metric('Away', pct(probs['away'])),
          ]),
          const SizedBox(height: 12),
          const Text('GOALS & MARKETS', style: AppText.label),
          const SizedBox(height: 6),
          Wrap(spacing: 16, runSpacing: 8, children: [
            _Metric('Over 1.5', pct(markets['over15'])),
            _Metric('Over 2.5', pct(markets['over25'])),
            _Metric('Both score', pct(markets['bttsYes'])),
            _Metric('Expected goals', '${goals['home'] ?? '—'} – ${goals['away'] ?? '—'}'),
          ]),
          const SizedBox(height: 10),
          Text(data!['notice']?.toString() ?? 'Statistical estimates only.', style: AppText.caption),
        ],
      ]),
    ));
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppText.caption),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
    ],
  );
}
