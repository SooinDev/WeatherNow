import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

class RainTextBox extends StatefulWidget {
  final Widget child;
  final bool enableRainEffect;
  final double rainIntensity;

  const RainTextBox({
    super.key,
    required this.child,
    this.enableRainEffect = true,
    this.rainIntensity = 1.0,
  });

  @override
  State<RainTextBox> createState() => _RainTextBoxState();
}

class _RainTextBoxState extends State<RainTextBox>
    with TickerProviderStateMixin {
  late AnimationController _dropletController;
  late AnimationController _flowController;
  late AnimationController _impactController;

  final List<WaterDroplet> _droplets = [];
  final List<WaterFlow> _flows = [];
  final List<ImpactEffect> _impacts = [];


  @override
  void initState() {
    super.initState();

    _dropletController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _flowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _impactController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.enableRainEffect) {
      _dropletController.repeat();
      _flowController.repeat();
      _impactController.repeat();

      _initializeEffects();
      _startPeriodicEffects();
    }

  }


  void _initializeEffects() {
    final random = Random();

    // Initialize water droplets
    for (int i = 0; i < 20; i++) {
      _droplets.add(WaterDroplet(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.3, // Start from top area
        size: 2 + random.nextDouble() * 4,
        opacity: 0.6 + random.nextDouble() * 0.4,
        speed: 0.5 + random.nextDouble() * 0.5,
        phase: random.nextDouble() * 2 * pi,
      ));
    }
  }

  void _startPeriodicEffects() {
    // 주기적으로 새로운 효과들 생성
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _createNewDroplet();
        _createWaterFlow();
        _createImpactEffect();

        Future.delayed(
          Duration(milliseconds: 100 + Random().nextInt(200)),
          _startPeriodicEffects,
        );
      }
    });
  }

  void _createNewDroplet() {
    if (_droplets.length < 30) {
      final random = Random();
      _droplets.add(WaterDroplet(
        x: random.nextDouble(),
        y: -0.1,
        size: 2 + random.nextDouble() * 4,
        opacity: 0.6 + random.nextDouble() * 0.4,
        speed: 0.5 + random.nextDouble() * 0.5,
        phase: random.nextDouble() * 2 * pi,
      ));
    }
  }

  void _createWaterFlow() {
    if (_flows.length < 5 && Random().nextDouble() < 0.3) {
      final random = Random();
      _flows.add(WaterFlow(
        startX: random.nextDouble(),
        startY: 0.0,
        endX: random.nextDouble(),
        endY: 1.0,
        width: 1 + random.nextDouble() * 2,
        opacity: 0.4 + random.nextDouble() * 0.3,
        speed: 0.8 + random.nextDouble() * 0.4,
        phase: random.nextDouble() * 2 * pi,
      ));
    }
  }

  void _createImpactEffect() {
    if (_impacts.length < 8 && Random().nextDouble() < 0.4) {
      final random = Random();
      _impacts.add(ImpactEffect(
        x: random.nextDouble(),
        y: random.nextDouble(),
        maxRadius: 4 + random.nextDouble() * 6,
        opacity: 0.5 + random.nextDouble() * 0.3,
        phase: 0.0,
      ));
    }
  }

  @override
  void didUpdateWidget(RainTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableRainEffect != oldWidget.enableRainEffect) {
      if (widget.enableRainEffect) {
        _dropletController.repeat();
        _flowController.repeat();
        _impactController.repeat();
      } else {
        _dropletController.stop();
        _flowController.stop();
        _impactController.stop();
      }
    }
  }

  @override
  void dispose() {
    _dropletController.dispose();
    _flowController.dispose();
    _impactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Original text box
        widget.child,

        // Rain effects overlay
        if (widget.enableRainEffect)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _dropletController,
                  _flowController,
                  _impactController,
                ]),
                builder: (context, child) => LayoutBuilder(
                  builder: (context, constraints) => CustomPaint(
                    painter: RainTextBoxPainter(
                      droplets: _droplets,
                      flows: _flows,
                      impacts: _impacts,
                      dropletAnimation: _dropletController.value,
                      flowAnimation: _flowController.value,
                      impactAnimation: _impactController.value,
                      intensity: widget.rainIntensity,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class WaterDroplet {
  double x;
  double y;
  final double size;
  final double opacity;
  final double speed;
  final double phase;

  WaterDroplet({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.phase,
  });
}

class WaterFlow {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double width;
  final double opacity;
  final double speed;
  final double phase;

  WaterFlow({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.width,
    required this.opacity,
    required this.speed,
    required this.phase,
  });
}

class ImpactEffect {
  final double x;
  final double y;
  final double maxRadius;
  final double opacity;
  double phase;

  ImpactEffect({
    required this.x,
    required this.y,
    required this.maxRadius,
    required this.opacity,
    required this.phase,
  });
}

class RainTextBoxPainter extends CustomPainter {
  final List<WaterDroplet> droplets;
  final List<WaterFlow> flows;
  final List<ImpactEffect> impacts;
  final double dropletAnimation;
  final double flowAnimation;
  final double impactAnimation;
  final double intensity;

  RainTextBoxPainter({
    required this.droplets,
    required this.flows,
    required this.impacts,
    required this.dropletAnimation,
    required this.flowAnimation,
    required this.impactAnimation,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawWaterFlows(canvas, size);
    _drawWaterDroplets(canvas, size);
    _drawImpactEffects(canvas, size);
  }

  void _drawWaterDroplets(Canvas canvas, Size size) {
    for (int i = 0; i < droplets.length; i++) {
      final droplet = droplets[i];

      // Update droplet position
      final currentY = (droplet.y + dropletAnimation * droplet.speed * 2) % 1.2 - 0.1;
      final swayX = sin(dropletAnimation * 4 * pi + droplet.phase) * 0.02;
      final currentX = droplet.x + swayX;

      if (currentY < -0.1 || currentY > 1.1) continue;

      final center = Offset(
        currentX * size.width,
        currentY * size.height,
      );

      // Realistic water droplet with gradient
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: droplet.opacity * 0.9),
            Colors.white.withValues(alpha: droplet.opacity * 0.6),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: droplet.size))
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.0);

      canvas.drawCircle(center, droplet.size, paint);

      // Highlight effect
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: droplet.opacity * 0.4);

      canvas.drawCircle(
        Offset(center.dx - droplet.size * 0.3, center.dy - droplet.size * 0.3),
        droplet.size * 0.3,
        highlightPaint,
      );
    }
  }

  void _drawWaterFlows(Canvas canvas, Size size) {
    for (int i = 0; i < flows.length; i++) {
      final flow = flows[i];

      final progress = (flowAnimation + flow.phase) % 1.0;
      final currentLength = progress * 0.8; // Flow doesn't cover entire height

      if (currentLength < 0.1) continue;

      final startPoint = Offset(
        flow.startX * size.width,
        flow.startY * size.height,
      );

      final endPoint = Offset(
        (flow.startX + (flow.endX - flow.startX) * currentLength) * size.width,
        currentLength * size.height,
      );

      // Water flow with gradient
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          startPoint,
          endPoint,
          [
            Colors.transparent,
            Colors.white.withValues(alpha: flow.opacity * 0.6),
            Colors.white.withValues(alpha: flow.opacity * 0.8),
            Colors.white.withValues(alpha: flow.opacity * 0.4),
            Colors.transparent,
          ],
          [0.0, 0.2, 0.5, 0.8, 1.0],
        )
        ..strokeWidth = flow.width
        ..strokeCap = StrokeCap.round
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 0.5);

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  void _drawImpactEffects(Canvas canvas, Size size) {
    for (int i = 0; i < impacts.length; i++) {
      final impact = impacts[i];

      // Update impact phase
      impact.phase = (impact.phase + 0.05) % 1.0;

      final radius = impact.maxRadius * impact.phase;
      final opacity = impact.opacity * (1.0 - impact.phase);

      if (opacity < 0.05) continue;

      final center = Offset(
        impact.x * size.width,
        impact.y * size.height,
      );

      // Ripple effect
      final ripplePaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.0);

      canvas.drawCircle(center, radius, ripplePaint);

      // Inner splash
      if (impact.phase < 0.5) {
        final splashPaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.8)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);

        canvas.drawCircle(center, radius * 0.3, splashPaint);
      }
    }

    // Remove completed impacts
    impacts.removeWhere((impact) => impact.phase >= 0.95);
  }

  @override
  bool shouldRepaint(RainTextBoxPainter oldDelegate) {
    return oldDelegate.dropletAnimation != dropletAnimation ||
           oldDelegate.flowAnimation != flowAnimation ||
           oldDelegate.impactAnimation != impactAnimation;
  }
}