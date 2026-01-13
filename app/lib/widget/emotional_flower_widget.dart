import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show OrderingTerm, OrderingMode;
import '../core/db/app_database.dart';

/// A flower widget that displays the last 20 emotional check-ins as colored petals
class EmotionalFlowerWidget extends StatefulWidget {
  const EmotionalFlowerWidget({Key? key}) : super(key: key);

  @override
  State<EmotionalFlowerWidget> createState() => _EmotionalFlowerWidgetState();
}

class _EmotionalFlowerWidgetState extends State<EmotionalFlowerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<CheckInColorData> _emotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _loadEmotions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadEmotions() async {
    final db = AppDatabase();
    // Query the last 20 emotional check-ins, ordered by date and timestamp
    final query = db.select(db.checkInColors)
      ..orderBy([
        (t) => OrderingTerm(expression: t.checkInDate, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.ts, mode: OrderingMode.desc),
      ])
      ..limit(20);

    final results = await query.get();

    setState(() {
      _emotions = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_emotions.isEmpty) {
      return const Center(
        child: Text(
          'No emotional check-ins yet.\nStart tracking your emotions!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: FlowerPainter(
            emotions: _emotions,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class FlowerPainter extends CustomPainter {
  final List<CheckInColorData> emotions;
  final double animationValue;

  FlowerPainter({
    required this.emotions,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * 0.35;

    // Draw petals
    final petalCount = emotions.length;
    for (int i = 0; i < petalCount; i++) {
      final angle = (2 * math.pi * i) / petalCount;
      final emotion = emotions[i];

      // Create pulsing effect
      final pulseScale = 1.0 + (math.sin(animationValue * 2 * math.pi + angle) * 0.1);
      final petalRadius = baseRadius * 0.4 * pulseScale;

      // Calculate petal position
      final petalDistance = baseRadius * 0.8;
      final petalCenter = Offset(
        center.dx + math.cos(angle) * petalDistance,
        center.dy + math.sin(angle) * petalDistance,
      );

      // Draw petal
      final paint = Paint()
        ..color = Color(emotion.colorRgb).withOpacity(0.8)
        ..style = PaintingStyle.fill;

      // Draw petal as an ellipse rotated towards center
      canvas.save();
      canvas.translate(petalCenter.dx, petalCenter.dy);
      canvas.rotate(angle + math.pi / 2);

      final petalPath = Path()
        ..addOval(Rect.fromCenter(
          center: Offset.zero,
          width: petalRadius,
          height: petalRadius * 1.6,
        ));

      canvas.drawPath(petalPath, paint);

      // Add petal outline
      final outlinePaint = Paint()
        ..color = Color(emotion.colorRgb).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(petalPath, outlinePaint);

      canvas.restore();
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.25, centerPaint);

    // Add center detail
    final centerDetailPaint = Paint()
      ..color = Colors.orange.shade800
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final angle = (2 * math.pi * i) / 8;
      final dotDistance = baseRadius * 0.15;
      final dotCenter = Offset(
        center.dx + math.cos(angle) * dotDistance,
        center.dy + math.sin(angle) * dotDistance,
      );
      canvas.drawCircle(dotCenter, baseRadius * 0.04, centerDetailPaint);
    }
  }

  @override
  bool shouldRepaint(FlowerPainter oldDelegate) {
    return oldDelegate.emotions != emotions ||
        oldDelegate.animationValue != animationValue;
  }
}
