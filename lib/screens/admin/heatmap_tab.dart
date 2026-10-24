import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/stats.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';

/// Survey heatmap: one row per issue, one column per ward, cell = % rating it Red.
class HeatmapTab extends StatelessWidget {
  const HeatmapTab({super.key});

  static const double _labelWidth = 104;
  static const double _cell = 27;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final hi = state.hindi;
    return AsyncView<HeatmapData>(
      key: ValueKey('heatmap-${state.dataVersion}'),
      load: ApiService.instance.heatmap,
      builder: (context, h, _) {
        int? value(int row, int col) => (h.rows[col]['redPct'] as List)[row] as int?;
        return ListView(padding: const EdgeInsets.all(16), children: [
          Text(s.issueHeatmap, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(s.heatmapHint, style: const TextStyle(color: JaColors.textSecondary)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const SizedBox(width: _labelWidth),
                for (final r in h.rows)
                  SizedBox(
                    width: _cell,
                    child: Text('${r['wardId']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: JaColors.navy)),
                  ),
              ]),
              const SizedBox(height: 4),
              for (var i = 0; i < h.columns.length; i++)
                Row(children: [
                  SizedBox(
                    width: _labelWidth,
                    child: Text(h.columns[i][hi ? 'shortHi' : 'shortEn'],
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                  ),
                  for (var c = 0; c < h.rows.length; c++) _HeatCell(value: value(i, c)),
                ]),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            for (final v in [0, 20, 40, 60, 80])
              Expanded(
                child: Column(children: [
                  Container(height: 10, color: _HeatCell.colorFor(v)),
                  Text('$v%', style: const TextStyle(fontSize: 10, color: JaColors.textSecondary)),
                ]),
              ),
          ]),
          const SizedBox(height: 24),
        ]);
      },
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.value});

  final int? value;

  static Color colorFor(int v) => Color.lerp(const Color(0xFFFDF0EC), JaColors.red, (v / 70).clamp(0, 1))!;

  @override
  Widget build(BuildContext context) {
    final v = value;
    return Container(
      width: HeatmapTab._cell - 2,
      height: 26,
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: v == null ? JaColors.background : colorFor(v),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(v == null ? '·' : '$v',
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: (v ?? 0) > 45 ? Colors.white : JaColors.textPrimary)),
    );
  }
}
