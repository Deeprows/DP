import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../theme.dart';
import 'common.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match, required this.onTap});
  final Match match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = match;
    final homeWon = m.finished && m.homeScore! > m.awayScore!;
    final awayWon = m.finished && m.awayScore! > m.homeScore!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  m.finished ? 'FT' : DateFormat('HH:mm').format(m.kickoff),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: m.finished ? AppColors.textFaint : AppColors.accent,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: AppColors.border,
              ),
              Expanded(
                child: Column(
                  children: [
                    _team(m.home, m.homeScore, homeWon),
                    const SizedBox(height: 6),
                    _team(m.away, m.awayScore, awayWon),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }

  Widget _team(String name, int? score, bool winner) => Row(
        children: [
          TeamBadge(name: name, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: winner ? FontWeight.w700 : FontWeight.w500,
                color: match.finished && !winner
                    ? AppColors.textMuted
                    : AppColors.text,
              ),
            ),
          ),
          if (score != null)
            Text(
              '$score',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: winner ? FontWeight.w800 : FontWeight.w600,
                color: winner ? AppColors.text : AppColors.textMuted,
              ),
            ),
        ],
      );
}
