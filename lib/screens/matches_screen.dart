import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/match.dart';
import '../services/fixtures_service.dart';
import '../theme.dart';
import 'match_detail_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late final DateTime today;
  late final List<DateTime> days;
  int dayIndex = 1;
  String league = 'All';
  bool liveOnly = false;
  late Future<List<LiveFixture>> matchesFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    days = List.generate(7, (i) => today.add(Duration(days: i - 1)));
    _reload();
  }

  void _reload() {
    matchesFuture = liveOnly
        ? FixturesService.live()
        : FixturesService.forDate(days[dayIndex]);
  }

  void _changeDay(int index) {
    setState(() {
      dayIndex = index;
      liveOnly = false;
      league = 'All';
      _reload();
    });
  }

  void _toggleLive() {
    setState(() {
      liveOnly = !liveOnly;
      league = 'All';
      _reload();
    });
  }

  Future<void> _refresh() async {
    setState(_reload);
    try {
      await matchesFuture;
    } catch (_) {
      // The FutureBuilder displays the actual error.
    }
  }

  void _openDetails(LiveFixture fixture) {
    final match = Match(
      fixture.home,
      fixture.away,
      fixture.competition,
      fixture.kickoff,
      fixture.homeScore,
      fixture.awayScore,
    );
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MatchDetailScreen(match: match),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Match Centre',
                        style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('Real fixtures and scores · device time',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _toggleLive,
                icon: Icon(Icons.circle, size: 10,
                    color: liveOnly ? Colors.white : AppColors.accent),
                label: Text(liveOnly ? 'All dates' : 'LIVE'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: liveOnly ? AppColors.accent : null,
                  foregroundColor: liveOnly ? Colors.white : AppColors.text,
                ),
              ),
              IconButton(
                onPressed: _refresh,
                tooltip: 'Refresh matches',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        if (!liveOnly)
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _dayChip(i),
            ),
          ),
        Expanded(
          child: FutureBuilder<List<LiveFixture>>(
            future: matchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _message(
                  Icons.wifi_off_outlined,
                  'Could not load matches',
                  '${snapshot.error}',
                );
              }
              final matches = snapshot.data ?? <LiveFixture>[];
              final leagues = <String>['All',
                ...{for (final match in matches) match.competition}
              ];
              final activeLeague = leagues.contains(league) ? league : 'All';
              final filtered = matches.where((match) =>
                  activeLeague == 'All' || match.competition == activeLeague).toList();
              final grouped = <String, List<LiveFixture>>{};
              for (final match in filtered) {
                grouped.putIfAbsent(match.competition, () => []).add(match);
              }
              return Column(
                children: [
                  if (leagues.length > 2)
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        itemCount: leagues.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 7),
                        itemBuilder: (_, i) => ChoiceChip(
                          label: Text(leagues[i], style: const TextStyle(fontSize: 12)),
                          selected: activeLeague == leagues[i],
                          onSelected: (_) => setState(() => league = leagues[i]),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${filtered.length} matches${liveOnly ? ' live' : ''}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: filtered.isEmpty
                          ? ListView(children: [
                              const SizedBox(height: 95),
                              _emptyContent(),
                            ])
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: grouped.length,
                              itemBuilder: (context, i) {
                                final name = grouped.keys.elementAt(i);
                                final items = grouped[name]!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(3, 12, 0, 8),
                                      child: Text(name, style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w700)),
                                    ),
                                    for (final item in items) Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _matchCard(item),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _emptyContent() => const Center(
    child: Column(children: [
      Icon(Icons.sports_soccer_outlined, size: 40, color: AppColors.textMuted),
      SizedBox(height: 12),
      Text('No matches found', style: TextStyle(fontWeight: FontWeight.w700)),
      SizedBox(height: 6),
      Text('Try another date or turn off LIVE.',
          style: TextStyle(color: AppColors.textMuted)),
    ]),
  );

  Widget _message(IconData icon, String title, String detail) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 40, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(detail, textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 12),
        FilledButton(onPressed: _refresh, child: const Text('Retry')),
      ]),
    ),
  );

  Widget _dayChip(int i) {
    final date = days[i];
    final selected = dayIndex == i;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _changeDay(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 56,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(isSameDay(date, today) ? 'Today' : DateFormat('EEE').format(date),
              style: TextStyle(fontSize: 10, color: selected ? Colors.white70 : AppColors.textMuted)),
          const SizedBox(height: 3),
          Text('${date.day}', style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.text)),
        ]),
      ),
    );
  }

  Widget _matchCard(LiveFixture m) {
    final status = m.isLive
        ? '${m.elapsed ?? ''}${m.elapsed == null ? '' : '′'} LIVE'
        : m.isFinished
            ? 'FT'
            : m.isUpcoming
                ? DateFormat('HH:mm').format(m.kickoff)
                : (m.statusLong.isEmpty ? m.status : m.statusLong);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetails(m),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(children: [
            SizedBox(
              width: 55,
              child: Text(status, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: m.isLive ? AppColors.accent : AppColors.textMuted)),
            ),
            Container(width: 1, height: 46, margin: const EdgeInsets.only(right: 12),
                color: AppColors.border),
            Expanded(child: Column(children: [
              _teamRow(m.home, m.homeLogo, m.homeScore),
              const SizedBox(height: 8),
              _teamRow(m.away, m.awayLogo, m.awayScore),
            ])),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ]),
        ),
      ),
    );
  }

  Widget _teamRow(String name, String logo, int? score) => Row(children: [
    SizedBox(
      width: 23, height: 23,
      child: logo.startsWith('https://')
          ? Image.network(logo, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield_outlined, size: 19))
          : const Icon(Icons.shield_outlined, size: 19),
    ),
    const SizedBox(width: 8),
    Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
    if (score != null)
      Text('$score', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
  ]);
}
