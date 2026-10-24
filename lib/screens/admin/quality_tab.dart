import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/stats.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';

/// Surveys that may need a second look: filed outside the ward (GPS) or too fast.
class QualityTab extends StatelessWidget {
  const QualityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    return AsyncView<QualityData>(
      key: ValueKey('quality-${state.dataVersion}'),
      load: ApiService.instance.quality,
      builder: (context, q, reload) => RefreshIndicator(
        onRefresh: reload,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text(s.qualityHint, style: const TextStyle(color: JaColors.textSecondary, height: 1.4)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: StatTile(
                  value: '${q.outsideWard}', label: s.filedOutsideWard, color: JaColors.red, icon: Icons.wrong_location),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                  value: '${q.tooFast}',
                  label: s.finishedTooFast(q.minSecondsPerSurvey),
                  color: JaColors.yellow,
                  icon: Icons.timer_off_outlined),
            ),
          ]),
          const SizedBox(height: 12),
          if (q.flagged.isEmpty) Text(s.nothingFlagged),
          for (final f in q.flagged) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(f.receiptNo, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text(s.ward(f.wardId), style: const TextStyle(color: JaColors.textSecondary)),
                  ]),
                  const SizedBox(height: 4),
                  Text('${f.volunteerName} · ${f.volunteerCode} · ${formatDate(f.submittedAt, state.hindi)}',
                      style: const TextStyle(fontSize: 13, color: JaColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    if (f.outsideWard)
                      _Reason(
                        icon: Icons.wrong_location,
                        color: JaColors.red,
                        text: f.distanceFromWardMeters == null
                            ? s.filedOutsideWard
                            : s.metersFromCentre(f.distanceFromWardMeters!),
                      ),
                    if (f.tooFast)
                      _Reason(icon: Icons.timer_off_outlined, color: JaColors.yellow, text: s.minutesTaken(f.durationSeconds)),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _Reason extends StatelessWidget {
  const _Reason({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color.lerp(color, Colors.black, .3))),
        ]),
      );
}
