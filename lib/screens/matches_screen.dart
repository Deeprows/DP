import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});
  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late final DateTime today;
  late final List<Match> all;
  late final List<DateTime> days;
  int dayIndex = 1;
  String league = 'All';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    all = demoMatches(now);
    days = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + i - 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = days[dayIndex];
    final dayMatches = all.where((m) => isSameDay(m.kickoff, day)).toList()
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
    final leagues = [
      'All',
      ...{for (final m in dayMatches) m.league}
    ];
    final active = leagues.contains(league) ? league : 'All';
    final visible = active == 'All'
        ? dayMatches
        : dayMatches.where((m) => m.league == active).toList();

    final grouped = <String, List<Match>>{};
    for (final m in visible) {
      grouped.putIfAbsent(m.league, () => []).add(m);
    }

    final children = <Widget>[];
    grouped.forEach((name, list) {
      children.add(Padding(
        padding: EdgeInsets.fromLTRB(2, children.isEmpty ? 4 : 14, 0, 8),
        child: SectionLabel(name),
      ));
      for (final m in list) {
        children.add(MatchCard(
          match: m,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MatchDetailScreen(match: m)),
          ),
        ));
        children.add(const SizedBox(height: 6));
      }
    });

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sample fixtures — live scores are not connected.',
              style: TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _dayChip(i),
          ),
        ),
        if (leagues.length > 2)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              itemCount: leagues.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => _leagueChip(leagues[i], active),
            ),
          ),
        Expanded(
          child: visible.isEmpty
              ? const EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'No matches',
                  text: 'There are no sample fixtures on this day.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: children,
                ),
        ),
      ],
    );
  }

  Widget _dayChip(int i) {
    final d = days[i];
    final selected = i == dayIndex;
    final isToday = isSameDay(d, today);
    return GestureDetector(
      onTap: () => setState(() => dayIndex = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 52,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday ? 'Today' : DateFormat('EEE').format(d),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white70 : AppColors.textFaint,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${d.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leagueChip(String name, String active) {
    final selected = name == active;
    return GestureDetector(
      onTap: () => setState(() => league = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.text : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
