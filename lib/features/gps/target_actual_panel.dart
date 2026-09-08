import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/theme/app_colors.dart';
import 'gps_controller.dart';

class TargetActualPanel extends ConsumerWidget {
  const TargetActualPanel({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
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
      } else if (gpsState.lastRawAccuracy != null && gpsState.lastRawAccuracy! > 20.0) {
        deltaText = 'Accuracy: ${gpsState.lastRawAccuracy!.toStringAsFixed(0)}m (Need <20m)';
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
              _buildMetricColumn('Target', '$target', 'SPM', AppColors.textPrimary),
              Container(width: 1, height: 40, color: AppColors.hairline),
              _buildMetricColumn(
                'Actual',
                actual > 0 ? actual.toStringAsFixed(0) : '--',
                'SPM',
                cadenceState.activeColor,
              ),
              Container(width: 1, height: 40, color: AppColors.hairline),
              _buildMetricColumn('Distance', gpsState.distanceKm.toStringAsFixed(2), 'km', AppColors.textPrimary),
            ],
          ),
          if (gpsState.isSessionActive) ...[
            const SizedBox(height: 12),
            Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeColumn('Moving', _formatDuration(gpsState.movingDuration), AppColors.textPrimary),
                Container(width: 1, height: 28, color: AppColors.hairline),
                _buildTimeColumn(
                  'Idle',
                  _formatDuration(gpsState.idleDuration),
                  gpsState.idleDuration.inSeconds > 0 ? AppColors.textPrimary : AppColors.textMuted,
                ),
                Container(width: 1, height: 28, color: AppColors.hairline),
                _buildTimeColumn(
                  'Pause',
                  _formatDuration(gpsState.pauseDuration),
                  gpsState.pauseDuration.inSeconds > 0 ? Colors.orange : AppColors.textMuted,
                ),
                Container(width: 1, height: 28, color: AppColors.hairline),
                _buildTimeColumn(
                  'Pace',
                  gpsState.currentSpeedKmH > 0 ? '${(60.0 / gpsState.currentSpeedKmH).toStringAsFixed(1)} min/km' : '--',
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
                gpsState.isSessionActive ? 'Total: ${_formatDuration(gpsState.totalDuration)}' : 'GPS Outdoor Mode',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              Text(
                deltaText,
                style: TextStyle(color: deltaColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          if (gpsState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              gpsState.errorMessage!,
              style: const TextStyle(color: AppColors.statusDanger, fontSize: 12),
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
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMetricColumn(String label, String value, String unit, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 2),
            Text(unit, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
