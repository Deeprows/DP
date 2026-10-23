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
  int completed = 0;

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
      completed = 0;
      busy = next.fixtures.isNotEmpty;
    });
    // Sequential requests help avoid bursts against API-Football's quota.
    for (final fixture in next.fixtures) {
      if (!mounted) return;
      try {
        final data = await PredictionService.analyzeWithPrediction(fixture);
        if (!mounted) return;
        setState(() => results[fixture.label] = data);
      } catch (error) {
        if (!mounted) return;
        setState(() => errors[fixture.label] =
            error.toString().replaceFirst('Bad state: ', ''));
      }
      if (mounted) setState(() => completed++);
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          const Text('Match Analyzer',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Verified fixtures and real API-Football statistical predictions.',
            style: AppText.muted,
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('UPCOMING FIXTURES', style: AppText.label),
                  const SizedBox(height: 10),
                  TextField(
                    controller: input,
                    minLines: 5,
                    maxLines: 9,
                    enabled: !busy,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'One fixture per line:\nHome Team vs Away Team',
                      border: OutlineInputBorder(),
                      helperText: 'Use real upcoming fixtures. Coverage varies by league.',
                      helperMaxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: busy ? null : analyze,
                    icon: busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.analytics_outlined),
                    label: Text(busy ? 'Analyzing $completed/${parsed?.fixtures.length ?? 0}…' : 'Analyze with live data'),
                  ),
                  if (busy) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: parsed == null || parsed!.fixtures.isEmpty
                          ? null
                          : completed / parsed!.fixtures.length,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (parsed != null) ...[
            const SizedBox(height: 18),
            Text('${parsed!.fixtures.length} recognized fixture(s)',
                style: AppText.heading),
            const SizedBox(height: 10),
            if (parsed!.fixtures.isEmpty)
              const Text('Enter fixtures as “Home Team vs Away Team”.',
                  style: AppText.muted),
            for (final fixture in parsed!.fixtures) ...[
              _ResultCard(
                fixture: fixture,
                data: results[fixture.label],
                error: errors[fixture.label],
              ),
              const SizedBox(height: 10),
            ],
            if (parsed!.invalidLines.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unrecognized input', style: AppText.heading),
                      for (final line in parsed!.invalidLines)
                        Text(line, style: AppText.muted),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Provider predictions are estimates, not guaranteed outcomes. No percentages are invented when provider data is missing.',
            style: AppText.caption,
          ),
        ],
      );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? value.map((key, value) => MapEntry(key.toString(), value)) : <String, dynamic>{};

