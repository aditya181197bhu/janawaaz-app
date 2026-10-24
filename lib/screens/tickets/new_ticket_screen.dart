import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/labels.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../widgets/common.dart';
import '../../widgets/gps_status.dart';
import '../../widgets/media_capture.dart';
import '../shared/ward_picker.dart';

/// Volunteer-only. Several problem types can be ticked; each becomes its own complaint.
class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key, required this.wardId});

  final int wardId;

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  late int _wardId = widget.wardId;
  final _selected = <String>{};
  final _description = TextEditingController();
  final _landmark = TextEditingController();
  final _residentName = TextEditingController();
  final _residentMobile = TextEditingController();
  String? _photoUrl;
  LocationReading? _location;
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [_description, _landmark, _residentName, _residentMobile]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    final s = state.s;
    if (_selected.isEmpty) {
      showMessage(context, s.chooseProblemType, error: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final created = await ApiService.instance.createTickets({
        'volunteerId': state.volunteerId,
        'wardId': _wardId,
        'categories': Labels.categories.where(_selected.contains).toList(),
        'description': _description.text.trim(),
        'landmark': _landmark.text.trim(),
        'residentName': _residentName.text.trim(),
        'residentMobile': _residentMobile.text.trim(),
        'photoUrl': _photoUrl,
        'latitude': _location?.lat,
        'longitude': _location?.lng,
      });
      if (!mounted) return;
      state.dataChanged();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: JaColors.green, size: 40),
          title: Text(s.complaintsRegistered(created.length)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final t in created)
              ListTile(
                dense: true,
                leading: Icon(Labels.categoryIcon(t.category), color: JaColors.primary),
                title: SelectableText(t.ticketNo, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(Labels.category(t.category, state.hindi)),
              ),
            const SizedBox(height: 6),
            Text(s.shareNumberWithResident, style: const TextStyle(color: JaColors.textSecondary)),
          ]),
          actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(s.done))],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final hi = state.hindi;
    return Scaffold(
      appBar: AppBar(title: Text(s.newComplaint)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        WardHeader(wardId: _wardId, onChange: (id) => setState(() => _wardId = id)),
        const SizedBox(height: 14),
        SectionCard(
          title: s.whatIsTheProblem,
          trailing: _selected.isEmpty
              ? null
              : Text(s.selectedCount(_selected.length),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: JaColors.primary)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in Labels.categories)
                FilterChip(
                  avatar: Icon(Labels.categoryIcon(c), size: 18),
                  label: Text(Labels.category(c, hi)),
                  selected: _selected.contains(c),
                  onSelected: (on) => setState(() => on ? _selected.add(c) : _selected.remove(c)),
                ),
            ]),
            const SizedBox(height: 8),
            Text(s.oneTicketPerType, style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
          ]),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(labelText: s.description, hintText: s.descriptionHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _landmark,
              decoration: InputDecoration(labelText: s.landmark, hintText: s.landmarkHint),
            ),
            const SizedBox(height: 12),
            TextField(controller: _residentName, decoration: InputDecoration(labelText: s.residentNameOptional)),
            const SizedBox(height: 12),
            TextField(
              controller: _residentMobile,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(labelText: s.residentMobileOptional, counterText: ''),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: s.photo,
          child: PhotoCaptureButton(url: _photoUrl, onChanged: (u) => setState(() => _photoUrl = u)),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: s.location,
          child: GpsStatusCard(ward: state.ward(_wardId), onReading: (r) => _location = r),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: JaColors.saffron),
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox.square(
                  dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send),
          label: Text(s.submitComplaint),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
