import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/match.dart';
import '../services/fixtures_service.dart';
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

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    if (widget.fixture != null && widget.fixture!.id > 0) {
      _details = FixturesService.byId(widget.fixture!.id);
    }
  }

  Future<void> _reload() async {
    setState(_refresh);
    try {
      await _details;
    } catch (_) {
      // The FutureBuilder shows errors without losing the known fixture.
    }
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
                        Text(league, textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        if ((fixture?.round ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(fixture!.round, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
                                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800,
                                        color: isLive ? AppColors.accent : AppColors.text),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(status, textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                          color: isLive ? AppColors.accent : AppColors.textMuted)),
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
                  Card(child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Could not refresh match details',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text('${snapshot.error}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      TextButton(onPressed: _reload, child: const Text('Try again')),
                    ]),
                  )),
                ],
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    child: Column(children: [
                      _info('Competition', league),
                      const Divider(height: 1),
                      _info('Date', DateFormat('EEE, d MMM yyyy').format(kickoff)),
                      const Divider(height: 1),
                      _info('Kickoff', '${DateFormat('HH:mm').format(kickoff)} · local time'),
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
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.auto_awesome, color: AppColors.accent),
                      SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('AI match insights', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        SizedBox(height: 6),
                        Text('Statistical predictions are not connected yet. Live scores and match information come from API-Football.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ])),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _team(String name, String logo) => Column(children: [
    SizedBox(
      width: 56,
      height: 56,
      child: logo.startsWith('https://')
          ? Image.network(logo, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield_outlined, size: 38))
          : const Icon(Icons.shield_outlined, size: 38),
    ),
    const SizedBox(height: 10),
    Text(name, textAlign: TextAlign.center, maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
  ]);

  Widget _info(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 13),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 104, child: Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
      Expanded(child: Text(value, textAlign: TextAlign.end,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  );
}
