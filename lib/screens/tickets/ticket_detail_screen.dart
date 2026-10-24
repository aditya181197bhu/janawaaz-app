import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../l10n/labels.dart';
import '../../models/ticket.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';
import '../../widgets/ward_map.dart';

/// Complaint detail with status updates and editing (volunteer and admin).
class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketNo});

  final String ticketNo;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  int _version = 0;

  void _changed() {
    setState(() => _version++);
    context.read<AppState>().dataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ticketNo)),
      body: AsyncView<Ticket>(
        key: ValueKey(_version),
        load: () => ApiService.instance.ticket(widget.ticketNo),
        builder: (context, t, _) => _TicketBody(ticket: t, onChanged: _changed),
      ),
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({required this.ticket, required this.onChanged});

  final Ticket ticket;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final hi = state.hindi;
    final t = ticket;
    final next = t.nextStatus;
    const gap = SizedBox(height: 12);

    return ListView(padding: const EdgeInsets.all(16), children: [
      SectionCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Labels.categoryIcon(t.category), color: JaColors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(Labels.category(t.category, hi),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            StatusChip(status: t.status),
          ]),
          const SizedBox(height: 8),
          SelectableText(t.ticketNo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: JaColors.primary)),
          const SizedBox(height: 2),
          Text('${state.ward(t.wardId).label(hi)} · ${formatDate(t.createdAt, hi)}',
              style: const TextStyle(color: JaColors.textSecondary)),
        ]),
      ),
      gap,
      if (t.photoUrl != null) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(ApiConfig.fileUrl(t.photoUrl!), height: 200, fit: BoxFit.cover),
        ),
        gap,
      ],
      SectionCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (t.description != null) _Field(label: s.description, value: t.description!),
          if (t.landmark != null) _Field(label: s.landmark, value: t.landmark!),
          if (t.residentName != null || t.residentMobileMasked != null)
            _Field(
              label: s.resident,
              value: [t.residentName, t.residentMobileMasked].whereType<String>().join(' · '),
            ),
          Row(children: [
            Icon(
              t.locationStatus == 'INSIDE_WARD' ? Icons.verified : Icons.wrong_location,
              size: 18,
              color: t.locationStatus == 'INSIDE_WARD' ? JaColors.green : JaColors.red,
            ),
            const SizedBox(width: 6),
            Text(switch (t.locationStatus) {
              'INSIDE_WARD' => s.loggedInsideWard,
              'OUTSIDE_WARD' => s.loggedOutsideWard,
              _ => s.noLocationCaptured,
            }),
          ]),
        ]),
      ),
      if (t.latitude != null) ...[
        gap,
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 170,
            child: AbsorbPointer(
              child: JaMap(
                center: LatLng(t.latitude!, t.longitude!),
                zoom: 15.5,
                interactive: false,
                markers: [
                  Marker(
                    point: LatLng(t.latitude!, t.longitude!),
                    width: 36,
                    height: 36,
                    child: Icon(Icons.location_pin, color: Labels.statusColor(t.status), size: 36),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      gap,
      SectionCard(
        title: s.history,
        child: Column(children: [
          for (final u in t.updates)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: Labels.statusColor(u.status), shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(Labels.status(u.status, hi), style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (u.note != null) Text(u.note!),
                    Text(formatDate(u.createdAt, hi),
                        style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
                  ]),
                ),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      if (next != null)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Labels.statusColor(next)),
          onPressed: () => _advance(context, next),
          icon: Icon(next == 'RESOLVED' ? Icons.task_alt : Icons.construction),
          label: Text(next == 'RESOLVED' ? s.markCompleted : s.markInProgress),
        ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.edit_outlined),
        label: Text(s.edit),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Future<void> _advance(BuildContext context, String next) async {
    final s = context.read<AppState>().s;
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(next == 'RESOLVED' ? s.markCompleted : s.markInProgress),
        content: TextField(controller: note, maxLines: 3, decoration: InputDecoration(labelText: s.noteOptional)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.save)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiService.instance.updateTicketStatus(ticket.ticketNo, next, note: note.text.trim());
      if (context.mounted) showMessage(context, s.statusUpdated);
      onChanged();
    } catch (e) {
      if (context.mounted) showMessage(context, e.toString(), error: true);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditSheet(ticket: ticket),
    );
    if (saved == true) onChanged();
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15)),
        ]),
      );
}

class _EditSheet extends StatefulWidget {
  const _EditSheet({required this.ticket});

  final Ticket ticket;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late String _category = widget.ticket.category;
  late final _description = TextEditingController(text: widget.ticket.description ?? '');
  late final _landmark = TextEditingController(text: widget.ticket.landmark ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _description.dispose();
    _landmark.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = context.read<AppState>().s;
    setState(() => _saving = true);
    try {
      await ApiService.instance.editTicket(widget.ticket.ticketNo,
          category: _category, description: _description.text, landmark: _landmark.text);
      if (!mounted) return;
      showMessage(context, s.saved);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(s.editComplaint, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: InputDecoration(labelText: s.problemType),
          items: [
            for (final c in Labels.categories)
              DropdownMenuItem(value: c, child: Text(Labels.category(c, state.hindi))),
          ],
          onChanged: (v) => setState(() => _category = v ?? _category),
        ),
        const SizedBox(height: 12),
        TextField(controller: _description, maxLines: 3, decoration: InputDecoration(labelText: s.description)),
        const SizedBox(height: 12),
        TextField(controller: _landmark, decoration: InputDecoration(labelText: s.landmark)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _saving ? null : _save, child: Text(s.save)),
      ]),
    );
  }
}
