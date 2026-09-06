import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/formulas/pace_formulas.dart';
import '../../core/theme/app_colors.dart';
import 'beat_scheduler_provider.dart';
import 'metric_graph_widget.dart';
import 'knurled_bar_widget.dart';

class MetronomeScreen extends ConsumerStatefulWidget {
  const MetronomeScreen({super.key});

  @override
  ConsumerState<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends ConsumerState<MetronomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _dragAccumulator = 0.0;
  bool _showClockTime = false;

  void _togglePlay() {
    final scheduler = ref.read(beatSchedulerProvider);
    final cadenceState = ref.read(cadenceProvider);
    if (scheduler.isRunning) {
      scheduler.stop();
      ref.read(cadenceProvider.notifier).setRunning(false);
    } else {
      scheduler.setCadence(cadenceState.targetCadence);
      scheduler.start();
      ref.read(cadenceProvider.notifier).setRunning(true);
    }
    setState(() {});
  }

  void _handleWheelDrag(double delta) {
    _dragAccumulator += delta;
    if (_dragAccumulator.abs() > 15.0) {
      final cadenceNotifier = ref.read(cadenceProvider.notifier);
      final currentCadence = ref.read(cadenceProvider).targetCadence;
      final step = _dragAccumulator < 0 ? 1 : -1; // Drag up increases cadence
      final newCadence = (currentCadence + step).clamp(60, 240);
      cadenceNotifier.setTargetCadence(newCadence);
      final scheduler = ref.read(beatSchedulerProvider);
      if (scheduler.isRunning) {
        scheduler.setCadence(newCadence);
      }
      _dragAccumulator = 0.0;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final cadenceState = ref.watch(cadenceProvider);
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(
      cadenceState.targetCadence.toDouble(),
      cadenceState.strideLengthMeters,
    );
    final pace = PaceFormulas.speedKmHToPace(speed);
    final paceStr =
        '${pace.inMinutes}:${(pace.inSeconds % 60).toString().padLeft(2, '0')}';

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
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    Center(
                      child: KnurledBar(onVerticalDragUpdate: _handleWheelDrag),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 14,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildCardPage(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildCardPage(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                        ValueListenableBuilder<int>(
                                          valueListenable: ref
                                              .read(beatSchedulerProvider)
                                              .beatCountNotifier,
                                          builder: (context, beatCount, child) {
                                            return Text(
                                              'Beats: $beatCount',
                                              style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 16,
                                              ),
                                            );
                                          },
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
                            const SizedBox(height: 16),
                            MetricGraphWidget(
                              metricIndex: _currentPage,
                              showClockTime: _showClockTime,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _buildTimeToggleBtn(
                                    'Relative',
                                    !_showClockTime,
                                    () =>
                                        setState(() => _showClockTime = false),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTimeToggleBtn(
                                    'Clock Time',
                                    _showClockTime,
                                    () => setState(() => _showClockTime = true),
                                  ),
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
                                      title: const Text(
                                        'Reset Graph',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to reset the graph history?',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            ref
                                                .read(cadenceProvider.notifier)
                                                .resetHistory();
                                          },
                                          child: const Text(
                                            'Reset',
                                            style: TextStyle(
                                              color: AppColors.statusDanger,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.hairline,
                                    ),
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
                            const SizedBox(height: 16),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: _buildStat(
                                      'SPEED',
                                      '${speed.toStringAsFixed(1)} km/h',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: _buildStat('PACE', '$paceStr /km'),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: ValueListenableBuilder<int>(
                                      valueListenable: ref
                                          .read(beatSchedulerProvider)
                                          .beatCountNotifier,
                                      builder: (context, beatCount, child) {
                                        return _buildStat(
                                          'BEATS',
                                          '$beatCount',
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildModeButtons(cadenceState),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Center(
                      child: KnurledBar(onVerticalDragUpdate: _handleWheelDrag),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: ref
                      .read(beatSchedulerProvider)
                      .isRunningNotifier,
                  builder: (context, isRunning, child) {
                    return GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfacePanel,
                          border: Border.all(
                            color: isRunning
                                ? AppColors.statusDanger
                                : AppColors.traceCalm,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isRunning
                                          ? AppColors.statusDanger
                                          : AppColors.traceCalm)
                                      .withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isRunning ? Icons.stop : Icons.play_arrow,
                            color: isRunning
                                ? AppColors.statusDanger
                                : AppColors.traceCalm,
                            size: 36,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 84),
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
          ),
        ],
      ),
      child: Center(child: child),
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
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          color: active
              ? AppColors.traceCalm.withValues(alpha: 0.2)
              : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.traceCalm : AppColors.hairline,
          ),
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

  Widget _buildModeButtons(CadenceState cadenceState) {
    final presets = cadenceState.presetsForMode(cadenceState.movementMode);
    final activeColor = cadenceState.activeColor;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildModeBtn(
                'Walk',
                MovementMode.walking,
                cadenceState.movementMode == MovementMode.walking,
                cadenceState.walkColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeBtn(
                'Jog',
                MovementMode.jogging,
                cadenceState.movementMode == MovementMode.jogging,
                cadenceState.jogColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeBtn(
                'Run',
                MovementMode.running,
                cadenceState.movementMode == MovementMode.running,
                cadenceState.runColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.entries.map((entry) {
              final isPresetActive = cadenceState.targetCadence == entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    final notifier = ref.read(cadenceProvider.notifier);
                    notifier.setTargetCadence(entry.value);
                    final scheduler = ref.read(beatSchedulerProvider);
                    if (scheduler.isRunning) {
                      scheduler.setCadence(entry.value);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPresetActive
                          ? activeColor.withValues(alpha: 0.3)
                          : AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPresetActive
                            ? activeColor
                            : AppColors.hairline,
                        width: isPresetActive ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      '${entry.key} (${entry.value})',
                      style: TextStyle(
                        color: isPresetActive
                            ? activeColor
                            : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: isPresetActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModeBtn(
    String label,
    MovementMode mode,
    bool isActive,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(cadenceProvider.notifier).setMovementMode(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.25)
              : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : AppColors.hairline,
            width: isActive ? 2.0 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : AppColors.textMuted,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
