import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/theme/app_colors.dart';

class MetricGraphWidget extends ConsumerWidget {
  final int metricIndex;
  final bool showClockTime;

  const MetricGraphWidget({
    super.key,
    required this.metricIndex,
    required this.showClockTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(cadenceHistoryProvider.select((s) => s.history));
    final walkColor = ref.watch(cadenceProvider.select((s) => s.walkColor));
    final jogColor = ref.watch(cadenceProvider.select((s) => s.jogColor));
    final runColor = ref.watch(cadenceProvider.select((s) => s.runColor));
    final currentMode = ref.watch(
      cadenceProvider.select((s) => s.movementMode),
    );

    return RepaintBoundary(
      child: SizedBox(
        height: 140,
        child: CustomPaint(
          painter: MetricGraphPainter(
            history: history,
            metricIndex: metricIndex,
            showClockTime: showClockTime,
            walkColor: walkColor,
            jogColor: jogColor,
            runColor: runColor,
            currentMode: currentMode,
          ),
          size: const Size(double.infinity, 140),
        ),
      ),
    );
  }
}

class _GraphSegment {
  final MovementMode mode;
  final List<Offset> points;

  _GraphSegment(this.mode) : points = [];
}

class MetricGraphPainter extends CustomPainter {
  final List<MetricPoint> history;
  final int metricIndex;
  final bool showClockTime;
  final Color walkColor;
  final Color jogColor;
  final Color runColor;
  final MovementMode currentMode;
  late final Shader fillShader;
  late final Shader lineShader;

  MetricGraphPainter({
    required this.history,
    required this.metricIndex,
    required this.showClockTime,
    required this.walkColor,
    required this.jogColor,
    required this.runColor,
    required this.currentMode,
  }) {
    final color = _colorForMode(currentMode);
    fillShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
    ).createShader(const Rect.fromLTWH(0, 0, 1000, 1000)); // Large enough rect

