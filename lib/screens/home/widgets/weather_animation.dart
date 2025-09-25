import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
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
  late AnimationController _snowController;
  late AnimationController _cloudController;
  final List<RainDrop> _rainDrops = [];
  final List<SnowFlake> _snowFlakes = [];
  final List<Cloud> _clouds = [];

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _lightRainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _heavyRainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _snowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _cloudController = AnimationController(
      duration: const Duration(milliseconds: 30000),
      vsync: this,
    );

    _initializeParticles();
    _startAnimations();
  }

  void _initializeParticles() {
    _rainDrops.clear();
    _snowFlakes.clear();
    _clouds.clear();

    final random = Random();

    // Initialize rain drops
    for (int i = 0; i < 150; i++) {
      _rainDrops.add(RainDrop(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.8 + random.nextDouble() * 0.4,
        length: 15 + random.nextDouble() * 25,
        opacity: 0.3 + random.nextDouble() * 0.7,
        thickness: 1.0 + random.nextDouble() * 2.0,
      ));
    }

    // Initialize snow flakes
    for (int i = 0; i < 100; i++) {
      _snowFlakes.add(SnowFlake(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.1 + random.nextDouble() * 0.3,
        size: 2 + random.nextDouble() * 6,
        opacity: 0.4 + random.nextDouble() * 0.6,
        sway: random.nextDouble() * 0.02,
      ));
    }

    // Initialize clouds
    for (int i = 0; i < 5; i++) {
      _clouds.add(Cloud(
        x: random.nextDouble() * 1.2 - 0.1,
        y: 0.1 + random.nextDouble() * 0.4,
        speed: 0.0005 + random.nextDouble() * 0.002,
        scale: 0.6 + random.nextDouble() * 0.8,
        opacity: 0.1 + random.nextDouble() * 0.15, // 불투명도를 더 낮춤
      ));
    }
  }

  void _startAnimations() {
    if (widget.weatherType == WeatherType.rainy ||
        widget.weatherType == WeatherType.stormy) {
      _rainController.repeat();
      _lightRainController.repeat();
      _heavyRainController.repeat();
    }

    if (widget.weatherType == WeatherType.snowy) {
      _snowController.repeat();
    }

    if (widget.weatherType == WeatherType.cloudy ||
        widget.weatherType == WeatherType.foggy) {
      _cloudController.repeat();
    }
  }

  @override
  void didUpdateWidget(WeatherAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weatherType != widget.weatherType) {
      _stopAllAnimations();
      _startAnimations();
    }
  }

  void _stopAllAnimations() {
    _rainController.stop();
    _lightRainController.stop();
    _heavyRainController.stop();
    _snowController.stop();
    _cloudController.stop();
  }

  @override
  void dispose() {
    _rainController.dispose();
    _lightRainController.dispose();
    _heavyRainController.dispose();
    _snowController.dispose();
    _cloudController.dispose();
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
      case WeatherType.cloudy:
        return _buildCloudAnimation();
      case WeatherType.foggy:
        return _buildFogAnimation();
    }
  }

  Widget _buildRainAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rainController, _lightRainController, _heavyRainController]),
      builder: (context, child) => CustomPaint(
        painter: AppleStyleRainPainter(
          rainDrops: _rainDrops,
          animationValue: _rainController.value,
          lightAnimationValue: _lightRainController.value,
          heavyAnimationValue: _heavyRainController.value,
        ),
        size: Size.infinite,
      ),
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
    return AnimatedBuilder(
      animation: _snowController,
      builder: (context, child) => CustomPaint(
        painter: SnowPainter(
          snowFlakes: _snowFlakes,
          animationValue: _snowController.value,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildSunAnimation() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) => CustomPaint(
        painter: CloudPainter(
          clouds: _clouds,
          animationValue: _cloudController.value,
          isLightClouds: true,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildCloudAnimation() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) => CustomPaint(
        painter: CloudPainter(
          clouds: _clouds,
          animationValue: _cloudController.value,
          isLightClouds: false,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildFogAnimation() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) => CustomPaint(
        painter: FogPainter(
          animationValue: _cloudController.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// 애플 스타일 비 애니메이션을 위한 RainDrop 클래스
class RainDrop {
  double x;
  double y;
  final double speed;
  final double length;
  final double opacity;
  final double thickness;

  RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
    required this.thickness,
  });
}

// 눈송이 클래스
class SnowFlake {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;
  final double sway;

  SnowFlake({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.sway,
  });
}

// 구름 클래스
class Cloud {
  double x;
  final double y;
  final double speed;
  final double scale;
  final double opacity;

  Cloud({
    required this.x,
    required this.y,
    required this.speed,
    required this.scale,
    required this.opacity,
  });
}

// 애플 스타일 비 페인터
class AppleStyleRainPainter extends CustomPainter {
  final List<RainDrop> rainDrops;
  final double animationValue;
  final double lightAnimationValue;
  final double heavyAnimationValue;

  AppleStyleRainPainter({
    required this.rainDrops,
    required this.animationValue,
    required this.lightAnimationValue,
    required this.heavyAnimationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 애플 스타일의 더 realistic한 비 효과
    for (int i = 0; i < rainDrops.length; i++) {
      final drop = rainDrops[i];

      // 각 애니메이션 컨트롤러에 따라 다른 속도로 움직임
      double animValue;
      if (i % 3 == 0) {
        animValue = heavyAnimationValue;
      } else if (i % 3 == 1) {
        animValue = animationValue;
      } else {
        animValue = lightAnimationValue;
      }

      // 빗방울 위치 계산 (더 자연스러운 움직임)
      final currentY = (drop.y + animValue * drop.speed * 2) % 1.2 - 0.1;
      final currentX = drop.x + sin(animValue * 2 * pi + i) * 0.01; // 바람 효과

      // 화면 밖에 있으면 그리지 않음
      if (currentY < -0.1 || currentY > 1.1) continue;

      final startPoint = Offset(
        currentX * size.width,
        currentY * size.height
      );

      final endPoint = Offset(
        (currentX + 0.02) * size.width,
        (currentY + drop.length / size.height) * size.height,
      );

      // 빗방울 그라데이션 효과
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          startPoint,
          endPoint,
          [
            Colors.white.withValues(alpha: drop.opacity * 0.8),
            Colors.white.withValues(alpha: drop.opacity * 0.3),
            Colors.transparent,
          ],
          [0.0, 0.7, 1.0],
        )
        ..strokeWidth = drop.thickness
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startPoint, endPoint, paint);

      // 물방울 끝부분에 작은 원 효과 (더 realistic함)
      if (drop.thickness > 1.5) {
        canvas.drawCircle(
          endPoint,
          drop.thickness * 0.8,
          Paint()
            ..color = Colors.white.withValues(alpha: drop.opacity * 0.4)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.0),
        );
      }
    }

    // 바닥 물튀김 효과
    _drawSplashEffects(canvas, size);
  }

  void _drawSplashEffects(Canvas canvas, Size size) {
    final random = Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final splashPhase = (animationValue + i * 0.1) % 1.0;
      final splashSize = (1.0 - splashPhase) * 4.0;

      if (splashSize > 0.5) {
        canvas.drawCircle(
          Offset(x, size.height - 5 + random.nextDouble() * 10),
          splashSize,
          Paint()
            ..color = Colors.white.withValues(alpha: (1.0 - splashPhase) * 0.3)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0),
        );
      }
    }
  }

  @override
  bool shouldRepaint(AppleStyleRainPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.lightAnimationValue != lightAnimationValue ||
           oldDelegate.heavyAnimationValue != heavyAnimationValue;
  }
}

