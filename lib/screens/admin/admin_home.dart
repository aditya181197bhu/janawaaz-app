import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../tickets/ticket_browser.dart';
import 'admin_map_tab.dart';
import 'heatmap_tab.dart';
import 'overview_tab.dart';
import 'quality_tab.dart';

/// Leader / admin: all insights. Can also search and edit complaints.
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.profileAdmin), actions: appBarActions(context)),
      body: AsyncView(
        load: () => Future.wait([state.ensureWards(), state.ensureQuestions()]),
        builder: (context, _, _) => IndexedStack(index: _tab, children: const [
          OverviewTab(),
          AdminMapTab(),
          HeatmapTab(),
          TicketBrowser(),
          QualityTab(),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), label: s.overview),
          NavigationDestination(icon: const Icon(Icons.map_outlined), label: s.map),
          NavigationDestination(icon: const Icon(Icons.grid_on), label: s.issues),
          NavigationDestination(icon: const Icon(Icons.report_problem_outlined), label: s.complaints),
          NavigationDestination(icon: const Icon(Icons.fact_check_outlined), label: s.checks),
        ],
      ),
    );
  }
}
