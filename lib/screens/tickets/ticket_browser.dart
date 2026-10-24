import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/labels.dart';
import '../../models/ticket.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';
import 'new_ticket_screen.dart';
import 'ticket_detail_screen.dart';

/// Complaint list with number search, ward and status filters. Used by the
/// volunteer (can also create) and the admin. Never shown to Janta.
class TicketBrowser extends StatefulWidget {
  const TicketBrowser({super.key, this.initialWardId, this.canCreate = false});

  final int? initialWardId;
  final bool canCreate;

  @override
  State<TicketBrowser> createState() => _TicketBrowserState();
}

class _TicketBrowserState extends State<TicketBrowser> {
  late int? _wardId = widget.initialWardId;
  String? _status;
  final _search = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _findByNumber() async {
    final number = _search.text.trim();
    if (number.isEmpty) return;
    setState(() => _searching = true);
    try {
      final ticket = await ApiService.instance.ticket(number);
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      openTicket(context, ticket.ticketNo);
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final statusFilters = <(String?, String)>[
      (null, s.all),
      ('REPORTED', s.notStarted),
      ('IN_PROGRESS', s.inProgress),
      ('RESOLVED', s.completed),
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: widget.canCreate
          ? FloatingActionButton.extended(
              backgroundColor: JaColors.saffron,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => NewTicketScreen(wardId: _wardId ?? state.dutyWardId ?? 1))),
              icon: const Icon(Icons.add),
              label: Text(s.newComplaint),
            )
          : null,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(children: [
            TextField(
              controller: _search,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _findByNumber(),
              decoration: InputDecoration(
                hintText: 'JA-W03-C0012',
                labelText: s.searchByNumber,
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                    : IconButton(icon: const Icon(Icons.search), onPressed: _findByNumber),
              ),
            ),
            const SizedBox(height: 10),
            WardDropdown(value: _wardId, allowAll: true, onChanged: (v) => setState(() => _wardId = v)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final (value, label) in statusFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _status == value,
                      onSelected: (_) => setState(() => _status = value),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
        Expanded(
          child: AsyncView<List<Ticket>>(
            key: ValueKey('tickets-$_wardId-$_status-${state.dataVersion}'),
            load: () => ApiService.instance.tickets(wardId: _wardId, status: _status),
            builder: (context, tickets, reload) => RefreshIndicator(
              onRefresh: reload,
              child: tickets.isEmpty
                  ? ListView(children: [
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(s.noComplaintsHere,
                            textAlign: TextAlign.center, style: const TextStyle(color: JaColors.textSecondary)),
                      ),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: tickets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => TicketCard(ticket: tickets[i]),
                    ),
            ),
          ),
        ),
      ]),
    );
  }
}

void openTicket(BuildContext context, String ticketNo) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TicketDetailScreen(ticketNo: ticketNo)));

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hi = state.hindi;
    final t = ticket;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openTicket(context, t.ticketNo),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: JaColors.sky, borderRadius: BorderRadius.circular(12)),
              child: Icon(Labels.categoryIcon(t.category), color: JaColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(Labels.category(t.category, hi),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  StatusChip(status: t.status),
                ]),
                const SizedBox(height: 4),
                Text(t.ticketNo, style: const TextStyle(fontWeight: FontWeight.w600, color: JaColors.primary)),
                const SizedBox(height: 2),
                Text(
                  [state.s.ward(t.wardId), if (t.landmark != null) t.landmark!, state.s.daysAgo(daysSince(t.createdAt))]
                      .join(' · '),
                  style: const TextStyle(fontSize: 12, color: JaColors.textSecondary),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
