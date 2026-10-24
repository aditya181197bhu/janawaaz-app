import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/meta.dart';
import '../../models/survey.dart';
import '../../providers/app_state.dart';
import '../../widgets/media_capture.dart';
import 'priorities_screen.dart';

/// One question per screen. Each answer has a distinct shape as well as a
/// colour (circle, triangle, square) so it works for colour-blind users and in sunlight.
class SurveyQuestionsScreen extends StatefulWidget {
  const SurveyQuestionsScreen({super.key, required this.draft});

  final SurveyDraft draft;

  @override
  State<SurveyQuestionsScreen> createState() => _SurveyQuestionsScreenState();
}

class _SurveyQuestionsScreenState extends State<SurveyQuestionsScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final hi = state.hindi;
    final questions = state.questions;
    final q = questions[_index];
    final answer = widget.draft.answers[q.id];
    final isLast = _index == questions.length - 1;

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index--);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(state.ward(widget.draft.wardId).label(hi))),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: Text(s.partLabel(q.part),
                      style: const TextStyle(color: JaColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
                Text('${_index + 1} / ${questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: JaColors.navy)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_index + 1) / questions.length,
                  minHeight: 6,
                  backgroundColor: JaColors.divider,
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(q.title(hi),
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: JaColors.navy, height: 1.25)),
              const SizedBox(height: 16),
              _OptionTile(
                rating: 'GREEN',
                title: s.good,
                description: q.green(hi),
                selected: answer?.rating == 'GREEN',
                onTap: () => _choose(q, 'GREEN'),
              ),
              _OptionTile(
                rating: 'YELLOW',
                title: s.needsAttention,
                description: q.yellow(hi),
                selected: answer?.rating == 'YELLOW',
                onTap: () => _choose(q, 'YELLOW'),
              ),
              _OptionTile(
                rating: 'RED',
                title: s.serious,
                description: q.red(hi),
                selected: answer?.rating == 'RED',
                onTap: () => _choose(q, 'RED'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ChoiceChip(
                  label: Text(s.notApplicable),
                  selected: answer?.rating == 'NA',
                  onSelected: (_) => _choose(q, 'NA'),
                ),
              ),
              if (answer != null && (answer.rating == 'YELLOW' || answer.rating == 'RED')) ...[
                const SizedBox(height: 16),
                Text(s.evidenceHint, style: const TextStyle(color: JaColors.textSecondary)),
                const SizedBox(height: 8),
                PhotoCaptureButton(
                  url: answer.photoUrl,
                  onChanged: (u) => setState(() => answer.photoUrl = u),
                ),
                const SizedBox(height: 8),
                VoiceNoteButton(
                  url: answer.voiceUrl,
                  onChanged: (u) => setState(() => answer.voiceUrl = u),
                ),
              ],
            ]),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _index == 0 ? Navigator.pop(context) : setState(() => _index--),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(s.back),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: answer == null
                        ? null
                        : () => isLast
                            ? Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => PrioritiesScreen(draft: widget.draft)))
                            : setState(() => _index++),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(s.next),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  void _choose(Question q, String rating) {
    setState(() {
      final existing = widget.draft.answers[q.id];
      if (existing == null) {
        widget.draft.answers[q.id] = AnswerDraft(rating);
      } else {
        existing.rating = rating;
        if (rating == 'GREEN' || rating == 'NA') {
          existing.photoUrl = null;
          existing.voiceUrl = null;
        }
      }
    });
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.rating,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String rating;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  Color get _color => switch (rating) {
        'GREEN' => JaColors.green,
        'YELLOW' => JaColors.yellow,
        _ => JaColors.red,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? _color.withValues(alpha: 0.12) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? _color : JaColors.divider, width: selected ? 2 : 1),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox.square(dimension: 26, child: CustomPaint(painter: _ShapePainter(rating, _color))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(description, style: const TextStyle(color: JaColors.textSecondary, height: 1.35)),
                ]),
              ),
              if (selected) Icon(Icons.check_circle, color: _color),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.rating, this.color);

  final String rating;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    switch (rating) {
      case 'GREEN':
        canvas.drawCircle(Offset(w / 2, w / 2), w / 2, paint);
      case 'YELLOW':
        canvas.drawPath(
            Path()
              ..moveTo(w / 2, 0)
              ..lineTo(w, w)
              ..lineTo(0, w)
              ..close(),
            paint);
      default:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, w - 2, w - 2), const Radius.circular(3)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) => old.rating != rating || old.color != color;
}
