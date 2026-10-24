import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/logo.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Scaffold(
      backgroundColor: JaColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(children: [
            const Spacer(),
            const JaLogo(size: 96),
            const SizedBox(height: 20),
            const Text('जन आवाज़',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
            const Text('Jan Awaaz', style: TextStyle(fontSize: 18, color: Colors.white70, letterSpacing: 1)),
            const Spacer(),
            const Text('भाषा चुनें · Choose your language',
                style: TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _LanguageButton(label: 'हिन्दी', onTap: () => state.setLanguage('hi'))),
              const SizedBox(width: 14),
              Expanded(child: _LanguageButton(label: 'English', onTap: () => state.setLanguage('en'))),
            ]),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 88,
          child: Center(
            child: Text(label,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: JaColors.navy)),
          ),
        ),
      ),
    );
  }
}
