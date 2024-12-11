import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PieChart extends pw.StatelessWidget {
  final List<double> values;
  final List<PdfColor> colors;

  PieChart({required this.values, required this.colors});

  @override
  pw.Widget build(pw.Context context) {
    double total = values.reduce((a, b) => a + b);
    double startAngle = 0.0;
    final radius = 100.0;
    final int segments = 100; // Incrementa para suavizar el círculo

    return pw.Container(
      width: radius * 2,
      height: radius * 2,
      child: pw.CustomPaint(
        painter: (PdfGraphics canvas, PdfPoint size) {
          for (int i = 0; i < values.length; i++) {
            final sweepAngle = (values[i] / total) * 2 * pi;
            final segmentSweep = sweepAngle / segments;

            for (int j = 0; j < segments; j++) {
              final angle1 = startAngle + j * segmentSweep;
              final angle2 = angle1 + segmentSweep;

              final x1 = radius + radius * cos(angle1);
              final y1 = radius + radius * sin(angle1);
              final x2 = radius + radius * cos(angle2);
              final y2 = radius + radius * sin(angle2);

              canvas
                ..setColor(colors[i])
                ..moveTo(radius, radius)
                ..lineTo(x1, y1)
                ..lineTo(x2, y2)
                ..closePath()
                ..fillPath();
            }

            startAngle += sweepAngle;
          }
        },
      ),
    );
  }
}
