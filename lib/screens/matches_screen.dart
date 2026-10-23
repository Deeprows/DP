import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/fixtures_service.dart';
import '../services/prediction_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'match_detail_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});
  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late Future<List<LiveFixture>> request;
  late DateTime chosen;
  String filter = 'All';
  String league = 'All';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    chosen = DateTime(now.year, now.month, now.day);
    _refresh();
  }

  void _refresh() => request = FixturesService.upcoming();
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  bool _live(String s) => ['LIVE', 'IN_PLAY', '1H', '2H', 'HT', 'PAUSED'].contains(s.toUpperCase());
  bool _finished(String s) => ['FT', 'FINISHED', 'FULL_TIME', 'ENDED', 'AET'].contains(s.toUpperCase());

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () async {
      setState(_refresh);
      try { await request; } catch (_) {}
    },
    child: FutureBuilder<List<LiveFixture>>(
      future: request,
      builder: (context, snapshot) {
        final fixtures = snapshot.data ?? <LiveFixture>[];
        final today = DateTime.now();
        final days = List.generate(9, (i) => DateTime(today.year, today.month, today.day + i - 2));
        final onDay = fixtures.where((m) => _sameDay(m.kickoff, chosen)).toList()
          ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
        final leagues = ['All', ...{for (final m in onDay) m.competition}];
        final activeLeague = leagues.contains(league) ? league : 'All';
        final visible = onDay.where((m) {
          if (activeLeague != 'All' && m.competition != activeLeague) return false;
          if (filter == 'Live' && !_live(m.status)) return false;
          if (filter == 'Upcoming' && (_live(m.status) || _finished(m.status))) return false;
          if (filter == 'Results' && !_finished(m.status)) return false;
          return true;
        }).toList();
        final groups = <String, List<LiveFixture>>{};
        for (final match in visible) {
          groups.putIfAbsent(match.competition, () => []).add(match);
        }
        return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 28), children: [
          const Text('Match centre', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Football fixtures, scores and match insights', style: AppText.muted),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xff331922), AppColors.surface]),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              const Icon(Icons.sports_soccer, color: AppColors.accent, size: 30),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('THE FOOTBALL HUB', style: AppText.label),
                const SizedBox(height: 3),
                Text(snapshot.hasData ? '${fixtures.length} fixtures from your provider' : 'Your football dashboard', style: AppText.heading),
                const SizedBox(height: 3),
                const Text('Pull down to refresh match data', style: AppText.caption),
              ])),
              IconButton(tooltip: 'Refresh', onPressed: () => setState(_refresh), icon: const Icon(Icons.refresh_rounded)),
            ]),
          ),
          const SizedBox(height: 18),
          SizedBox(height: 66, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final day = days[i];
              final selected = _sameDay(day, chosen);
              return InkWell(
                onTap: () => setState(() { chosen = day; league = 'All'; }),
                borderRadius: BorderRadius.circular(14),
                child: Container(width: 62, decoration: BoxDecoration(
                  color: selected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? AppColors.accent : AppColors.border),
                ), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_sameDay(day, today) ? 'Today' : DateFormat('EEE').format(day), style: TextStyle(fontSize: 11, color: selected ? Colors.white : AppColors.textMuted)),
                  const SizedBox(height: 3),
                  Text('${day.day}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ])),
              );
            },
          )),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: ['All', 'Live', 'Upcoming', 'Results'].map((item) => ChoiceChip(
            label: Text(item), selected: filter == item,
            onSelected: (_) => setState(() => filter = item),
            selectedColor: AppColors.accentSoft,
            side: BorderSide(color: filter == item ? AppColors.accent : AppColors.border),
          )).toList()),
          if (leagues.length > 1) ...[
            const SizedBox(height: 8),
            SizedBox(height: 44, child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: leagues.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text(leagues[i]), selected: activeLeague == leagues[i],
                onSelected: (_) => setState(() => league = leagues[i]),
                selectedColor: AppColors.accentSoft,
              ),
            )),
          ],
          const SizedBox(height: 18),
          if (snapshot.connectionState != ConnectionState.done)
            const Padding(padding: EdgeInsets.symmetric(vertical: 64), child: Center(child: CircularProgressIndicator()))
          else if (snapshot.hasError) ...[
            InfoBanner(text: PredictionService.endpoint.trim().isEmpty ? 'Live football data is not connected yet. Add PREDICTION_API_URL to your GitHub Actions configuration when your provider is ready.' : 'Could not reach the football provider. Check your internet connection or API configuration.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () => setState(_refresh), icon: const Icon(Icons.refresh), label: const Text('Try again')),
          ] else if (visible.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'No matches available',
              text: 'No matches were returned for this date and filter. Try another day or pull down to refresh.',
            ))
          else
            for (final group in groups.entries) ...[
              Padding(padding: const EdgeInsets.only(bottom: 10, top: 6), child: Row(children: [
                const Icon(Icons.emoji_events_outlined, size: 17, color: AppColors.accent),
                const SizedBox(width: 8),
                Expanded(child: Text(group.key.toUpperCase(), style: AppText.label)),
                Text('${group.value.length}', style: AppText.caption),
              ])),
              for (final match in group.value) ...[
                _fixtureCard(match),
                const SizedBox(height: 9),
              ],
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 8),
          const Center(child: Text('Match information comes from your configured data provider.', textAlign: TextAlign.center, style: AppText.caption)),
        ]);
      },
    ),
  );

  Widget _fixtureCard(LiveFixture match) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchDetailScreen(fixture: match))),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16), child: Row(children: [
        SizedBox(width: 53, child: Column(children: [
          Text(DateFormat('HH:mm').format(match.kickoff), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 4),
          Text(match.status.replaceAll('_', ' '), textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        ])),
        Container(height: 47, width: 1, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppColors.border),
        Expanded(child: Column(children: [
          Row(children: [TeamBadge(name: match.home, size: 26), const SizedBox(width: 9), Expanded(child: Text(match.home, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.heading))]),
          const SizedBox(height: 11),
          Row(children: [TeamBadge(name: match.away, size: 26), const SizedBox(width: 9), Expanded(child: Text(match.away, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.heading))]),
        ])),
        const Icon(Icons.chevron_right, color: AppColors.textFaint),
      ])),
    ),
  );
}
