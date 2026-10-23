import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } on FirebaseException {
      // Allows the navigation shell to render in isolated widget tests.
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('My profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      const Text('Your DP Football AI account', style: AppText.muted),
      const SizedBox(height: 24),
      Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(children: [
        CircleAvatar(radius: 37, backgroundColor: AppColors.accentSoft, child: Text(initials(user?.displayName ?? user?.email ?? 'DP'), style: const TextStyle(fontSize: 25, color: AppColors.accent, fontWeight: FontWeight.bold))),
        const SizedBox(height: 14),
        Text(user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Football fan', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(user?.email ?? 'Not signed in', textAlign: TextAlign.center, style: AppText.muted),
        const SizedBox(height: 12),
        Pill(user?.emailVerified == true ? 'EMAIL VERIFIED' : 'ACCOUNT', color: AppColors.accent),
      ]))),
      const SizedBox(height: 18),
      const Text('ACCOUNT', style: AppText.label),
      const SizedBox(height: 10),
      Card(child: Column(children: [
        ListTile(leading: const Icon(Icons.email_outlined, color: AppColors.accent), title: const Text('Email address'), subtitle: Text(user?.email ?? 'Unavailable')),
        const Divider(height: 1),
        const ListTile(leading: Icon(Icons.shield_outlined, color: AppColors.accent), title: Text('Authentication'), subtitle: Text('Protected by Firebase Authentication')),
      ])),
      const SizedBox(height: 18),
      OutlinedButton.icon(onPressed: () async {
        try {
          await FirebaseAuth.instance.signOut();
        } on FirebaseAuthException catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Could not sign out.')));
        }
      }, icon: const Icon(Icons.logout), label: const Text('Sign out')),
    ]);
  }
}
