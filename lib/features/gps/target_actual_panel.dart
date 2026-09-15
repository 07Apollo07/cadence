import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/theme/app_colors.dart';
import 'gps_controller.dart';

class TargetActualPanel extends ConsumerStatefulWidget {
  const TargetActualPanel({super.key});

  @override
  ConsumerState<TargetActualPanel> createState() => _TargetActualPanelState();
}

class _TargetActualPanelState extends ConsumerState<TargetActualPanel> {
  bool _isTargetExpanded = false;
  FixedExtentScrollController? _scrollController;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _toggleTargetExpanded() {
    setState(() {
      _isTargetExpanded = !_isTargetExpanded;
      if (_isTargetExpanded) {
        final target = ref.read(cadenceProvider).targetCadence;
        final itemIndex = (target - 60).clamp(0, 180);
        _scrollController?.dispose();
        _scrollController = FixedExtentScrollController(initialItem: itemIndex);
      }
    });
  }

  void _selectTarget(int cadence) {
    HapticFeedback.selectionClick();
    ref.read(cadenceProvider.notifier).setTargetCadence(cadence);
    setState(() {
      _isTargetExpanded = false;
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cadenceState = ref.watch(cadenceProvider);
    final gpsState = ref.watch(gpsControllerProvider);

    final target = cadenceState.targetCadence;
    final actual = gpsState.actualCadenceSpm;
    final delta = actual - target;

    Color deltaColor = AppColors.textPrimary;
    String deltaText = 'On Target';
    if (gpsState.isPaused) {
      deltaText = 'Session Paused';
      deltaColor = Colors.orange;
    } else if (gpsState.isSessionActive &&
        (!gpsState.isGpsEnabled || gpsState.isGpsDropped)) {
      deltaText = gpsState.isGpsDropped ? 'GPS Signal Dropped' : 'GPS Disabled';
      deltaColor = AppColors.statusDanger;
    } else if (actual > 0) {
      if (delta > 2) {
        deltaText = '+${delta.toStringAsFixed(0)} SPM (Fast)';
        deltaColor = AppColors.traceHot;
      } else if (delta < -2) {
        deltaText = '${delta.toStringAsFixed(0)} SPM (Slow)';
        deltaColor = AppColors.statusDanger;
      } else {
        deltaText = 'On Target';
        deltaColor = AppColors.traceCalm;
      }
    } else {
      if (!gpsState.isSessionActive) {
        deltaText = 'Ready';
        deltaColor = AppColors.textMuted;
      } else if (!gpsState.hasReceivedAnyFix) {
        deltaText = 'Searching for GPS signal...';
        deltaColor = AppColors.textMuted;
      } else if (gpsState.lastRawAccuracy != null &&
          gpsState.lastRawAccuracy! > 20.0) {
        deltaText =
            'Accuracy: ${gpsState.lastRawAccuracy!.toStringAsFixed(0)}m (Need <20m)';
        deltaColor = AppColors.statusDanger;
      } else {
        deltaText = 'GPS Locked (Standing still / ready)';
        deltaColor = AppColors.traceCalm;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModePicker(context, ref, cadenceState),
              Container(width: 1, height: 40, color: AppColors.hairline),
              _buildTargetPicker(context, ref, target, cadenceState),
              Container(width: 1, height: 40, color: AppColors.hairline),
              _buildMetricColumn(
                'Actual',
                actual > 0 ? actual.toStringAsFixed(0) : '--',
                'SPM',
                cadenceState.activeColor,
              ),
              Container(width: 1, height: 40, color: AppColors.hairline),
              _buildMetricColumn(
                'Distance',
                gpsState.distanceKm.toStringAsFixed(2),
                'km',
                AppColors.textPrimary,
              ),
            ],
          ),
          if (gpsState.isSessionActive) ...[
            const SizedBox(height: 12),
            Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeColumn(
                  'Moving',
                  _formatDuration(gpsState.movingDuration),
                  AppColors.textPrimary,
                ),
                Container(width: 1, height: 28, color: AppColors.hairline),
                _buildTimeColumn(
                  'Idle',
                  _formatDuration(gpsState.idleDuration),
                  gpsState.idleDuration.inSeconds > 0
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
                Container(width: 1, height: 28, color: AppColors.hairline),
                _buildTimeColumn(
                  'Pause',
                  _formatDuration(gpsState.pauseDuration),
                  gpsState.pauseDuration.inSeconds > 0
                      ? Colors.orange
                      : AppColors.textMuted,
                ),
                Container(width: 1, height: 28, color: AppColors.hairline),
                _buildTimeColumn(
                  'Pace',
                  gpsState.currentSpeedKmH > 0
                      ? '${(60.0 / gpsState.currentSpeedKmH).toStringAsFixed(1)} min/km'
                      : '--',
                  AppColors.textPrimary,
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Divider(color: AppColors.hairline, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gpsState.isSessionActive
                    ? 'Total: ${_formatDuration(gpsState.totalDuration)}'
                    : 'GPS Outdoor Mode',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                deltaText,
                style: TextStyle(
                  color: deltaColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (gpsState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              gpsState.errorMessage!,
              style: const TextStyle(
                color: AppColors.statusDanger,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricColumn(
    String label,
    String value,
    String unit,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetPicker(
    BuildContext context,
    WidgetRef ref,
    int target,
    CadenceState cadenceState,
  ) {
    if (!_isTargetExpanded) {
      return GestureDetector(
        onTap: _toggleTargetExpanded,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Target',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.edit, size: 12, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$target',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'SPM',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isTargetExpanded = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Target',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle, size: 16, color: AppColors.traceCalm),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: cadenceState.activeColor.withValues(alpha: 0.5),
              ),
            ),
            child: ListWheelScrollView.useDelegate(
              itemExtent: 38,
              perspective: 0.003,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              controller: _scrollController ??= FixedExtentScrollController(
                initialItem: (target - 60).clamp(0, 180),
              ),
              onSelectedItemChanged: (index) {
                final newCadence = 60 + index;
                HapticFeedback.selectionClick();
                ref.read(cadenceProvider.notifier).setTargetCadence(newCadence);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final cadence = 60 + index;
                  if (cadence < 60 || cadence > 240) return null;
                  final isSelected = cadence == target;
                  return GestureDetector(
                    onTap: () => _selectTarget(cadence),
                    child: Center(
                      child: Text(
                        '$cadence',
                        style: TextStyle(
                          color: isSelected ? cadenceState.activeColor : AppColors.textMuted,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: isSelected ? 14 : 11,
                        ),
                      ),
                    ),
                  );
                },
                childCount: 181,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildModePicker(
    BuildContext context,
    WidgetRef ref,
    CadenceState cadenceState,
  ) {
    return Column(
      children: [
        const Text(
          'Mode',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          width: 75,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: cadenceState.activeColor.withValues(alpha: 0.5),
            ),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 38,
            perspective: 0.003,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(
              initialItem: cadenceState.movementMode.index,
            ),
            onSelectedItemChanged: (index) {
              final mode = MovementMode.values[index];
              HapticFeedback.selectionClick();
              ref.read(cadenceProvider.notifier).setMovementMode(mode);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index >= MovementMode.values.length) return null;
                final mode = MovementMode.values[index];
                final isSelected = mode == cadenceState.movementMode;
                String label;
                Color color;
                switch (mode) {
                  case MovementMode.walking:
                    label = 'WALK';
                    color = cadenceState.walkColor;
                    break;
                  case MovementMode.jogging:
                    label = 'JOG';
                    color = cadenceState.jogColor;
                    break;
                  case MovementMode.running:
                    label = 'RUN';
                    color = cadenceState.runColor;
                    break;
                }
                return Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? color : AppColors.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: isSelected ? 13 : 11,
                    ),
                  ),
                );
              },
              childCount: MovementMode.values.length,
            ),
          ),
        ),
      ],
    );
  }
}
