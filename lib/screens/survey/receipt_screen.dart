import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/survey.dart';
import '../../providers/app_state.dart';

/// End-of-survey card from the plan: totals, top 3 priorities and a receipt ID.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.receipt, required this.draft});

  final SurveyReceipt receipt;
  final SurveyDraft draft;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final hi = state.hindi;
    final ward = state.ward(receipt.wardId);
    const mono = TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14, height: 1.6);
    final line = Container(height: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(vertical: 10));

    // The message says "serious", so use the highest-ranked priority rated Red.
    final redPriority = receipt.priorityQuestionIds.where((id) => draft.answers[id]?.rating == 'RED');
    final firstRed = redPriority.isEmpty ? null : state.question(redPriority.first).short(hi);
    final showWhatsapp = draft.whatsappOptIn && firstRed != null;
    final name = (draft.respondentName?.isNotEmpty ?? false) ? draft.respondentName! : (hi ? 'नागरिक' : 'Citizen');

    return Scaffold(
      appBar: AppBar(title: Text(s.surveySaved), automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF15192B), borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Text(s.receiptTitle,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 1)),
            ),
            Center(child: Text(ward.label(hi), style: const TextStyle(color: Colors.white60))),
            line,
            Text('${s.issuesEvaluated} : ${receipt.green + receipt.yellow + receipt.red + receipt.notApplicable}',
                style: mono),
            _row(JaColors.green, s.greenSatisfied, receipt.green),
            _row(JaColors.yellow, s.yellowIncomplete, receipt.yellow),
            _row(JaColors.red, s.redSevere, receipt.red),
            _row(JaColors.grey, s.notApplicableShort, receipt.notApplicable),
            line,
            Text(s.citizenPriorities, style: mono.copyWith(fontWeight: FontWeight.w700)),
            for (final (i, id) in receipt.priorityQuestionIds.indexed)
              Text('${i + 1}. ${state.question(id).short(hi)}', style: mono),
            if (receipt.priorityQuestionIds.isEmpty) const Text('—', style: mono),
            line,
            Text('${s.receiptId} : ${receipt.receiptNo}', style: mono.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(receipt.locationStatus == 'INSIDE_WARD' ? Icons.verified : Icons.wrong_location,
                  size: 16,
                  color: receipt.locationStatus == 'INSIDE_WARD' ? JaColors.green : JaColors.yellow),
              const SizedBox(width: 6),
              Text(
                switch (receipt.locationStatus) {
                  'INSIDE_WARD' => s.loggedInsideWard,
                  'OUTSIDE_WARD' => s.loggedOutsideWard,
                  _ => s.noLocationCaptured,
                },
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Text(s.receiptPromise, textAlign: TextAlign.center, style: const TextStyle(color: JaColors.textSecondary)),
        if (showWhatsapp) ...[
          const SizedBox(height: 20),
          Text(s.whatsappPreview, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDCF8C6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Text(s.whatsappMessage(name, ward.label(hi), firstRed), style: const TextStyle(height: 1.4)),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(s.done)),
      ]),
    );
  }

  Widget _row(Color color, String label, int value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'monospace'))),
          Text('[ $value ]', style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
        ]),
      );
}
