import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/logo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Row(children: [
            const JaLogo(size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.appName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: JaColors.navy)),
                Text(s.constituency, style: const TextStyle(color: JaColors.textSecondary)),
              ]),
            ),
            TextButton(onPressed: state.toggleLanguage, child: Text(s.switchLanguage)),
          ]),
          const SizedBox(height: 32),
          Text(s.whoIsUsing,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: JaColors.textPrimary)),
          const SizedBox(height: 16),
          _ProfileCard(
            icon: Icons.groups_outlined,
            color: JaColors.primaryLight,
            title: s.profileJanta,
            subtitle: s.profileJantaDesc,
            onTap: () => state.setProfile(Profile.janta),
          ),
          _ProfileCard(
            icon: Icons.assignment_ind_outlined,
            color: JaColors.saffron,
            title: s.profileVolunteer,
            subtitle: s.profileVolunteerDesc,
            onTap: () => state.setProfile(Profile.volunteer),
          ),
          _ProfileCard(
            icon: Icons.insights,
            color: JaColors.navy,
            title: s.profileAdmin,
            subtitle: s.profileAdminDesc,
            onTap: () => state.setProfile(Profile.admin),
          ),
          const SizedBox(height: 12),
          Text(s.demoProfilesNote,
              textAlign: TextAlign.center, style: const TextStyle(color: JaColors.textSecondary, fontSize: 13)),
        ]),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard(
      {required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: JaColors.textSecondary)),
                ]),
              ),
              const Icon(Icons.chevron_right, color: JaColors.grey),
            ]),
          ),
        ),
      ),
    );
  }
}