// 눈 페인터
class SnowPainter extends CustomPainter {
  final List<SnowFlake> snowFlakes;
  final double animationValue;

  SnowPainter({
    required this.snowFlakes,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final flake in snowFlakes) {
      final currentY = (flake.y + animationValue * flake.speed) % 1.2 - 0.1;
      final swayOffset = sin(animationValue * 2 * pi + flake.sway * 100) * flake.sway;
      final currentX = flake.x + swayOffset;

      if (currentY < -0.1 || currentY > 1.1) continue;

      final center = Offset(
        currentX * size.width,
        currentY * size.height,
      );

      // 눈송이 그리기 (6각형 모양)
      _drawSnowFlake(canvas, center, flake.size, flake.opacity);
    }
  }

  void _drawSnowFlake(Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // 6각형 눈송이 그리기
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final x = center.dx + cos(angle) * size;
      final y = center.dy + sin(angle) * size;
      canvas.drawLine(center, Offset(x, y), paint);

      // 작은 가지들
      final branchX = center.dx + cos(angle) * size * 0.6;
      final branchY = center.dy + sin(angle) * size * 0.6;
      final branchAngle1 = angle + pi / 6;
      final branchAngle2 = angle - pi / 6;

      canvas.drawLine(
        Offset(branchX, branchY),
        Offset(branchX + cos(branchAngle1) * size * 0.3, branchY + sin(branchAngle1) * size * 0.3),
        paint,
      );
      canvas.drawLine(
        Offset(branchX, branchY),
        Offset(branchX + cos(branchAngle2) * size * 0.3, branchY + sin(branchAngle2) * size * 0.3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// 구름 페인터
class CloudPainter extends CustomPainter {
  final List<Cloud> clouds;
  final double animationValue;
  final bool isLightClouds;

  CloudPainter({
    required this.clouds,
    required this.animationValue,
    required this.isLightClouds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final cloud in clouds) {
      final currentX = (cloud.x + animationValue * cloud.speed) % 1.3 - 0.1;

      if (currentX < -0.2 || currentX > 1.2) continue;

      final center = Offset(
        currentX * size.width,
        cloud.y * size.height,
      );

      _drawCloud(canvas, center, cloud.scale * size.width * 0.3, cloud.opacity);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()
      ..color = (isLightClouds ? Colors.white : Colors.grey.shade300)
          .withValues(alpha: opacity * 0.4) // 전체적으로 훨씬 더 투명하게
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12.0); // 블러 효과 증가

    // 구름 모양을 여러 원으로 구성
    final cloudParts = [
      Offset(center.dx - size * 0.3, center.dy),
      Offset(center.dx - size * 0.1, center.dy - size * 0.2),
      Offset(center.dx + size * 0.1, center.dy - size * 0.1),
      Offset(center.dx + size * 0.3, center.dy),
      Offset(center.dx, center.dy + size * 0.1),
    ];

    final radii = [size * 0.4, size * 0.3, size * 0.35, size * 0.4, size * 0.25];

    for (int i = 0; i < cloudParts.length; i++) {
      canvas.drawCircle(cloudParts[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// 안개 페인터
class FogPainter extends CustomPainter {
  final double animationValue;

  FogPainter({
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20.0);

    // 여러 층의 안개 효과
    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.2 + i * 0.15);
      final opacity = 0.05 + sin(animationValue * 2 * pi + i) * 0.03; // 안개 불투명도 감소

      paint.shader = ui.Gradient.linear(
        Offset(0, y - 30),
        Offset(0, y + 30),
        [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: opacity),
          Colors.white.withValues(alpha: 0.0),
        ],
      );

      canvas.drawRect(
        Rect.fromLTWH(
          -size.width * 0.1,
          y - 30,
          size.width * 1.2,
          60,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FogPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// 기존 RainPainter는 호환성을 위해 유지
class RainPainter extends CustomPainter {
  final double animation;
  final int density;
  final double opacity;
  final double dropLength;
  final double speed;
  final Random _random = Random(42);

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

    for (int i = 0; i < density; i++) {
      final x = _random.nextDouble() * size.width;
      final baseY = _random.nextDouble() * size.height;
      final animationOffset = (animation * size.height * speed * 2) % (size.height + 100);
      final y = (baseY + animationOffset) % (size.height + 100) - 50;
      final currentDropLength = dropLength + _random.nextDouble() * 10;
      final angle = -0.1 + _random.nextDouble() * 0.2;

      final startPoint = Offset(x + angle * y, y);
      final endPoint = Offset(x + angle * (y + currentDropLength), y + currentDropLength);

      if (startPoint.dy < size.height && startPoint.dy > -currentDropLength) {
        canvas.drawLine(startPoint, endPoint, paint);
      }
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}