import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/meta.dart';
import '../../models/survey.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';
import '../../widgets/gps_status.dart';
import '../shared/ward_picker.dart';
import '../shared/ward_report_view.dart';
import '../survey/household_form_screen.dart';
import '../tickets/new_ticket_screen.dart';
import '../tickets/ticket_browser.dart';

/// Volunteer: surveys, complaint creation/search/editing, and the ward view.
/// No constituency-wide insights here; those are on the Admin side.
class VolunteerHome extends StatefulWidget {
  const VolunteerHome({super.key});

  @override
  State<VolunteerHome> createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<VolunteerHome> {
  int _tab = 0;

  Future<Volunteer> _load(AppState state) async {
    await Future.wait([state.ensureWards(), state.ensureQuestions()]);
    return ApiService.instance.volunteer(state.volunteerId);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.profileVolunteer), actions: appBarActions(context)),
      body: AsyncView<Volunteer>(
        load: () => _load(state),
        builder: (context, volunteer, reload) {
          final wardId = state.dutyWardId ?? volunteer.wardId;
          return IndexedStack(index: _tab, children: [
            AsyncView<Volunteer>(
              key: ValueKey('home-${state.dataVersion}'),
              load: () => ApiService.instance.volunteer(state.volunteerId),
              builder: (context, fresh, _) => _HomeTab(volunteer: fresh, wardId: wardId),
            ),
            TicketBrowser(initialWardId: wardId, canCreate: true),
            WardReportView(wardId: wardId, header: WardHeader(wardId: wardId, onChange: state.setDutyWard)),
          ]);
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: s.home),
          NavigationDestination(icon: const Icon(Icons.report_problem_outlined), label: s.complaints),
          NavigationDestination(icon: const Icon(Icons.location_city_outlined), label: s.myWard),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.volunteer, required this.wardId});

  final Volunteer volunteer;
  final int wardId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final ward = state.ward(wardId);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: JaColors.sky,
          child: Text(volunteer.name[0],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: JaColors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(volunteer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(volunteer.code, style: const TextStyle(color: JaColors.textSecondary)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: JaColors.sky, borderRadius: BorderRadius.circular(12)),
          child: Text(s.surveysToday(volunteer.surveysToday),
              style: const TextStyle(fontWeight: FontWeight.w700, color: JaColors.primary)),
        ),
      ]),
      const SizedBox(height: 16),
      SectionCard(
        title: s.todaysDuty,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          WardHeader(wardId: wardId, onChange: state.setDutyWard),
          const SizedBox(height: 10),
          GpsStatusCard(ward: ward),
        ]),
      ),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: JaColors.saffron, minimumSize: const Size.fromHeight(58)),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => HouseholdFormScreen(draft: SurveyDraft(wardId: wardId))),
        ),
        icon: const Icon(Icons.assignment_outlined),
        label: Text(s.startSurvey),
      ),
      const SizedBox(height: 6),
      Text(s.startSurveyHint,
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
      const SizedBox(height: 14),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewTicketScreen(wardId: wardId))),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(s.newComplaint),
      ),
      const SizedBox(height: 6),
      Text(s.newComplaintHint,
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
      const SizedBox(height: 20),
      SectionCard(
        title: s.myRecentSurveys,
        child: AsyncView<List<SurveySummary>>(
          load: () => ApiService.instance.mySurveys(volunteer.id),
          builder: (context, surveys, _) => surveys.isEmpty
              ? Text(s.noSurveysYet, style: const TextStyle(color: JaColors.textSecondary))
              : Column(children: [for (final sv in surveys) _SurveyRow(summary: sv)]),
        ),
      ),
    ]);
  }
}

class _SurveyRow extends StatelessWidget {
  const _SurveyRow({required this.summary});

  final SurveySummary summary;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final outside = summary.locationStatus == 'OUTSIDE_WARD';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(summary.respondentName ?? summary.receiptNo, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('${summary.receiptNo} · ${formatDate(summary.submittedAt, state.hindi)}',
                style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
            const SizedBox(height: 6),
            RagBar(green: summary.green, yellow: summary.yellow, red: summary.red, height: 6),
          ]),
        ),
        const SizedBox(width: 10),
        Icon(outside ? Icons.wrong_location : Icons.verified,
            color: outside ? JaColors.red : JaColors.green, size: 20),
      ]),
    );
  }
}
