import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/labels.dart';
import '../../models/survey.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../widgets/common.dart';
import 'receipt_screen.dart';

class PrioritiesScreen extends StatefulWidget {
  const PrioritiesScreen({super.key, required this.draft});

  final SurveyDraft draft;

  @override
  State<PrioritiesScreen> createState() => _PrioritiesScreenState();
}

class _PrioritiesScreenState extends State<PrioritiesScreen> {
  bool _submitting = false;

  /// Red issues first, then Yellow: the ones worth ranking.
  List<int> get _candidates {
    final answers = widget.draft.answers;
    int weight(String r) => r == 'RED' ? 0 : 1;
    return answers.entries
        .where((e) => e.value.rating == 'RED' || e.value.rating == 'YELLOW')
        .map((e) => e.key)
        .toList()
      ..sort((a, b) {
        final c = weight(answers[a]!.rating).compareTo(weight(answers[b]!.rating));
        return c != 0 ? c : a.compareTo(b);
      });
  }

  void _toggle(int id) {
    final p = widget.draft.priorities;
    setState(() {
      if (p.contains(id)) {
        p.remove(id);
      } else if (p.length < 3) {
        p.add(id);
      }
    });
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    setState(() => _submitting = true);
    LocationReading? location;
    try {
      location = await LocationService.read(ward: state.ward(widget.draft.wardId), demo: state.demoLocation);
    } on LocationException {
      // Submit without GPS; the backend records "location not captured" and the admin sees it.
    }
    try {
      final receipt = await ApiService.instance.submitSurvey(widget.draft.toJson(
        volunteerId: state.volunteerId,
        latitude: location?.lat,
        longitude: location?.lng,
        accuracy: location?.accuracy,
      ));
      if (!mounted) return;
      state.dataChanged();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => ReceiptScreen(receipt: receipt, draft: widget.draft)),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final candidates = _candidates;
    final chosen = widget.draft.priorities;
    return Scaffold(
      appBar: AppBar(title: Text(s.topPriorities)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(s.topPrioritiesHint, style: const TextStyle(color: JaColors.textSecondary, height: 1.4)),
        const SizedBox(height: 14),
        if (candidates.isEmpty)
          Text(s.noIssuesToRank, style: const TextStyle(fontWeight: FontWeight.w600))
        else
          for (final id in candidates)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: chosen.contains(id) ? JaColors.sky : Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _toggle(id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: chosen.contains(id) ? JaColors.primary : JaColors.divider),
                    ),
                    child: Row(children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: Labels.ratingColor(widget.draft.answers[id]!.rating), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(state.question(id).short(state.hindi),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      if (chosen.contains(id))
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: JaColors.primary,
                          child: Text('${chosen.indexOf(id) + 1}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                    ]),
                  ),
                ),
              ),
            ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: JaColors.saffron),
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox.square(
                  dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send),
          label: Text(_submitting ? s.submitting : s.submitSurvey),
        ),
      ]),
    );
  }
}
