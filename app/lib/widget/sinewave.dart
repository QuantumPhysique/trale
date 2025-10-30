// dart
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';

class SineWave extends StatefulWidget {
  const SineWave({
    super.key,
    this.amplitude = 4,  // 3 is pb default
    this.wavelength = 40,
    this.speed = 10,
    this.strokeWidth = 2,  // 4 is pb default
    this.sampleStep = 2, // larger = cheaper sampling
    this.color,
  });

  final double amplitude;
  final double wavelength;
  final double speed;
  final Color? color;
  final double strokeWidth;
  final double sampleStep;

  @override
  State<SineWave> createState() => _SineWaveState();
}

class _SineWaveState extends State<SineWave> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final DateTime _start;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(() => setState(() {}))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _elapsedSeconds => DateTime.now().difference(_start).inMilliseconds / 1000.0;

  @override
  Widget build(BuildContext context) {
    final double height = widget.amplitude + widget.strokeWidth +
      4 * TraleTheme.of(context)!.padding;
    final double pad = TraleTheme.of(context)!.padding;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OverflowBox(
        maxWidth: MediaQuery.of(context).size.width + 2 * pad,
        alignment: Alignment.centerLeft,
        child: Transform.translate(
          offset: Offset(-2 * pad, 0),
          child: SizedBox(
            height: height,
            width: MediaQuery.of(context).size.width * 2 * pad,
            child: CustomPaint(
              painter: SineWavePainter(
                amplitude: widget.amplitude,
                wavelength: widget.wavelength,
                speed: widget.speed,
                elapsed: _elapsedSeconds,
                color: widget.color ?? Theme.of(context).colorScheme.primary,
                strokeWidth: widget.strokeWidth,
                sampleStep: widget.sampleStep,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// dart


class SineWavePainter extends CustomPainter {
  SineWavePainter({
    required this.amplitude,
    required this.wavelength,
    required this.speed,
    required this.elapsed,
    required this.color,
    required this.strokeWidth,
    required this.sampleStep,
  });

  final double amplitude;
  final double wavelength;
  final double speed;
  final double elapsed;
  final Color color;
  final double strokeWidth;
  final double sampleStep;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final Path path = Path();
    final double centerY = size.height / 2;
    final double k = 2 * pi / wavelength;
    final double offset = speed * elapsed; // moves wave to the right

    bool started = false;
    for (double x = 0; x <= size.width; x += sampleStep) {
      final double y = centerY + amplitude * sin(k * (x - offset));
      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SineWavePainter old) {
    return old.elapsed != elapsed
        || old.amplitude != amplitude
        || old.wavelength != wavelength
        || old.color != color
        || old.strokeWidth != strokeWidth;
  }
}