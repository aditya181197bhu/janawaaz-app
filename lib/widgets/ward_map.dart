import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/theme.dart';
import '../l10n/labels.dart';
import '../models/stats.dart';

/// OpenStreetMap base map (free, no API key) with circles and markers on top.
class JaMap extends StatelessWidget {
  const JaMap({
    super.key,
    required this.center,
    required this.zoom,
    this.circles = const [],
    this.markers = const [],
    this.interactive = true,
    this.fitBounds,
    this.fitPadding = const EdgeInsets.all(24),
  });

  final LatLng center;
  final double zoom;
  final LatLngBounds? fitBounds;
  final EdgeInsets fitPadding;
  final List<CircleMarker> circles;
  final List<Marker> markers;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        initialCameraFit: fitBounds == null ? null : CameraFit.bounds(bounds: fitBounds!, padding: fitPadding),
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.stavya.janawaaz_app',
        ),
        CircleLayer(circles: circles),
        MarkerLayer(markers: markers),
        const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
      ],
    );
  }
}

/// Ward boundary plus complaint points drawn as soft overlapping circles, so
/// clusters of complaints read as a heatmap, with a solid dot at each one.
class WardComplaintsLayers {
  static List<CircleMarker> circles(WardReport r) => [
        CircleMarker(
          point: LatLng(r.centerLat, r.centerLng),
          radius: r.radiusMeters.toDouble(),
          useRadiusInMeter: true,
          color: JaColors.primary.withValues(alpha: 0.05),
          borderColor: JaColors.primary.withValues(alpha: 0.6),
          borderStrokeWidth: 2,
        ),
        for (final p in r.points)
          CircleMarker(
            point: LatLng(p.lat, p.lng),
            radius: 110,
            useRadiusInMeter: true,
            color: Labels.statusColor(p.status).withValues(alpha: 0.16),
          ),
      ];

  static List<Marker> markers(WardReport r) => [
        for (final p in r.points)
          Marker(point: LatLng(p.lat, p.lng), width: 14, height: 14, child: _Dot(color: Labels.statusColor(p.status))),
      ];
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
}

/// Full-screen interactive map opened from a map preview.
class FullScreenMap extends StatelessWidget {
  const FullScreenMap({super.key, required this.title, required this.map, this.footer});

  final String title;
  final Widget map;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(children: [
        Expanded(child: map),
        if (footer != null) Container(color: Colors.white, padding: const EdgeInsets.all(12), child: footer),
      ]),
    );
  }
}
