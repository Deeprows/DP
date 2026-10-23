import 'package:flutter/material.dart';
import '../theme.dart';

String initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final word = parts.first;
    return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

class TeamBadge extends StatelessWidget {
  const TeamBadge({super.key, required this.name, this.size = 24});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hue =
        name.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) % 360).toDouble();
    final bg = HSLColor.fromAHSL(1, hue, .45, .24).toColor();
    final fg = HSLColor.fromAHSL(1, hue, .75, .78).toColor();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        initials(name),
        style: TextStyle(
          fontSize: size * .38,
          fontWeight: FontWeight.w700,
          color: fg,
          height: 1,
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.color = AppColors.textMuted});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withAlpha(32),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
            color: color,
          ),
        ),
      );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppText.label);
}

class IconBox extends StatelessWidget {
  const IconBox(this.icon, {super.key, this.size = 34});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: size * .52, color: AppColors.accent),
      );
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.text, this.icon = Icons.info_outline});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warning.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withAlpha(50)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppText.muted)),
          ],
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.badge,
  });
  final IconData icon;
  final String title, text;
  final String? badge;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBox(icon, size: 48),
                const SizedBox(height: 14),
                Text(title, style: AppText.heading.copyWith(fontSize: 16)),
                if (badge != null) ...[
                  const SizedBox(height: 8),
                  Pill(badge!, color: AppColors.accent),
                ],
                const SizedBox(height: 8),
                Text(text, textAlign: TextAlign.center, style: AppText.muted),
              ],
            ),
          ),
        ),
      );
}