    lineShader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
    ).createShader(const Rect.fromLTWH(0, 0, 1000, 1000));
  }

  Color _colorForMode(MovementMode m) {
    switch (m) {
      case MovementMode.walking:
        return walkColor;
      case MovementMode.jogging:
        return jogColor;
      case MovementMode.running:
        return runColor;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double leftMargin = 32.0;
    const double bottomMargin = 20.0;
    final graphWidth = size.width - leftMargin;
    final graphHeight = size.height - bottomMargin;

    final gridPaint = Paint()
      ..color = AppColors.surfaceRaised.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;

    // Draw grid lines
    const int verticalGridLines = 5;
    const int horizontalGridLines = 4;

    canvas.save();
    canvas.translate(leftMargin, 0);

    for (int i = 0; i <= verticalGridLines; i++) {
      final x = (graphWidth / verticalGridLines) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, graphHeight), gridPaint);
    }

    for (int j = 0; j <= horizontalGridLines; j++) {
      final y = (graphHeight / horizontalGridLines) * j;
      canvas.drawLine(Offset(0, y), Offset(graphWidth, y), gridPaint);
    }

    // Draw axes
    canvas.drawLine(Offset(0, 0), Offset(0, graphHeight), axisPaint);
    canvas.drawLine(
      Offset(0, graphHeight),
      Offset(graphWidth, graphHeight),
      axisPaint,
    );
    canvas.restore();

    // Determine min/max
    double minY = 60;
    double maxY = 220;
    if (metricIndex == 1) {
      minY = 0;
      maxY = 25;
    } else if (metricIndex == 2) {
      minY = 0.5;
      maxY = 2.5;
    }

    // Draw Y-axis labels
    final textStyle = const TextStyle(color: AppColors.textMuted, fontSize: 9);
    for (int j = 0; j <= horizontalGridLines; j++) {
      final val = maxY - (maxY - minY) * (j / horizontalGridLines);
      final tp = TextPainter(
        text: TextSpan(text: val.toStringAsFixed(0), style: textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(2, graphHeight * (j / horizontalGridLines) - 5));
    }

    canvas.save();
    canvas.translate(leftMargin, 0);

    if (history.isNotEmpty) {
      final startTime = history.first.timeSeconds;
      final endTime = history.last.timeSeconds;
      final duration = endTime - startTime > 0 ? endTime - startTime : 3600.0;

      // X-axis time labels
      for (int i = 0; i <= 3; i++) {
        final tFrac = i / 3.0;
        final tSec = startTime + duration * tFrac;

        String label;
        if (showClockTime && history.isNotEmpty) {
          final startAbs = history.first.absoluteTimestamp;
          final endAbs = history.last.absoluteTimestamp;
          final absDuration = endAbs - startAbs > 0
              ? endAbs - startAbs
              : duration;
          final tAbs = startAbs + absDuration * tFrac;
          final dt = DateTime.fromMillisecondsSinceEpoch((tAbs * 1000).round());
          final hour = dt.hour == 0
              ? 12
              : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
          final minute = dt.minute.toString().padLeft(2, '0');
          final amPm = dt.hour >= 12 ? 'PM' : 'AM';
          label = '$hour:$minute $amPm';
        } else {
          final diffSec =
              tSec - endTime; // Time difference: negative (past) to 0 (now)
          if (duration < 60) {
            final secsAgo = diffSec.round();
            label = secsAgo == 0 ? 'Now' : '${secsAgo}s';
          } else {
            final minutesAgo = (diffSec / 60).round();
            label = minutesAgo == 0 ? 'Now' : '${minutesAgo}m';
          }
        }

        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        final xPos = graphWidth * tFrac - (tp.width / 2);
        tp.paint(canvas, Offset(xPos, graphHeight + 4));
      }

      if (history.length > 1) {
        // Group points into continuous segments
        final List<_GraphSegment> segments = [];
        _GraphSegment? currentSegment;

        for (int i = 0; i < history.length; i++) {
          final p = history[i];
          double val = metricIndex == 0
              ? p.cadence
              : (metricIndex == 1 ? p.speed : p.stride);

          final x =
              graphWidth *
              ((p.timeSeconds - startTime) / (duration == 0 ? 1 : duration));
          final y =
              graphHeight *
              (1.0 - ((val - minY) / (maxY - minY)).clamp(0.0, 1.0));

          final offset = Offset(x, y);

          if (currentSegment == null) {
            currentSegment = _GraphSegment(p.mode)..points.add(offset);
          } else {
            final prevP = history[i - 1];
            final hasGap = (p.timeSeconds - prevP.timeSeconds) > 2.0;

            if (p.mode == currentSegment.mode && !hasGap) {
              currentSegment.points.add(offset);
            } else {
              if (!hasGap) {
                // Include transition point to connect lines continuously without structural gaps
                currentSegment.points.add(offset);
              }
              segments.add(currentSegment);
              currentSegment = _GraphSegment(p.mode)..points.add(offset);
            }
          }
        }
        if (currentSegment != null && currentSegment.points.isNotEmpty) {
          segments.add(currentSegment);
        }

        // Draw each segment optimally
        for (final seg in segments) {
          if (seg.points.length > 1) {
            final color = _colorForMode(seg.mode);

            // Path for gradient filling
            final fillPath = Path()..moveTo(seg.points.first.dx, graphHeight);
            for (final pt in seg.points) {
              fillPath.lineTo(pt.dx, pt.dy);
            }
            fillPath.lineTo(seg.points.last.dx, graphHeight);
            fillPath.close();

            final fillPaint = Paint()
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.35),
                  color.withValues(alpha: 0.0),
                ],
              ).createShader(Rect.fromLTWH(0, 0, graphWidth, graphHeight));

            canvas.drawPath(fillPath, fillPaint);

            // Path for line tracing
            final strokePath = Path()
              ..moveTo(seg.points.first.dx, seg.points.first.dy);
            for (int k = 1; k < seg.points.length; k++) {
              strokePath.lineTo(seg.points[k].dx, seg.points[k].dy);
            }

            final strokePaint = Paint()
              ..color = color
              ..strokeWidth = 2.5
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round;

            canvas.drawPath(strokePath, strokePaint);
          } else if (seg.points.length == 1) {
            final pt = seg.points.first;
            final color = _colorForMode(seg.mode);
            final ptPaint = Paint()
              ..color = color
              ..style = PaintingStyle.fill;
            canvas.drawCircle(pt, 3.5, ptPaint);
          }
        }
      } else if (history.length == 1) {
        final p = history.first;
        final color = _colorForMode(currentMode);

        double val = metricIndex == 0
            ? p.cadence
            : (metricIndex == 1 ? p.speed : p.stride);
        final x =
            graphWidth *
            ((p.timeSeconds - startTime) / (duration == 0 ? 1 : duration));
        final y =
            graphHeight *
            (1.0 - ((val - minY) / (maxY - minY)).clamp(0.0, 1.0));

        // Faded template gradient fill and sloped line
        final templatePath = Path()
          ..moveTo(x, y)
          ..lineTo(graphWidth, graphHeight)
          ..lineTo(x, graphHeight)
          ..close();

        final templateFillPaint = Paint()..shader = fillShader;
        canvas.drawPath(templatePath, templateFillPaint);

        final templateLinePaint = Paint()
          ..shader = lineShader
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final templateLinePath = Path()
          ..moveTo(x, y)
          ..lineTo(graphWidth, graphHeight);
        canvas.drawPath(templateLinePath, templateLinePaint);

        final ptPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 3.5, ptPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MetricGraphPainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.metricIndex != metricIndex ||
        oldDelegate.showClockTime != showClockTime ||
        oldDelegate.walkColor != walkColor ||
        oldDelegate.jogColor != jogColor ||
        oldDelegate.runColor != runColor ||
        oldDelegate.currentMode != currentMode;
  }
}
