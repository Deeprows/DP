import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final posts = <String>[];

  Future<void> _compose() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: const Text('Create a post'),
      content: TextField(controller: controller, autofocus: true, maxLines: 4, maxLength: 500, decoration: const InputDecoration(hintText: 'Share your football thoughts…')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Post')),
      ],
    ));
    controller.dispose();
    if (!mounted || text == null || text.isEmpty) return;
    setState(() => posts.insert(0, text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft added on this device. Connect a community database to publish posts for everyone.')));
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Community', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
    const SizedBox(height: 5),
    const Text('Talk football. Share ideas. Connect with fans.', style: AppText.muted),
    const SizedBox(height: 20),
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xff3a1b27), AppColors.surface]),
      borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border),
    ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.groups_rounded, size: 38, color: AppColors.accent),
      const SizedBox(height: 12),
      const Text('Your football community starts here', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Create local draft posts now. Public feeds, replies, likes and user profiles need a community database connection.', style: AppText.muted),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: _compose, icon: const Icon(Icons.edit_outlined), label: const Text('Write a post')),
    ])),
    const SizedBox(height: 22),
    Row(children: [const Expanded(child: Text('Community feed', style: AppText.heading)), Pill('${posts.length} drafts')]),
    const SizedBox(height: 12),
    if (posts.isEmpty)
      const Card(child: Padding(padding: EdgeInsets.symmetric(vertical: 45, horizontal: 20), child: Column(children: [
        Icon(Icons.forum_outlined, color: AppColors.accent, size: 40),
        SizedBox(height: 12),
        Text('No posts yet', style: AppText.heading),
        SizedBox(height: 6),
        Text('Create your first draft. Shared community posts will become available after backend integration.', textAlign: TextAlign.center, style: AppText.muted),
      ])))
    else
      for (final post in posts) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.account_circle, color: AppColors.accent), SizedBox(width: 9), Text('My draft', style: AppText.heading), Spacer(), Pill('LOCAL')]),
        const SizedBox(height: 14),
        Text(post, style: AppText.body),
      ]))),
  ]);
}
