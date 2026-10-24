import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../shared/ward_picker.dart';
import '../shared/ward_report_view.dart';
import 'manifesto_screen.dart';

/// Janta (public): pick a ward to see its complaints, and read the manifesto.
/// No complaint search and no complaint creation on this side.
class JantaHome extends StatefulWidget {
  const JantaHome({super.key});

  @override
  State<JantaHome> createState() => _JantaHomeState();
}

class _JantaHomeState extends State<JantaHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    return Scaffold(
      appBar: AppBar(title: Text(s.appName), actions: appBarActions(context)),
      body: IndexedStack(index: _tab, children: const [_MyWardTab(), ManifestoView()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.location_city_outlined), label: s.myWard),
          NavigationDestination(icon: const Icon(Icons.menu_book_outlined), label: s.manifesto),
        ],
      ),
    );
  }
}

class _MyWardTab extends StatelessWidget {
  const _MyWardTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return AsyncView(
      load: state.ensureWards,
      builder: (context, _, _) {
        final wardId = state.jantaWardId;
        if (wardId == null) {
          return ListView(padding: const EdgeInsets.all(20), children: [
            const Icon(Icons.location_city, size: 56, color: JaColors.primaryLight),
            const SizedBox(height: 12),
            Text(state.s.selectYourWard,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            WardNumberGrid(selected: null, onSelected: state.setJantaWard),
          ]);
        }
        return WardReportView(
          wardId: wardId,
          header: WardHeader(wardId: wardId, onChange: state.setJantaWard),
        );
      },
    );
  }
}
