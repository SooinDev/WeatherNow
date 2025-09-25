import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../../../models/weather_model.dart';

class WindCompass extends StatefulWidget {
  final WeatherModel weather;

  const WindCompass({
    super.key,
    required this.weather,
  });

  @override
  State<WindCompass> createState() => _WindCompassState();
}

class _WindCompassState extends State<WindCompass>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: _getWindAngle(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '바람 정보',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2.0,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              // 나침반
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 180.w,
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CompassPainter(
                          windDirection: _rotationAnimation.value,
                          windSpeed: widget.weather.windSpeed,
                        ),
                        size: Size(180.w, 180.w),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              // 풍속 정보
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWindInfo('풍속', '${widget.weather.windSpeed.toStringAsFixed(1)}m/s'),
                    SizedBox(height: 12.h),
                    _buildWindInfo('풍향', _getWindDirectionText()),
                    SizedBox(height: 12.h),
                    _buildWindInfo('등급', _getWindSpeedLevel()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWindInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2.0,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2.0,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getWindAngle() {
    // OpenWeather API의 풍향은 바람이 불어오는 방향을 나타냄 (meteorological convention)
    // 0도 = 북쪽에서 불어옴, 90도 = 동쪽에서 불어옴
    return widget.weather.windDirection ?? 0.0;
  }

  String _getWindDirectionText() {
    final angle = _getWindAngle();
    if (angle >= 0 && angle < 22.5) return '북';
    if (angle >= 22.5 && angle < 67.5) return '북동';
    if (angle >= 67.5 && angle < 112.5) return '동';
    if (angle >= 112.5 && angle < 157.5) return '남동';
    if (angle >= 157.5 && angle < 202.5) return '남';
    if (angle >= 202.5 && angle < 247.5) return '남서';
    if (angle >= 247.5 && angle < 292.5) return '서';
    if (angle >= 292.5 && angle < 337.5) return '북서';
    return '북';
  }

  String _getWindSpeedLevel() {
    final speed = widget.weather.windSpeed;
    if (speed < 1.8) return '고요함';
    if (speed < 3.4) return '실바람';
    if (speed < 5.5) return '남실바람';
    if (speed < 8.0) return '산들바람';
    if (speed < 10.8) return '건들바람';
    if (speed < 13.9) return '흔들바람';
    if (speed < 17.2) return '된바람';
    if (speed < 20.8) return '센바람';
    if (speed < 24.5) return '큰바람';
    if (speed < 28.5) return '큰센바람';
    if (speed < 32.7) return '노대바람';
    return '왕바람';
  }
}

class CompassPainter extends CustomPainter {
  final double windDirection;
  final double windSpeed;

  CompassPainter({
    required this.windDirection,
    required this.windSpeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 나침반 배경
    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawCircle(center, radius, borderPaint);

    // 방향 표시 (N, E, S, W)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < directions.length; i++) {
      final angle = angles[i] * math.pi / 180;
      final directionOffset = Offset(
        center.dx + (radius - 15) * math.sin(angle),
        center.dy - (radius - 15) * math.cos(angle),
      );

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          directionOffset.dx - textPainter.width / 2,
          directionOffset.dy - textPainter.height / 2,
        ),
      );
    }

    // 작은 방향 표시선
    final smallLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (int i = 0; i < 360; i += 30) {
      final angle = i * math.pi / 180;
      final startRadius = radius - 10;
      final endRadius = radius - 5;

      final start = Offset(
        center.dx + startRadius * math.sin(angle),
        center.dy - startRadius * math.cos(angle),
      );
      final end = Offset(
        center.dx + endRadius * math.sin(angle),
        center.dy - endRadius * math.cos(angle),
      );

      canvas.drawLine(start, end, smallLinePaint);
    }

    // 바람 화살표
    if (windSpeed > 0) {
      final arrowPaint = Paint()
        ..color = _getWindSpeedColor()
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final arrowAngle = windDirection * math.pi / 180;
      final arrowLength = radius * 0.6;

      // 화살표 몸체
      final arrowEnd = Offset(
        center.dx + arrowLength * math.sin(arrowAngle),
        center.dy - arrowLength * math.cos(arrowAngle),
      );

      canvas.drawLine(center, arrowEnd, arrowPaint);

      // 화살표 머리
      final headLength = 15.0;
      final headAngle = math.pi / 6;

      final head1 = Offset(
        arrowEnd.dx - headLength * math.sin(arrowAngle + headAngle),
        arrowEnd.dy + headLength * math.cos(arrowAngle + headAngle),
      );

      final head2 = Offset(
        arrowEnd.dx - headLength * math.sin(arrowAngle - headAngle),
        arrowEnd.dy + headLength * math.cos(arrowAngle - headAngle),
      );

      canvas.drawLine(arrowEnd, head1, arrowPaint);
      canvas.drawLine(arrowEnd, head2, arrowPaint);
    }

    // 중앙 점
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, centerPaint);
  }

  Color _getWindSpeedColor() {
    if (windSpeed < 3.0) return Colors.green;
    if (windSpeed < 7.0) return Colors.yellow;
    if (windSpeed < 12.0) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is! CompassPainter ||
        oldDelegate.windDirection != windDirection ||
        oldDelegate.windSpeed != windSpeed;
  }
}