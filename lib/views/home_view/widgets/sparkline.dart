import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';

/// Thin polyline rendering of the `sparkline_30d` series returned with
/// engagement rate. Self-scaling: min and max of the input drive the
/// vertical extent so even small wobbles read clearly.
class Sparkline extends StatelessWidget {
  final List<double> values;
  final double width;
  final double height;

  const Sparkline({
    super.key,
    required this.values,
    this.width = 160,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(values),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values;
}
