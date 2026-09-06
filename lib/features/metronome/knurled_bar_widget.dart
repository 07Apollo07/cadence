import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class KnurledBar extends StatelessWidget {
  final ValueChanged<double> onVerticalDragUpdate;

  const KnurledBar({super.key, required this.onVerticalDragUpdate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        onVerticalDragUpdate(details.delta.dy);
      },
      child: Container(
        width: 35,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF333333), Color(0xFF1A1A1A)],
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
                        ? [
                            AppColors.traceCalm,
                            AppColors.traceCalm.withValues(alpha: 0.7),
                          ]
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
}
