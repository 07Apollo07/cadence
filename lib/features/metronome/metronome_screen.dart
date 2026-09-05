import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/audio/beat_scheduler.dart';
import '../../core/formulas/pace_formulas.dart';
import '../../core/theme/app_colors.dart';

class MetronomeScreen extends ConsumerStatefulWidget {
  const MetronomeScreen({super.key});

  @override
  ConsumerState<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends ConsumerState<MetronomeScreen> {
  late final BeatScheduler _scheduler;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _dragAccumulator = 0.0;
  bool _showClockTime = false;

  @override
  void initState() {
    super.initState();
    _scheduler = BeatScheduler();
    _scheduler.onBeat = () {
      if (mounted) {
        ref.read(cadenceProvider.notifier).addTickPoint();
        setState(() {});
      }
    };
  }

  @override
  void dispose() {
    _scheduler.stop();
    _scheduler.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final cadenceState = ref.read(cadenceProvider);
    if (_scheduler.isRunning) {
      _scheduler.stop();
      ref.read(cadenceProvider.notifier).setRunning(false);
    } else {
      _scheduler.setCadence(cadenceState.targetCadence);
      _scheduler.start();
      ref.read(cadenceProvider.notifier).setRunning(true);
    }
  }

  void _handleWheelDrag(double delta) {
    _dragAccumulator += delta;
    if (_dragAccumulator.abs() > 15.0) {
      final cadenceNotifier = ref.read(cadenceProvider.notifier);
      final currentCadence = ref.read(cadenceProvider).targetCadence;
      final step = _dragAccumulator < 0 ? 1 : -1; // Drag up increases cadence
      final newCadence = (currentCadence + step).clamp(120, 220);
      cadenceNotifier.setTargetCadence(newCadence);
      if (_scheduler.isRunning) {
        _scheduler.setCadence(newCadence);
      }
      _dragAccumulator = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cadenceState = ref.watch(cadenceProvider);
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(
        cadenceState.targetCadence.toDouble(), cadenceState.strideLengthMeters);
    final pace = PaceFormulas.speedKmHToPace(speed);
    final paceStr = '${pace.inMinutes}:${(pace.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'CADENCE',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 2.0),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    _buildKnurledBar(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 160,
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              children: [
                                _buildCardPage(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${cadenceState.targetCadence}',
                                        style: const TextStyle(
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'SPM',
                                        style: TextStyle(color: AppColors.textMuted, fontSize: 14, letterSpacing: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildCardPage(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${speed.toStringAsFixed(1)} km/h',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.traceCalm,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pace: $paceStr /km',
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildCardPage(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${cadenceState.strideLengthMeters.toStringAsFixed(2)} m',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.traceCalm,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Beats: ${_scheduler.beatCount}',
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(_currentPage == 0),
                              const SizedBox(width: 6),
                              _buildDot(_currentPage == 1),
                              const SizedBox(width: 6),
                              _buildDot(_currentPage == 2),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 140,
                            child: CustomPaint(
                              painter: MetricGraphPainter(
                                history: cadenceState.history,
                                metricIndex: _currentPage,
                                showClockTime: _showClockTime,
                              ),
                              size: const Size(double.infinity, 140),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _buildTimeToggleBtn('Relative', !_showClockTime, () => setState(() => _showClockTime = false)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTimeToggleBtn('Clock Time', _showClockTime, () => setState(() => _showClockTime = true)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppColors.surfacePanel,
                                    title: const Text('Reset Graph', style: TextStyle(color: AppColors.textPrimary)),
                                    content: const Text('Are you sure you want to reset the graph history?', style: TextStyle(color: AppColors.textMuted)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          ref.read(cadenceProvider.notifier).resetHistory();
                                        },
                                        child: const Text('Reset', style: TextStyle(color: AppColors.statusDanger)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceRaised,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.hairline),
                                ),
                                child: const Text(
                                  'Reset Graph',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(child: Center(child: _buildStat('SPEED', '${speed.toStringAsFixed(1)} km/h'))),
                              Expanded(child: Center(child: _buildStat('PACE', '$paceStr /km'))),
                              Expanded(child: Center(child: _buildStat('BEATS', '${_scheduler.beatCount}'))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildKnurledBar(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfacePanel,
                      border: Border.all(
                        color: _scheduler.isRunning ? AppColors.statusDanger : AppColors.traceCalm,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_scheduler.isRunning ? AppColors.statusDanger : AppColors.traceCalm).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _scheduler.isRunning ? Icons.stop : Icons.play_arrow,
                        color: _scheduler.isRunning ? AppColors.statusDanger : AppColors.traceCalm,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPage({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildKnurledBar() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        _handleWheelDrag(details.delta.dy);
      },
      child: Container(
        width: 24,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF333333),
              Color(0xFF1A1A1A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF444444), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 24,
            itemBuilder: (context, index) {
              final isCenter = index == 12;
              return Container(
                height: 8,
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isCenter
                        ? [AppColors.traceCalm, AppColors.traceCalm.withValues(alpha: 0.7)]
                        : [
                            const Color(0xFF555555),
                            const Color(0xFF222222),
                            const Color(0xFF111111),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.traceCalm : AppColors.hairline,
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTimeToggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.traceCalm.withValues(alpha: 0.2) : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.traceCalm : AppColors.hairline),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.traceCalm : AppColors.textMuted,
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class MetricGraphPainter extends CustomPainter {
  final List<MetricPoint> history;
  final int metricIndex;
  final bool showClockTime;

  MetricGraphPainter({
    required this.history,
    required this.metricIndex,
    required this.showClockTime,
  });

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
    canvas.drawLine(Offset(0, graphHeight), Offset(graphWidth, graphHeight), axisPaint);
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
          final absDuration = endAbs - startAbs > 0 ? endAbs - startAbs : duration;
          final tAbs = startAbs + absDuration * tFrac;
          final dt = DateTime.fromMillisecondsSinceEpoch((tAbs * 1000).round());
          final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
          final minute = dt.minute.toString().padLeft(2, '0');
          final amPm = dt.hour >= 12 ? 'PM' : 'AM';
          label = '$hour:$minute $amPm';
        } else {
          final minutesAgo = ((endTime - tSec) / 60).round();
          label = minutesAgo == 0 ? 'Now' : '-${minutesAgo}m';
        }

        final tp = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        final xPos = graphWidth * tFrac - (tp.width / 2);
        tp.paint(canvas, Offset(xPos, graphHeight + 4));
      }

      final linePaint = Paint()
        ..color = AppColors.traceCalm
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.traceCalm.withValues(alpha: 0.35),
            AppColors.traceCalm.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, graphWidth, graphHeight));

      final path = Path();
      final fillPath = Path();
      fillPath.moveTo(0, graphHeight);

      for (int i = 0; i < history.length; i++) {
        final pt = history[i];
        double val = metricIndex == 0 ? pt.cadence : (metricIndex == 1 ? pt.speed : pt.stride);

        final x = graphWidth * ((pt.timeSeconds - startTime) / (duration == 0 ? 1 : duration));
        final normY = (val - minY) / (maxY - minY);
        final clampedY = normY.clamp(0.0, 1.0);
        final y = graphHeight * (1.0 - clampedY);

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.lineTo(x, y);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }

      fillPath.lineTo(graphWidth, graphHeight);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, linePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MetricGraphPainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.metricIndex != metricIndex ||
        oldDelegate.showClockTime != showClockTime;
  }
}
