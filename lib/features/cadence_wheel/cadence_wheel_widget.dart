import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class CadenceWheelWidget extends StatelessWidget {
  final int currentCadence;
  final ValueChanged<int> onCadenceChanged;

  const CadenceWheelWidget({
    super.key,
    required this.currentCadence,
    required this.onCadenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 60,
        perspective: 0.003,
        diameterRatio: 1.8,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(
          initialItem: (currentCadence - 60).clamp(0, 180),
        ),
        onSelectedItemChanged: (index) {
          final newCadence = 60 + index;
          HapticFeedback.selectionClick();
          onCadenceChanged(newCadence);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final cadence = 60 + index;
            if (cadence < 60 || cadence > 240) return null;
            final isSelected = cadence == currentCadence;
            return Center(
              child: Text(
                '$cadence',
                style: TextStyle(
                  fontSize: isSelected ? 42 : 28,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.traceCalm : AppColors.textMuted,
                ),
              ),
            );
          },
          childCount: 181,
        ),
      ),
    );
  }
}
