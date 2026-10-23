import 'package:flutter/material.dart';
import '../widgets/common.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title, text;

  @override
  Widget build(BuildContext context) => EmptyState(
        icon: icon,
        title: title,
        text: text,
        badge: 'COMING SOON',
      );
}
