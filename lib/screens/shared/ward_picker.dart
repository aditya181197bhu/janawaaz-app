import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/app_state.dart';

/// Grid of big ward-number buttons with the locality under each number.
class WardNumberGrid extends StatelessWidget {
  const WardNumberGrid({super.key, required this.selected, required this.onSelected});

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.82,
      children: [
        for (final w in state.wards)
          Material(
            color: w.id == selected ? JaColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelected(w.id),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: w.id == selected ? JaColors.primary : JaColors.divider),
                ),
                padding: const EdgeInsets.all(4),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${w.id}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: w.id == selected ? Colors.white : JaColors.navy)),
                  Text(w.locality(state.hindi),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10, color: w.id == selected ? Colors.white70 : JaColors.textSecondary)),
                ]),
              ),
            ),
          ),
      ],
    );
  }
}

Future<int?> pickWard(BuildContext context, int? current) {
  final s = context.read<AppState>().s;
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.selectYourWard, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        WardNumberGrid(selected: current, onSelected: (id) => Navigator.pop(ctx, id)),
      ]),
    ),
  );
}

/// "Ward 3 · Ghantaghar  [change]" header used above ward views.
class WardHeader extends StatelessWidget {
  const WardHeader({super.key, required this.wardId, required this.onChange});

  final int wardId;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ward = state.ward(wardId);
    return Material(
      color: JaColors.sky,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await pickWard(context, wardId);
          if (picked != null) onChange(picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            const Icon(Icons.location_on, color: JaColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(ward.label(state.hindi),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: JaColors.navy)),
            ),
            const Icon(Icons.swap_horiz, color: JaColors.primary),
          ]),
        ),
      ),
    );
  }
}
