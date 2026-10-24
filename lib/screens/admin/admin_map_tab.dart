import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/labels.dart';
import '../../models/stats.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common.dart';
import '../../widgets/ward_map.dart';
import '../tickets/ticket_browser.dart';
import 'admin_ward_screen.dart';

/// Constituency map: each ward shaded by how many complaints are open, with every
/// complaint as a dot. Tap a ward label for its detail, or a dot for the complaint.
class AdminMapTab extends StatefulWidget {
  const AdminMapTab({super.key});

  @override
  State<AdminMapTab> createState() => _AdminMapTabState();
}

class _AdminMapTabState extends State<AdminMapTab> {
  bool _showSurveys = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = state.s;
    return AsyncView<AdminMapData>(
      key: ValueKey('admin-map-${state.dataVersion}'),
      load: ApiService.instance.adminMap,
      builder: (context, data, _) {
        final maxOpen = data.wards.map((w) => w.tickets.open).fold(1, max);
        return Stack(children: [
          JaMap(
            center: const LatLng(25.145, 82.545),
            zoom: 12.6,
            fitBounds: LatLngBounds.fromPoints([
              for (final w in data.wards) ...[
                LatLng(w.centerLat - w.radiusMeters / 111320, w.centerLng),
                LatLng(w.centerLat + w.radiusMeters / 111320, w.centerLng),
                LatLng(w.centerLat, w.centerLng - w.radiusMeters / 100900),
                LatLng(w.centerLat, w.centerLng + w.radiusMeters / 100900),
              ],
            ]),
            fitPadding: const EdgeInsets.fromLTRB(16, 24, 16, 190),
            circles: [
              for (final w in data.wards)
                CircleMarker(
                  point: LatLng(w.centerLat, w.centerLng),
                  radius: w.radiusMeters.toDouble(),
                  useRadiusInMeter: true,
                  color: JaColors.red.withValues(alpha: 0.08 + 0.42 * w.tickets.open / maxOpen),
                  borderColor: JaColors.red.withValues(alpha: 0.7),
                  borderStrokeWidth: 1.5,
                ),
            ],
            markers: [
              if (_showSurveys)
                for (final p in data.surveys)
                  Marker(
                    point: LatLng(p.lat, p.lng),
                    width: 7,
                    height: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.status == 'OUTSIDE_WARD' ? JaColors.saffron : JaColors.primaryLight,
                      ),
                    ),
                  ),
              for (final p in data.tickets)
                Marker(
                  point: LatLng(p.lat, p.lng),
                  width: 16,
                  height: 16,
                  child: GestureDetector(
                    onTap: () => openTicket(context, p.ticketNo!),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Labels.statusColor(p.status),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
              for (final w in data.wards)
                Marker(
                  point: LatLng(w.centerLat, w.centerLng),
                  width: 44,
                  height: 26,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => AdminWardScreen(wardId: w.wardId))),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: JaColors.navy,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
                      ),
                      child: Text('W${w.wardId}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(s.mapHint, style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
                  const SizedBox(height: 8),
                  Legend(items: [
                    (JaColors.red, s.notStarted),
                    (JaColors.yellow, s.inProgress),
                    (JaColors.green, s.completed),
                  ]),
                  FilterChip(
                    label: Text(s.showSurveyLocations),
                    selected: _showSurveys,
                    onSelected: (v) => setState(() => _showSurveys = v),
                  ),
                ]),
              ),
            ),
          ),
        ]);
      },
    );
  }
}
