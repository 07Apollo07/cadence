import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/formulas/pace_formulas.dart';
import '../../core/theme/app_colors.dart';

class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  double _heightCm = 175.0;

  @override
  Widget build(BuildContext context) {
    ref.watch(cadenceProvider);
    final calculatedStride = PaceFormulas.estimateStrideLengthFromHeight(_heightCm);

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('Stride Calibration'),
        backgroundColor: AppColors.surfacePanel,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Height Calibration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adjust your height to estimate your optimal running stride length.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                '${_heightCm.toStringAsFixed(0)} cm',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.traceCalm),
              ),
            ),
            Slider(
              value: _heightCm,
              min: 120.0,
              max: 220.0,
              divisions: 100,
              activeColor: AppColors.traceCalm,
              inactiveColor: AppColors.hairline,
              onChanged: (val) {
                setState(() {
                  _heightCm = val;
                });
              },
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfacePanel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Stride Length:', style: TextStyle(color: AppColors.textMuted)),
                  Text('${calculatedStride.toStringAsFixed(2)} m', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ref.read(cadenceProvider.notifier).setStrideLength(calculatedStride);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stride length updated successfully!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.traceCalm,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('APPLY STRIDE LENGTH', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