String _display(dynamic value, {String fallback = '—'}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? fallback : text;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.fixture, this.data, this.error});
  final FixturePair fixture;
  final Map<String, dynamic>? data;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final verified = _map(data?['fixture']);
    final prediction = _map(data?['prediction']);
    final winner = _map(prediction['winner']);
    final probabilities = _map(prediction['probabilities']);
    final comparison = _map(prediction['comparison']);
    final teams = _map(prediction['teams']);
    final home = _map(teams['home']);
    final away = _map(teams['away']);
    final homeRecent = _map(home['last_5']);
    final awayRecent = _map(away['last_5']);
    final status = _display(data?['status'], fallback: 'unknown');
    final predictionStatus = _display(data?['predictionStatus'], fallback: 'unknown');
    final ready = predictionStatus == 'ok' && prediction.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fixture.label, style: AppText.heading),
            const SizedBox(height: 8),
            if (error != null)
              Text(error!, style: const TextStyle(color: AppColors.warning))
            else if (data == null)
              const Text('Waiting for fixture verification and prediction…',
                  style: AppText.muted)
            else if (status != 'found' && status != 'ok')
              Text(_display(data?['message'], fallback: 'Fixture not verified.'),
                  style: AppText.muted)
            else ...[
              Text(
                _display(verified['competition'], fallback: 'Verified fixture'),
                style: AppText.muted,
              ),
              if (!ready) ...[
                const SizedBox(height: 10),
                Text(
                  _display(data?['predictionMessage'],
                      fallback: 'Statistical prediction is not available for this fixture.'),
                  style: AppText.muted,
                ),
              ] else ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _TeamSummary(
                      name: _display(home['name'], fallback: _display(verified['home'])),
                      logo: _display(home['logo'], fallback: ''),
                    )),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('VS', style: AppText.label),
                    ),
                    Expanded(child: _TeamSummary(
                      name: _display(away['name'], fallback: _display(verified['away'])),
                      logo: _display(away['logo'], fallback: ''),
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('MATCH OUTCOME PROBABILITIES', style: AppText.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 18,
                  runSpacing: 10,
                  children: [
                    _Metric('Home win', _display(probabilities['home'])),
                    _Metric('Draw', _display(probabilities['draw'])),
                    _Metric('Away win', _display(probabilities['away'])),
                  ],
                ),
                const Divider(height: 28),
                const Text('PROVIDER RECOMMENDATION', style: AppText.label),
                const SizedBox(height: 6),
                Text(_display(prediction['advice'], fallback: 'No advice provided.'),
                    style: AppText.bodyStrong),
                const SizedBox(height: 5),
                Text(
                  'Favored: ${_display(winner['name'], fallback: 'Not specified')}',
                  style: AppText.muted,
                ),
                if (_display(winner['comment'], fallback: '').isNotEmpty)
                  Text(_display(winner['comment']), style: AppText.caption),
                const Divider(height: 28),
                const Text('TEAM FORM & PERFORMANCE', style: AppText.label),
                const SizedBox(height: 8),
                _CompareRow('Recent games', _display(homeRecent['played']),
                    _display(awayRecent['played'])),
                _CompareRow('Recent form', _display(homeRecent['form']),
                    _display(awayRecent['form'])),
                _CompareRow('Average goals scored',
                    _display(_map(_map(homeRecent['goals'])['for'])['average']),
                    _display(_map(_map(awayRecent['goals'])['for'])['average'])),
                _CompareRow('Average goals conceded',
                    _display(_map(_map(homeRecent['goals'])['against'])['average']),
                    _display(_map(_map(awayRecent['goals'])['against'])['average'])),
                const SizedBox(height: 12),
                const Text('PROVIDER COMPARISON', style: AppText.label),
                const SizedBox(height: 8),
                for (final entry in <String, String>{
                  'form': 'Form',
                  'att': 'Attack',
                  'def': 'Defense',
                  'h2h': 'Head-to-head',
                  'total': 'Overall comparison',
                }.entries)
                  _CompareRow(
                    entry.value,
                    _display(_map(comparison[entry.key])['home']),
                    _display(_map(comparison[entry.key])['away']),
                  ),
                const SizedBox(height: 10),
                Text(
                  _display(data?['predictionMessage'],
                      fallback: 'Statistical estimates, not guaranteed outcomes.'),
                  style: AppText.caption,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TeamSummary extends StatelessWidget {
  const _TeamSummary({required this.name, required this.logo});
  final String name;
  final String logo;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (logo.startsWith('https://'))
            Image.network(
              logo,
              height: 46,
              width: 46,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield_outlined, size: 40),
            )
          else
            const Icon(Icons.shield_outlined, size: 40),
          const SizedBox(height: 6),
          Text(name, textAlign: TextAlign.center, maxLines: 2,
              overflow: TextOverflow.ellipsis, style: AppText.bodyStrong),
        ],
      );
}

class _CompareRow extends StatelessWidget {
  const _CompareRow(this.label, this.home, this.away);
  final String label;
  final String home;
  final String away;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(width: 66, child: Text(home, style: AppText.bodyStrong)),
            Expanded(child: Text(label, textAlign: TextAlign.center,
                style: AppText.caption)),
            SizedBox(width: 66, child: Text(away, textAlign: TextAlign.end,
                style: AppText.bodyStrong)),
          ],
        ),
      );
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
          Text(value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800,
                  color: AppColors.text)),
        ],
      );
}
