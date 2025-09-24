import 'package:flutter/material.dart';
import 'dart:math';
import '../../../models/weather_model.dart';

class WeatherAnimation extends StatefulWidget {
  final WeatherType weatherType;
  final double opacity;

  const WeatherAnimation({
    super.key,
    required this.weatherType,
    this.opacity = 1.0,
  });

  @override
  State<WeatherAnimation> createState() => _WeatherAnimationState();
}

class _WeatherAnimationState extends State<WeatherAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _lightRainController;
  late AnimationController _heavyRainController;

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _lightRainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _heavyRainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    if (widget.weatherType == WeatherType.rainy ||
        widget.weatherType == WeatherType.stormy) {
      _rainController.repeat();
      _lightRainController.repeat();
      _heavyRainController.repeat();
    }
  }

  @override
  void didUpdateWidget(WeatherAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weatherType == WeatherType.rainy ||
        widget.weatherType == WeatherType.stormy) {
      if (!_rainController.isAnimating) {
        _rainController.repeat();
        _lightRainController.repeat();
        _heavyRainController.repeat();
      }
    } else {
      _rainController.stop();
      _lightRainController.stop();
      _heavyRainController.stop();
    }
  }

  @override
  void dispose() {
    _rainController.dispose();
    _lightRainController.dispose();
    _heavyRainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.opacity,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _buildWeatherAnimation(),
      ),
    );
  }

  Widget _buildWeatherAnimation() {
    switch (widget.weatherType) {
      case WeatherType.rainy:
        return _buildRainAnimation();
      case WeatherType.stormy:
        return _buildStormAnimation();
      case WeatherType.snowy:
        return _buildSnowAnimation();
      case WeatherType.sunny:
        return _buildSunAnimation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRainAnimation() {
    return Stack(
      children: [
        // Light rain drops
        AnimatedBuilder(
          animation: _lightRainController,
          builder: (context, child) => CustomPaint(
            painter: RainPainter(
              animation: _lightRainController.value,
              density: 50,
              opacity: 0.6,
              dropLength: 15,
              speed: 1.0,
            ),
            size: Size.infinite,
          ),
        ),
        // Medium rain drops
        AnimatedBuilder(
          animation: _rainController,
          builder: (context, child) => CustomPaint(
            painter: RainPainter(
              animation: _rainController.value,
              density: 80,
              opacity: 0.8,
              dropLength: 20,
              speed: 1.2,
            ),
            size: Size.infinite,
          ),
        ),
        // Heavy rain drops
        AnimatedBuilder(
          animation: _heavyRainController,
          builder: (context, child) => CustomPaint(
            painter: RainPainter(
              animation: _heavyRainController.value,
              density: 30,
              opacity: 1.0,
              dropLength: 25,
              speed: 1.5,
            ),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }

  Widget _buildStormAnimation() {
    return Stack(
      children: [
        _buildRainAnimation(),
        // Lightning effect could be added here
      ],
    );
  }

  Widget _buildSnowAnimation() {
    return Container(); // TODO: Implement snow animation
  }

  Widget _buildSunAnimation() {
    return Container(); // TODO: Implement sun animation
  }
}

class RainPainter extends CustomPainter {
  final double animation;
  final int density;
  final double opacity;
  final double dropLength;
  final double speed;
  final Random _random = Random(42); // Fixed seed for consistent pattern

  RainPainter({
    required this.animation,
    required this.density,
    required this.opacity,
    required this.dropLength,
    required this.speed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.7)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final heavyPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.9)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Create multiple layers of rain with different characteristics
    for (int i = 0; i < density; i++) {
      final x = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height;

      // Calculate drop position based on animation and speed
      final animationOffset = (animation * size.height * speed * 2) % (size.height + 100);
      final y = (baseY + animationOffset) % (size.height + 100) - 50;

      // Vary drop characteristics
      final currentDropLength = dropLength + _random.nextDouble() * 10;
      final angle = -0.1 + _random.nextDouble() * 0.2; // Slight wind effect

      // Different drop types for realism
      if (i % 5 == 0) {
        // Heavy drops
        final startPoint = Offset(x + angle * y, y);
        final endPoint = Offset(x + angle * (y + currentDropLength * 1.5), y + currentDropLength * 1.5);

        if (startPoint.dy < size.height && startPoint.dy > -currentDropLength) {
          canvas.drawLine(startPoint, endPoint, heavyPaint);
        }
      } else {
        // Normal drops
        final startPoint = Offset(x + angle * y, y);
        final endPoint = Offset(x + angle * (y + currentDropLength), y + currentDropLength);

        if (startPoint.dy < size.height && startPoint.dy > -currentDropLength) {
          canvas.drawLine(startPoint, endPoint, paint);
        }
      }
    }

    // Add some splash effects at the bottom
    _drawSplashes(canvas, size);
  }

  void _drawSplashes(Canvas canvas, Size size) {
    for (int i = 0; i < 20; i++) {
      final x = _random.nextDouble() * size.width;
      final splashSize = 2 + _random.nextDouble() * 3;
      final splashOpacity = 0.2 + _random.nextDouble() * 0.3;

      canvas.drawCircle(
        Offset(x, size.height - 10 + _random.nextDouble() * 10),
        splashSize,
        Paint()..color = Colors.white.withValues(alpha: splashOpacity * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
