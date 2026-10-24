import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../config/api_config.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import 'common.dart';

/// Takes or picks a photo and uploads it straight away; reports the server URL.
class PhotoCaptureButton extends StatefulWidget {
  const PhotoCaptureButton({super.key, required this.url, required this.onChanged});

  final String? url;
  final ValueChanged<String?> onChanged;

  @override
  State<PhotoCaptureButton> createState() => _PhotoCaptureButtonState();
}

class _PhotoCaptureButtonState extends State<PhotoCaptureButton> {
  bool _uploading = false;

  Future<void> _pick() async {
    final s = context.read<AppState>().s;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(s.camera),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(s.gallery),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 70, maxWidth: 1600);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      widget.onChanged(await ApiService.instance.upload(File(picked.path), kind: 'PHOTO'));
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    if (widget.url != null) {
      return _EvidenceChip(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(ApiConfig.fileUrl(widget.url!), width: 32, height: 32, fit: BoxFit.cover),
        ),
        label: s.photoAdded,
        onClear: () => widget.onChanged(null),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46)),
      onPressed: _uploading ? null : _pick,
      icon: _uploading
          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.add_a_photo_outlined),
      label: Text(_uploading ? s.uploading : s.addPhoto),
    );
  }
}

/// Records up to 30 seconds of audio, uploads it, and reports the server URL.
class VoiceNoteButton extends StatefulWidget {
  const VoiceNoteButton({super.key, required this.url, required this.onChanged});

  final String? url;
  final ValueChanged<String?> onChanged;

  @override
  State<VoiceNoteButton> createState() => _VoiceNoteButtonState();
}

class _VoiceNoteButtonState extends State<VoiceNoteButton> {
  static const _maxSeconds = 30;
  final _recorder = AudioRecorder();
  Timer? _timer;
  int _seconds = 0;
  bool _recording = false;
  bool _uploading = false;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final s = context.read<AppState>().s;
    if (!await _recorder.hasPermission()) {
      if (mounted) showMessage(context, s.microphoneDenied, error: true);
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1, bitRate: 64000), path: path);
    setState(() {
      _recording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _seconds++);
      if (_seconds >= _maxSeconds) _stop();
    });
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    setState(() {
      _recording = false;
      _uploading = path != null;
    });
    if (path == null) return;
    try {
      widget.onChanged(await ApiService.instance.upload(File(path), kind: 'VOICE'));
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    if (widget.url != null) {
      return _EvidenceChip(
        leading: const Icon(Icons.graphic_eq, color: JaColors.primary),
        label: s.voiceAdded,
        onClear: () => widget.onChanged(null),
      );
    }
    if (_recording) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: JaColors.red, minimumSize: const Size(0, 46)),
        onPressed: _stop,
        icon: const Icon(Icons.stop_circle_outlined),
        label: Text(s.recordingSeconds(_maxSeconds - _seconds)),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46)),
      onPressed: _uploading ? null : _start,
      icon: _uploading
          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.mic_none),
      label: Text(_uploading ? s.uploading : s.recordVoice),
    );
  }
}

class _EvidenceChip extends StatelessWidget {
  const _EvidenceChip({required this.leading, required this.label, required this.onClear});

  final Widget leading;
  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: JaColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: JaColors.green.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        leading,
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClear),
      ]),
    );
  }
}
