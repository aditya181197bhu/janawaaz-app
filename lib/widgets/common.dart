import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../l10n/labels.dart';
import '../providers/app_state.dart';

/// Language switch and profile switch, shown in every home screen's app bar.
List<Widget> appBarActions(BuildContext context) {
  final state = context.watch<AppState>();
  return [
    TextButton(
      onPressed: state.toggleLanguage,
      child: Text(state.s.switchLanguage,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    ),
    IconButton(
      tooltip: state.s.switchProfile,
      icon: const Icon(Icons.switch_account_outlined),
      onPressed: () {
        Navigator.of(context).popUntil((r) => r.isFirst);
        state.setProfile(null);
      },
    ),
  ];
}

/// Loads data with a future and shows loading, error-with-retry, or the content.
class AsyncView<T> extends StatefulWidget {
  const AsyncView({super.key, required this.load, required this.builder});

  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data, Future<void> Function() reload) builder;

  @override
  State<AsyncView<T>> createState() => _AsyncViewState<T>();
}

class _AsyncViewState<T> extends State<AsyncView<T>> {
  late Future<T> _future = widget.load();

  Future<void> _reload() async {
    final next = widget.load();
    setState(() => _future = next);
    await next.catchError((_) => null as T);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return ErrorView(message: snap.error.toString(), onRetry: _reload);
        }
        return widget.builder(context, snap.data as T, _reload);
      },
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, size: 48, color: JaColors.grey),
          const SizedBox(height: 12),
          Text(s.couldNotLoad, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: JaColors.textSecondary)),
          const SizedBox(height: 16),
          SizedBox(width: 180, child: OutlinedButton(onPressed: onRetry, child: Text(s.retry))),
        ]),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, this.trailing, required this.child, this.padding});

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (title != null) ...[
            Row(children: [
              Expanded(
                child: Text(title!.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 12, letterSpacing: 0.8, fontWeight: FontWeight.w700, color: JaColors.textSecondary)),
              ),
              ?trailing,
            ]),
            const SizedBox(height: 12),
          ],
          child,
        ]),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label, this.color = JaColors.textPrimary, this.icon});

  final String value;
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) ...[Icon(icon, size: 16, color: color), const SizedBox(width: 6)],
          Flexible(
            child: Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: JaColors.textSecondary, height: 1.2)),
      ]),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final hindi = context.watch<AppState>().hindi;
    final color = Labels.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(Labels.status(status, hindi),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color.lerp(color, Colors.black, 0.3))),
      ]),
    );
  }
}

/// A single horizontal bar split into Green / Yellow / Red shares.
class RagBar extends StatelessWidget {
  const RagBar({super.key, required this.green, required this.yellow, required this.red, this.height = 10});

  final int green, yellow, red;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = green + yellow + red;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: total == 0
            ? Container(color: JaColors.divider)
            : Row(children: [
                if (green > 0) Expanded(flex: green, child: Container(color: JaColors.green)),
                if (yellow > 0) Expanded(flex: yellow, child: Container(color: JaColors.yellow)),
                if (red > 0) Expanded(flex: red, child: Container(color: JaColors.red)),
              ]),
      ),
    );
  }
}

/// Completed / in progress / not started share of complaints.
class ProgressSplitBar extends StatelessWidget {
  const ProgressSplitBar({super.key, required this.resolved, required this.inProgress, required this.reported});

  final int resolved, inProgress, reported;

  @override
  Widget build(BuildContext context) => RagBar(green: resolved, yellow: inProgress, red: reported, height: 12);
}

class Legend extends StatelessWidget {
  const Legend({super.key, required this.items});

  final List<(Color, String)> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 14, runSpacing: 6, children: [
      for (final (color, label) in items)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12, color: JaColors.textSecondary)),
        ]),
    ]);
  }
}

class WardDropdown extends StatelessWidget {
  const WardDropdown({super.key, required this.value, required this.onChanged, this.allowAll = false});

  final int? value;
  final ValueChanged<int?> onChanged;
  final bool allowAll;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return DropdownButtonFormField<int?>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city_outlined)),
      items: [
        if (allowAll) DropdownMenuItem<int?>(value: null, child: Text(state.s.allWards)),
        for (final w in state.wards) DropdownMenuItem<int?>(value: w.id, child: Text(w.label(state.hindi))),
      ],
      onChanged: onChanged,
    );
  }
}

String formatDate(DateTime d, bool hindi) => DateFormat('d MMM, h:mm a', hindi ? 'hi' : 'en').format(d);

String formatDay(DateTime d, bool hindi) => DateFormat('d MMM yyyy', hindi ? 'hi' : 'en').format(d);

int daysSince(DateTime d) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
}

void showMessage(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? JaColors.error : JaColors.navy));
}
