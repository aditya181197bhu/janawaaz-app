import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../l10n/strings.dart';
import '../models/meta.dart';
import '../providers/app_state.dart';
import '../services/location_service.dart';

/// Shows whether the phone is inside the selected ward, with refresh and the
/// demo-location switch. Reports each new reading through [onReading].
class GpsStatusCard extends StatefulWidget {
  const GpsStatusCard({super.key, required this.ward, this.onReading});

  final Ward ward;
  final ValueChanged<LocationReading?>? onReading;

  @override
  State<GpsStatusCard> createState() => _GpsStatusCardState();
}

class _GpsStatusCardState extends State<GpsStatusCard> {
  LocationReading? _reading;
  LocationProblem? _problem;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  void didUpdateWidget(covariant GpsStatusCard old) {
    super.didUpdateWidget(old);
    if (old.ward.id != widget.ward.id) _read();
  }

  Future<void> _read() async {
    setState(() {
      _loading = true;
      _problem = null;
    });
    final demo = context.read<AppState>().demoLocation;
    try {
      final r = await LocationService.read(ward: widget.ward, demo: demo);
      if (!mounted) return;
      setState(() => _reading = r);
      widget.onReading?.call(r);
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _reading = null;
        _problem = e.problem;
      });
      widget.onReading?.call(null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    final (icon, color, text) = _describe(s);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Row(children: [
          _loading
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: Color.lerp(color, Colors.black, .35)))),
          IconButton(
            tooltip: s.refreshLocation,
            icon: const Icon(Icons.my_location, size: 20),
            onPressed: _loading ? null : _read,
          ),
        ]),
        Row(children: [
          const Icon(Icons.science_outlined, size: 16, color: JaColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(s.useDemoLocation, style: const TextStyle(fontSize: 13, color: JaColors.textSecondary))),
          Switch(
            value: state.demoLocation,
            onChanged: (v) {
              state.setDemoLocation(v);
              _read();
            },
          ),
        ]),
      ]),
    );
  }

  (IconData, Color, String) _describe(Strings s) {
    if (_loading && _reading == null) return (Icons.gps_fixed, JaColors.primary, s.checkingLocation);
    if (_problem != null) {
      final text = switch (_problem!) {
        LocationProblem.serviceOff => s.locationOff,
        LocationProblem.permissionDenied => s.locationDenied,
        LocationProblem.timeout => s.locationTimeout,
      };
      return (Icons.gps_off, JaColors.red, text);
    }
    final r = _reading!;
    final meters = r.distanceTo(widget.ward);
    return r.isInside(widget.ward)
        ? (Icons.verified, JaColors.green, s.insideWard(widget.ward.id, meters))
        : (Icons.wrong_location, JaColors.red, s.outsideWard(widget.ward.id, meters));
  }
}
