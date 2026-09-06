import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class KnurledBar extends StatefulWidget {
  final ValueChanged<double> onVerticalDragUpdate;

  const KnurledBar({super.key, required this.onVerticalDragUpdate});

  @override
  State<KnurledBar> createState() => _KnurledBarState();
}

class _KnurledBarState extends State<KnurledBar> {
  bool _isDragging = false;
  double _scrollOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (_) => setState(() => _isDragging = true),
      onVerticalDragUpdate: (details) {
        setState(() {
          _scrollOffset -= details.delta.dy;
        });
        widget.onVerticalDragUpdate(details.delta.dy);
      },
      onVerticalDragEnd: (_) => setState(() => _isDragging = false),
      onVerticalDragCancel: () => setState(() => _isDragging = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 35,
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C2C35),
              Color(0xFF161619),
              Color(0xFF0A0A0C),
            ],
          ),
          border: Border.all(
            color: _isDragging ? AppColors.traceCalm : const Color(0xFF4A4A58),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.traceCalm.withValues(
                alpha: _isDragging ? 0.45 : 0.15,
              ),
              blurRadius: _isDragging ? 16 : 8,
              spreadRadius: _isDragging ? 2 : 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.9),
              blurRadius: 10,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.5),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // CustomPainter for smooth 60fps roller ridges & 3D cylinder shading
              Positioned.fill(
                child: CustomPaint(
                  painter: KnurledRollerPainter(scrollOffset: _scrollOffset),
                ),
              ),
              // Center Neon Laser Ring / Indicator
              Container(
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.traceCalm,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.traceCalm,
                      blurRadius: _isDragging ? 14 : 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KnurledRollerPainter extends CustomPainter {
  final double scrollOffset;

  KnurledRollerPainter({required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const double itemHeight = 12.0;
    final int count = (size.height / itemHeight).ceil() + 4;
    final double startY = (scrollOffset % itemHeight) - itemHeight;

    for (int i = -2; i < count; i++) {
      final double y = startY + (i * itemHeight);

      // Ridge rect
      final rect = Rect.fromLTWH(3, y + 2, size.width - 6, 7);

      // Bevel shadow / highlight
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.shift(const Offset(0, 1)),
          const Radius.circular(2),
        ),
        shadowPaint,
      );

      final ridgePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A4A58), Color(0xFF222228), Color(0xFF111114)],
        ).createShader(rect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        ridgePaint,
      );
    }

    // 3D Cylinder curvature shading overlay (left/right dark edges, specular center)
    final cylinderShader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color.fromRGBO(0, 0, 0, 0.65),
        Colors.transparent,
        Color.fromRGBO(255, 255, 255, 0.12),
        Colors.transparent,
        Color.fromRGBO(0, 0, 0, 0.75),
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    paint.shader = cylinderShader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant KnurledRollerPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset;
  }
}
