import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/stats.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';
import '../shared/ward_report_view.dart';
import 'admin_ward_screen.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    return AsyncView<AdminOverview>(
      key: ValueKey('overview-${state.dataVersion}'),
      load: ApiService.instance.adminOverview,
      builder: (context, o, reload) => RefreshIndicator(
        onRefresh: reload,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          SectionCard(
            title: s.householdsSurveyed,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${o.householdsSurveyed}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: JaColors.navy, height: 1)),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(s.ofTarget(o.targetHouseholds), style: const TextStyle(color: JaColors.textSecondary)),
                ),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: o.targetHouseholds == 0 ? 0 : o.householdsSurveyed / o.targetHouseholds,
                  minHeight: 10,
                  backgroundColor: JaColors.divider,
                ),
              ),
              const SizedBox(height: 10),
              Text('${s.today}: ${s.todayActivity(o.surveysToday, o.ticketsToday)}',
                  style: const TextStyle(color: JaColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.9,
            children: [
              StatTile(
                  value: '${o.tickets.open}', label: s.openComplaints, color: JaColors.red, icon: Icons.pending_actions),
              StatTile(
                  value: '${o.tickets.resolved}/${o.tickets.total}',
                  label: s.completed,
                  color: JaColors.green,
                  icon: Icons.task_alt),
              StatTile(
                  value: o.avgResolutionDays?.toStringAsFixed(1) ?? '—',
                  label: s.avgDaysToResolve,
                  color: JaColors.primary,
                  icon: Icons.timer_outlined),
              StatTile(
                  value: '${o.flaggedSurveys}',
                  label: s.flaggedSurveys,
                  color: JaColors.yellow,
                  icon: Icons.flag_outlined),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: s.topSeriousIssues,
            child: Column(children: [for (final i in o.topRedIssues) IssueRow(stat: i)]),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: s.wardsTitle,
            trailing: Text(s.volunteersCount(o.volunteers),
                style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(s.tapWardForDetail, style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
              const SizedBox(height: 8),
              for (final w in o.wards) _WardRow(row: w),
            ]),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _WardRow extends StatelessWidget {
  const _WardRow({required this.row});

  final AdminWardRow row;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final w = row;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminWardScreen(wardId: w.wardId))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: JaColors.sky,
            child: Text('${w.wardId}', style: const TextStyle(fontWeight: FontWeight.w800, color: JaColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(w.locality(state.hindi), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text(s.surveyedOf(w.surveyed, w.target),
                    style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
              ]),
              const SizedBox(height: 6),
              ProgressSplitBar(
                  resolved: w.tickets.resolved, inProgress: w.tickets.inProgress, reported: w.tickets.reported),
              const SizedBox(height: 4),
              Text(
                s.wardRowLine(w.tickets.total, w.tickets.open, w.flaggedSurveys),
                style: const TextStyle(fontSize: 12, color: JaColors.textSecondary),
              ),
            ]),
          ),
          const Icon(Icons.chevron_right, color: JaColors.grey),
        ]),
      ),
    );
  }
}
