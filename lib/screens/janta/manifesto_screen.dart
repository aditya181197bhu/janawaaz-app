import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/logo.dart';

/// Manifesto read from assets/manifesto/manifesto.json (the same file the PDF is built from).
class ManifestoView extends StatelessWidget {
  const ManifestoView({super.key});

  static const _icons = {
    'water': Icons.water_drop_outlined,
    'road': Icons.add_road,
    'health': Icons.local_hospital_outlined,
    'school': Icons.school_outlined,
    'trade': Icons.storefront_outlined,
    'safety': Icons.shield_outlined,
    'river': Icons.waves,
    'governance': Icons.account_balance_outlined,
  };

  Future<Map<String, dynamic>> _load() async =>
      jsonDecode(await rootBundle.loadString('assets/manifesto/manifesto.json')) as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final suffix = state.hindi ? 'Hi' : 'En';
    return AsyncView<Map<String, dynamic>>(
      load: _load,
      builder: (context, m, _) => ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [JaColors.navy, JaColors.primaryLight]),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const JaLogo(size: 40),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: JaColors.saffron, borderRadius: BorderRadius.circular(10)),
                child: Text(s.draft, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 14),
            Text(m['title$suffix'],
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(m['subtitle$suffix'], style: const TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: JaColors.saffron),
          onPressed: () => _download(context),
          icon: const Icon(Icons.download),
          label: Text(s.downloadPdf),
        ),
        const SizedBox(height: 14),
        Text(m['intro$suffix'], style: const TextStyle(color: JaColors.textSecondary, height: 1.45)),
        const SizedBox(height: 14),
        for (final section in (m['sections'] as List).cast<Map<String, dynamic>>()) ...[
          SectionCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_icons[section['icon']] ?? Icons.check_circle_outline, color: JaColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(section['title$suffix'],
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: JaColors.navy)),
                ),
              ]),
              const SizedBox(height: 10),
              for (final (i, point) in (section['points$suffix'] as List).cast<String>().indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 10, top: 1),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: JaColors.sky, shape: BoxShape.circle),
                      child: Text('${i + 1}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: JaColors.primary)),
                    ),
                    Expanded(child: Text(point, style: const TextStyle(height: 1.4))),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 16),
      ]),
    );
  }

  /// Opens the system "save as" dialog, so the PDF lands wherever the person
  /// chooses (e.g. Downloads) without the app needing storage permission.
  Future<void> _download(BuildContext context) async {
    final state = context.read<AppState>();
    final lang = state.hindi ? 'hi' : 'en';
    try {
      final bytes = await rootBundle.load('assets/manifesto/manifesto_$lang.pdf');
      final path = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: bytes.buffer.asUint8List(),
          fileName: state.hindi ? 'Jan-Awaaz-Ghoshnapatra.pdf' : 'Jan-Awaaz-Manifesto.pdf',
          mimeTypesFilter: const ['application/pdf'],
        ),
      );
      if (path != null && context.mounted) showMessage(context, state.s.pdfSaved);
    } catch (e) {
      if (context.mounted) showMessage(context, '${state.s.somethingWentWrong}: $e', error: true);
    }
  }
}
