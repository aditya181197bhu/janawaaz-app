import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/survey.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import 'survey_questions_screen.dart';

class HouseholdFormScreen extends StatefulWidget {
  const HouseholdFormScreen({super.key, required this.draft});

  final SurveyDraft draft;

  @override
  State<HouseholdFormScreen> createState() => _HouseholdFormScreenState();
}

class _HouseholdFormScreenState extends State<HouseholdFormScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _mobile = TextEditingController();
  final _occupation = TextEditingController();
  bool _consent = false;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _mobile.dispose();
    _occupation.dispose();
    super.dispose();
  }

  void _continue() {
    final s = context.read<AppState>().s;
    if (!_consent) {
      showMessage(context, s.consentNeeded, error: true);
      return;
    }
    final d = widget.draft
      ..respondentName = _name.text.trim()
      ..respondentAge = int.tryParse(_age.text.trim())
      ..mobile = _mobile.text.trim()
      ..occupation = _occupation.text.trim();
    if (d.mobile!.isEmpty) d.whatsappOptIn = false;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SurveyQuestionsScreen(draft: d)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final d = widget.draft;
    return Scaffold(
      appBar: AppBar(title: Text(state.ward(d.wardId).label(state.hindi))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SectionCard(
          title: s.household,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: s.respondentName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: s.age),
            ),
            const SizedBox(height: 12),
            Text(s.gender, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'FEMALE', label: Text(s.female)),
                ButtonSegment(value: 'MALE', label: Text(s.male)),
                ButtonSegment(value: 'OTHER', label: Text(s.otherGender)),
              ],
              selected: {d.respondentGender},
              onSelectionChanged: (v) => setState(() => d.respondentGender = v.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(labelText: s.mobileOptional, counterText: ''),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _occupation,
              decoration: InputDecoration(labelText: s.occupation, hintText: s.occupationHint),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        _ConsentTile(
          value: _consent,
          text: s.consentRequired,
          onChanged: (v) => setState(() => _consent = v),
        ),
        const SizedBox(height: 8),
        _ConsentTile(
          value: d.whatsappOptIn,
          text: s.consentWhatsapp,
          onChanged: (v) => setState(() => d.whatsappOptIn = v),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: JaColors.saffron),
          onPressed: _continue,
          child: Text(s.startQuestions),
        ),
      ]),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({required this.value, required this.text, required this.onChanged});

  final bool value;
  final String text;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(text, style: const TextStyle(fontSize: 14, height: 1.35)),
      ),
    );
  }
}
