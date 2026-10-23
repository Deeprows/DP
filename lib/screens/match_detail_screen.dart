import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/match.dart';
import '../services/fixtures_service.dart';
import '../services/prediction_service.dart';
import '../theme.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({super.key, required this.match, this.fixture});

  final Match match;
  final LiveFixture? fixture;

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  Future<LiveFixture>? _details;
  Future<Map<String, dynamic>>? _prediction;
  bool _showPrediction = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final id = widget.fixture?.id;
    if (id != null && id > 0) {
      _details = FixturesService.byId(id);
    }
  }

  Future<void> _reload() async {
    setState(_refresh);
    try {
      await _details;
    } catch (_) {
      // Keep the supplied fixture visible if refreshing fails.
    }
  }

  Future<Map<String, dynamic>> _fetchPrediction(int fixtureId) async {
    final endpoint = PredictionService.endpoint.trim();
    if (endpoint.isEmpty) {
      throw StateError('Prediction API URL is not configured.');
    }
    final base = endpoint.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/predictions').replace(
      queryParameters: {'fixture': '$fixtureId'},
    );
    final http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 45));
    } catch (_) {
      throw StateError('Unable to connect to the prediction service.');
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw StateError('Prediction service returned invalid JSON.');
    }
    if (decoded is! Map) {
      throw StateError('Unexpected prediction response.');
    }
    final data = Map<String, dynamic>.from(decoded);
    if (response.statusCode != 200 || data['status'] == 'error') {
      throw StateError(data['message']?.toString() ??
          'Prediction request failed (HTTP ${response.statusCode}).');
    }
    return data;
  }

  void _analyze(int fixtureId) {
    setState(() {
      _showPrediction = true;
      _prediction = _fetchPrediction(fixtureId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match centre'),
        actions: [
          if (_details != null)
            IconButton(
              tooltip: 'Refresh match',
              icon: const Icon(Icons.refresh),
              onPressed: _reload,
            ),
        ],
      ),
      body: FutureBuilder<LiveFixture>(
        future: _details,
        builder: (context, snapshot) {
          final fixture = snapshot.data ?? widget.fixture;
          final m = widget.match;
          final home = fixture?.home ?? m.home;
          final away = fixture?.away ?? m.away;
          final league = fixture?.competition ?? m.league;
          final kickoff = fixture?.kickoff ?? m.kickoff;
          final homeScore = fixture?.homeScore ?? m.homeScore;
          final awayScore = fixture?.awayScore ?? m.awayScore;
          final isLive = fixture?.isLive ?? false;
          final finished = fixture?.isFinished ?? m.finished;
          final status = fixture == null
              ? (finished ? 'Full time' : 'Scheduled')
              : isLive
                  ? 'LIVE${fixture.elapsed == null ? '' : ' · ${fixture.elapsed}′'}'
                  : fixture.statusLong.isNotEmpty
                      ? fixture.statusLong
                      : fixture.status;
          final fixtureId = fixture?.id;

          return RefreshIndicator(
            onRefresh: _details == null ? () async {} : _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 20, 14, 22),
                    child: Column(
                      children: [
                        if ((fixture?.leagueLogo ?? '').startsWith('https://'))
                          Image.network(
                            fixture!.leagueLogo,
                            width: 32,
                            height: 32,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        const SizedBox(height: 8),
                        Text(league,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        if ((fixture?.round ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(fixture!.round,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                        ],
                        const SizedBox(height: 22),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _team(home, fixture?.homeLogo ?? '')),
                            SizedBox(
                              width: 112,
                              child: Column(
                                children: [
                                  Text(
                                    homeScore != null && awayScore != null
                                        ? '$homeScore  :  $awayScore'
                                        : DateFormat('HH:mm').format(kickoff),
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w800,
                                        color: isLive
                                            ? AppColors.accent
                                            : AppColors.text),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(status,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isLive
                                              ? AppColors.accent
                                              : AppColors.textMuted)),
                                ],
                              ),
                            ),
                            Expanded(child: _team(away, fixture?.awayLogo ?? '')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                if (snapshot.hasError) ...[
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Could not refresh match details',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 5),
                          Text('${snapshot.error}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                          TextButton(
                              onPressed: _reload, child: const Text('Try again')),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    child: Column(children: [
                      _info('Competition', league),
                      const Divider(height: 1),
                      _info('Date', DateFormat('EEE, d MMM yyyy').format(kickoff)),
                      const Divider(height: 1),
                      _info('Kickoff',
                          '${DateFormat('HH:mm').format(kickoff)} · local time'),
                      const Divider(height: 1),
                      _info('Status', status),
                      if ((fixture?.venue ?? '').isNotEmpty) ...[
                        const Divider(height: 1),
                        _info('Venue', fixture!.venue),
                      ],
                      if ((fixture?.country ?? '').isNotEmpty) ...[
                        const Divider(height: 1),
                        _info('Country', fixture!.country),
                      ],
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(children: [
                          Icon(Icons.auto_awesome, color: AppColors.accent),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('AI match insights',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        const Text(
                          'View API-Football statistical predictions for this fixture.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: fixtureId == null || fixtureId <= 0
                              ? null
                              : () => _analyze(fixtureId),
                          icon: const Icon(Icons.analytics_outlined),
                          label: Text(_showPrediction
                              ? 'Refresh prediction'
                              : 'Analyze match'),
                        ),
                        if (fixtureId == null || fixtureId <= 0)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Predictions require a verified API-Football fixture.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                            ),
                          ),
                        if (_showPrediction && _prediction != null) ...[
                          const SizedBox(height: 14),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _prediction,
                            builder: (context, result) {
                              if (result.connectionState == ConnectionState.waiting) {
                                return const Column(children: [
                                  LinearProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Loading verified prediction…'),
                                ]);
                              }
                              if (result.hasError) {
                                return Text(
                                  '${result.error}'.replaceFirst('Bad state: ', ''),
                                  style: const TextStyle(color: AppColors.warning),
                                );
                              }
                              final data = result.data ?? {};
                              if (data['status'] != 'ok') {
                                return Text(
                                  data['message']?.toString() ??
                                      'Prediction unavailable for this fixture.',
                                  style: const TextStyle(color: AppColors.textMuted),
                                );
                              }
                              final prediction = _asMap(data['prediction']);
                              if (prediction.isEmpty) {
                                return const Text('No statistical prediction returned.');
                              }
                              final probs = _asMap(prediction['probabilities']);
                              final winner = _asMap(prediction['winner']);
                              final comparison = _asMap(prediction['comparison']);
                              final teams = _asMap(prediction['teams']);
                              final homeTeam = _asMap(teams['home']);
                              final awayTeam = _asMap(teams['away']);
                              final homeRecent = _asMap(homeTeam['last_5']);
                              final awayRecent = _asMap(awayTeam['last_5']);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('MATCH OUTCOME',
                                      style: TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Wrap(spacing: 18, runSpacing: 10, children: [
                                    _metric('Home win', probs['home']),
                                    _metric('Draw', probs['draw']),
                                    _metric('Away win', probs['away']),
                                  ]),
                                  const Divider(height: 26),
                                  const Text('PROVIDER RECOMMENDATION',
                                      style: TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(_value(prediction['advice'],
                                      fallback: 'No advice provided')),
                                  const SizedBox(height: 4),
                                  Text('Favored: ${_value(winner['name'], fallback: 'Not specified')}',
                                      style: const TextStyle(color: AppColors.textMuted)),
                                  const Divider(height: 26),
                                  const Text('RECENT TEAM FORM',
                                      style: TextStyle(fontWeight: FontWeight.w700)),
                                  _comparisonRow('Games played',
                                      homeRecent['played'], awayRecent['played']),
                                  _comparisonRow('Form',
                                      homeRecent['form'], awayRecent['form']),
                                  _comparisonRow('Goals scored / game',
                                      _asMap(_asMap(homeRecent['goals'])['for'])['average'],
                                      _asMap(_asMap(awayRecent['goals'])['for'])['average']),
                                  _comparisonRow('Goals conceded / game',
                                      _asMap(_asMap(homeRecent['goals'])['against'])['average'],
                                      _asMap(_asMap(awayRecent['goals'])['against'])['average']),
                                  const Divider(height: 26),
                                  const Text('TEAM COMPARISON',
                                      style: TextStyle(fontWeight: FontWeight.w700)),
                                  for (final entry in const {
                                    'form': 'Form',
                                    'att': 'Attack',
                                    'def': 'Defense',
                                    'h2h': 'Head-to-head',
                                    'total': 'Overall',
                                  }.entries)
                                    _comparisonRow(
                                      entry.value,
                                      _asMap(comparison[entry.key])['home'],
                                      _asMap(comparison[entry.key])['away'],
                                    ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Provider estimates are based on available statistics and do not guarantee match outcomes.',
                                    style: TextStyle(
                                        fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) => value is Map
      ? value.map((key, value) => MapEntry(key.toString(), value))
      : <String, dynamic>{};

  static String _value(dynamic value, {String fallback = '—'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? fallback : text;
  }

  Widget _metric(String label, dynamic value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(_value(value),
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w800)),
        ],
      );

  Widget _comparisonRow(String label, dynamic home, dynamic away) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(width: 58, child: Text(_value(home))),
          Expanded(
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
          ),
          SizedBox(
            width: 58,
            child: Text(_value(away), textAlign: TextAlign.end),
          ),
        ]),
      );

  Widget _team(String name, String logo) => Column(children: [
        SizedBox(
          width: 56,
          height: 56,
          child: logo.startsWith('https://')
              ? Image.network(logo,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.shield_outlined, size: 38))
              : const Icon(Icons.shield_outlined, size: 38),
        ),
        const SizedBox(height: 10),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700)),
      ]);

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 104,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}
