import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/stats.dart';
import '../../models/ticket.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';
import '../shared/ward_report_view.dart';
import '../tickets/ticket_browser.dart';

/// Everything about one ward for the leader: complaints, survey results, and how
/// each volunteer there is engaging with residents.
class AdminWardScreen extends StatelessWidget {
  const AdminWardScreen({super.key, required this.wardId});

  final int wardId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    return Scaffold(
      appBar: AppBar(title: Text(state.ward(wardId).label(state.hindi))),
      body: AsyncView<Map<String, dynamic>>(
        key: ValueKey('admin-ward-$wardId-${state.dataVersion}'),
        load: () => ApiService.instance.adminWard(wardId),
        builder: (context, j, reload) {
          final report = WardReport.fromJson(j['report']);
          final volunteers =
              (j['volunteers'] as List).map((v) => VolunteerActivity.fromJson(v)).toList();
          final recent = (j['recentTickets'] as List).map((t) => Ticket.fromJson(t)).toList();
          final sections = wardReportSections(context, report);
          sections.insertAll(4, [
            SectionCard(
              title: s.volunteerActivity,
              child: Column(children: [
                for (final v in volunteers)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      CircleAvatar(
                        backgroundColor: JaColors.sky,
                        child: Text(v.name[0],
                            style: const TextStyle(fontWeight: FontWeight.w800, color: JaColors.primary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${v.name} · ${v.code}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(s.activityLine(v.surveys, v.tickets, v.flaggedSurveys),
                              style: const TextStyle(fontSize: 13)),
                          Text(
                            v.lastActiveAt == null
                                ? s.noActivityYet
                                : s.lastActive(formatDate(v.lastActiveAt!, state.hindi)),
                            style: const TextStyle(fontSize: 12, color: JaColors.textSecondary),
                          ),
                        ]),
                      ),
                      if (v.flaggedSurveys > 0) const Icon(Icons.flag, color: JaColors.yellow, size: 20),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: s.recentComplaints,
              child: recent.isEmpty
                  ? Text(s.noComplaintsHere, style: const TextStyle(color: JaColors.textSecondary))
                  : Column(children: [
                      for (final t in recent)
                        Padding(padding: const EdgeInsets.only(bottom: 8), child: TicketCard(ticket: t)),
                    ]),
            ),
            const SizedBox(height: 12),
          ]);
          return RefreshIndicator(
            onRefresh: reload,
            child: ListView(padding: const EdgeInsets.all(16), children: sections),
          );
        },
      ),
    );
  }
}
