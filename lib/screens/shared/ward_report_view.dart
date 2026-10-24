import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/labels.dart';
import '../../models/stats.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';
import '../../widgets/ward_map.dart';

/// Loads and shows one ward's public picture. Used by Janta and Volunteer.
class WardReportView extends StatelessWidget {
  const WardReportView({super.key, required this.wardId, this.header});

  final int wardId;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final version = context.watch<AppState>().dataVersion;
    return AsyncView<WardReport>(
      key: ValueKey('ward-$wardId-$version'),
      load: () => ApiService.instance.wardReport(wardId),
      builder: (context, report, reload) => RefreshIndicator(
        onRefresh: reload,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          if (header != null) ...[header!, const SizedBox(height: 12)],
          ...wardReportSections(context, report),
        ]),
      ),
    );
  }
}

/// The ward sections as a list, so admin screens can add their own around them.
List<Widget> wardReportSections(BuildContext context, WardReport r) {
  final state = context.watch<AppState>();
  final s = state.s;
  final hindi = state.hindi;
  const gap = SizedBox(height: 12);
  return [
    _WardMapCard(report: r),
    gap,
    SectionCard(
      title: s.complaints,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${r.tickets.total}',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: JaColors.navy, height: 1)),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(s.total, style: const TextStyle(color: JaColors.textSecondary, fontSize: 16)),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(s.percentCompleted(r.tickets.completedPct),
                style: const TextStyle(fontWeight: FontWeight.w700, color: JaColors.green)),
          ),
        ]),
        const SizedBox(height: 12),
        ProgressSplitBar(
            resolved: r.tickets.resolved, inProgress: r.tickets.inProgress, reported: r.tickets.reported),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: StatTile(value: '${r.tickets.reported}', label: s.notStarted, color: JaColors.red)),
          const SizedBox(width: 8),
          Expanded(child: StatTile(value: '${r.tickets.inProgress}', label: s.inProgress, color: JaColors.yellow)),
          const SizedBox(width: 8),
          Expanded(child: StatTile(value: '${r.tickets.resolved}', label: s.completed, color: JaColors.green)),
        ]),
      ]),
    ),
    gap,
    if (r.byCategory.isNotEmpty) ...[
      SectionCard(
        title: s.byProblemType,
        child: Column(children: [
          for (final c in r.byCategory)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                Icon(Labels.categoryIcon(c.category), color: JaColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Text(Labels.category(c.category, hindi),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Text(s.pendingDone(c.pending, c.resolved),
                          style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
                    ]),
                    const SizedBox(height: 5),
                    RagBar(green: c.resolved, yellow: c.inProgress, red: c.reported, height: 6),
                  ]),
                ),
              ]),
            ),
        ]),
      ),
      gap,
    ],
    SectionCard(
      title: s.whatHouseholdsSaid,
      child: r.enoughSurveyData
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(s.householdsShared(r.householdsSurveyed), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              for (final p in r.topProblems) IssueRow(stat: p),
              const SizedBox(height: 4),
              Legend(items: [(JaColors.green, s.good), (JaColors.yellow, s.needsAttention), (JaColors.red, s.serious)]),
            ])
          : Text(s.notEnoughSurveys(r.householdsSurveyed, r.minHouseholds),
              style: const TextStyle(color: JaColors.textSecondary)),
    ),
    gap,
    Row(children: [
      const Icon(Icons.lock_outline, size: 16, color: JaColors.textSecondary),
      const SizedBox(width: 6),
      Expanded(child: Text(s.privacyNote, style: const TextStyle(fontSize: 12, color: JaColors.textSecondary))),
    ]),
    const SizedBox(height: 24),
  ];
}

class IssueRow extends StatelessWidget {
  const IssueRow({super.key, required this.stat});

  final IssueStat stat;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(stat.short(state.hindi), style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(state.s.seriousPct(stat.redPct),
              style: const TextStyle(fontWeight: FontWeight.w700, color: JaColors.red, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        RagBar(green: stat.greenPct, yellow: stat.yellowPct, red: stat.redPct),
      ]),
    );
  }
}

class _WardMapCard extends StatelessWidget {
  const _WardMapCard({required this.report});

  final WardReport report;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final title = state.hindi
        ? 'वार्ड ${report.wardId} · ${report.localityHi}'
        : 'Ward ${report.wardId} · ${report.localityEn}';
    final legend = Legend(items: [
      (JaColors.red, s.notStarted),
      (JaColors.yellow, s.inProgress),
      (JaColors.green, s.completed),
    ]);
    JaMap mapWidget({required bool interactive}) => JaMap(
          center: LatLng(report.centerLat, report.centerLng),
          zoom: report.radiusMeters > 1500 ? 13.6 : 14.4,
          circles: WardComplaintsLayers.circles(report),
          markers: WardComplaintsLayers.markers(report),
          interactive: interactive,
        );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text(s.complaintMap,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: JaColors.navy)),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => FullScreenMap(title: title, map: mapWidget(interactive: true), footer: legend),
          )),
          child: Stack(children: [
            SizedBox(height: 210, child: AbsorbPointer(child: mapWidget(interactive: false))),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.open_in_full, size: 14, color: JaColors.primary),
                  const SizedBox(width: 4),
                  Text(s.tapToExpand, style: const TextStyle(fontSize: 11, color: JaColors.primary)),
                ]),
              ),
            ),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(12), child: legend),
      ]),
    );
  }
}
