import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Placeholder Jan Awaaz mark: a blue tile with a speech bubble holding a voice
/// waveform ("awaaz" = voice). The launcher icon is drawn from the same design.
class JaLogo extends StatelessWidget {
  const JaLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: size, child: CustomPaint(painter: _LogoPainter()));
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final tile = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.24));
    canvas.drawRRect(
      tile,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [JaColors.navy, JaColors.primaryLight],
        ).createShader(Offset.zero & size),
    );

    final bubble = RRect.fromLTRBR(s * 0.17, s * 0.2, s * 0.83, s * 0.7, Radius.circular(s * 0.14));
    final tail = Path()
      ..moveTo(s * 0.3, s * 0.66)
      ..lineTo(s * 0.26, s * 0.84)
      ..lineTo(s * 0.46, s * 0.68)
      ..close();
    final white = Paint()..color = Colors.white;
    canvas.drawRRect(bubble, white);
    canvas.drawPath(tail, white);

    const heights = [0.3, 0.6, 1.0, 0.6, 0.3];
    final bar = Paint()
      ..color = JaColors.primary
      ..strokeWidth = s * 0.065
      ..strokeCap = StrokeCap.round;
    final centerY = s * 0.45;
    for (var i = 0; i < heights.length; i++) {
      final x = s * (0.32 + i * 0.09);
      final half = s * 0.15 * heights[i];
      canvas.drawLine(Offset(x, centerY - half), Offset(x, centerY + half), bar);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
