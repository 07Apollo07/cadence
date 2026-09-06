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
          isComplex: true,
          willChange: true,
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

  static final Paint _gridPaint = Paint()
    ..color = AppColors.surfaceRaised.withValues(alpha: 0.6)
    ..strokeWidth = 1.0;

  static final Paint _axisPaint = Paint()
    ..color = AppColors.textMuted.withValues(alpha: 0.7)
    ..strokeWidth = 1.5;

  static const TextStyle _textStyle = TextStyle(
    color: AppColors.textMuted,
    fontSize: 9,
  );

  static final Map<String, TextPainter> _textPainterCache = {};

  static TextPainter _getTextPainter(String text) {
    return _textPainterCache.putIfAbsent(text, () {
      final tp = TextPainter(
        text: TextSpan(text: text, style: _textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      return tp;
    });
  }

  late final Map<MovementMode, Paint> _strokePaints;
  late final Map<MovementMode, Paint> _fillPaints;
  late final Paint _currentModeFillPaint;
  late final Paint _currentModeLinePaint;

  MetricGraphPainter({
    required this.history,
    required this.metricIndex,
    required this.showClockTime,
    required this.walkColor,
    required this.jogColor,
    required this.runColor,
    required this.currentMode,
  }) {
    _strokePaints = {
      MovementMode.walking: _createStrokePaint(walkColor),
      MovementMode.jogging: _createStrokePaint(jogColor),
      MovementMode.running: _createStrokePaint(runColor),
    };
  }

  static Paint _createStrokePaint(Color color) {
    return Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
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

  void _initShaders(double width, double height) {
    final rect = Rect.fromLTWH(0, 0, width, height);

    _fillPaints = {
      MovementMode.walking: Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            walkColor.withValues(alpha: 0.35),
            walkColor.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
      MovementMode.jogging: Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            jogColor.withValues(alpha: 0.35),
            jogColor.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
      MovementMode.running: Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            runColor.withValues(alpha: 0.35),
            runColor.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    };

    final currentColor = _colorForMode(currentMode);
    _currentModeFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          currentColor.withValues(alpha: 0.15),
          currentColor.withValues(alpha: 0.0),
        ],
      ).createShader(rect);

    _currentModeLinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          currentColor.withValues(alpha: 0.25),
          currentColor.withValues(alpha: 0.0),
        ],
      ).createShader(rect)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double leftMargin = 32.0;
    const double bottomMargin = 20.0;
    final graphWidth = size.width - leftMargin;
    final graphHeight = size.height - bottomMargin;

    _initShaders(graphWidth, graphHeight);

    // Draw grid lines
    const int verticalGridLines = 5;
    const int horizontalGridLines = 4;

    canvas.save();
    canvas.translate(leftMargin, 0);

    for (int i = 0; i <= verticalGridLines; i++) {
      final x = (graphWidth / verticalGridLines) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, graphHeight), _gridPaint);
    }

    for (int j = 0; j <= horizontalGridLines; j++) {
      final y = (graphHeight / horizontalGridLines) * j;
      canvas.drawLine(Offset(0, y), Offset(graphWidth, y), _gridPaint);
    }

    // Draw axes
    canvas.drawLine(Offset(0, 0), Offset(0, graphHeight), _axisPaint);
    canvas.drawLine(
      Offset(0, graphHeight),
      Offset(graphWidth, graphHeight),
      _axisPaint,
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
    for (int j = 0; j <= horizontalGridLines; j++) {
      final val = maxY - (maxY - minY) * (j / horizontalGridLines);
      final label = val.toStringAsFixed(0);
      final tp = _getTextPainter(label);
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
          final diffSec = tSec - endTime;
          if (duration < 60) {
            final secsAgo = diffSec.round();
            label = secsAgo == 0 ? 'Now' : '${secsAgo}s';
          } else {
            final minutesAgo = (diffSec / 60).round();
            label = minutesAgo == 0 ? 'Now' : '${minutesAgo}m';
          }
        }

        final tp = _getTextPainter(label);
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
            final fillPath = Path()..moveTo(seg.points.first.dx, graphHeight);
            for (final pt in seg.points) {
              fillPath.lineTo(pt.dx, pt.dy);
            }
            fillPath.lineTo(seg.points.last.dx, graphHeight);
            fillPath.close();

            canvas.drawPath(fillPath, _fillPaints[seg.mode]!);

            final strokePath = Path()
              ..moveTo(seg.points.first.dx, seg.points.first.dy);
            for (int k = 1; k < seg.points.length; k++) {
              strokePath.lineTo(seg.points[k].dx, seg.points[k].dy);
            }

            canvas.drawPath(strokePath, _strokePaints[seg.mode]!);
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

        final templatePath = Path()
          ..moveTo(x, y)
          ..lineTo(graphWidth, graphHeight)
          ..lineTo(x, graphHeight);
        templatePath.close();

        canvas.drawPath(templatePath, _currentModeFillPaint);

        final templateLinePath = Path()
          ..moveTo(x, y)
          ..lineTo(graphWidth, graphHeight);
        canvas.drawPath(templateLinePath, _currentModeLinePaint);

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
