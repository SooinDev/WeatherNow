import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

class EnhancedRainTextBox extends StatefulWidget {
  final Widget child;
  final bool enableRainEffect;
  final double rainIntensity;

  const EnhancedRainTextBox({
    super.key,
    required this.child,
    this.enableRainEffect = true,
    this.rainIntensity = 1.0,
  });

  @override
  State<EnhancedRainTextBox> createState() => _EnhancedRainTextBoxState();
}

class _EnhancedRainTextBoxState extends State<EnhancedRainTextBox>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late AnimationController _physicsController;

  final List<EnhancedRainDrop> _rainDrops = [];
  final List<CollisionEffect> _collisions = [];
  final List<WaterTrail> _trails = [];
  final List<SplashParticle> _splashes = [];

  final GlobalKey _boxKey = GlobalKey();
  Rect? _boxBounds;

  @override
  void initState() {
    super.initState();

    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _secondaryController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _physicsController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    if (widget.enableRainEffect) {
      _initializeRainSystem();
      _startAnimations();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBoxBounds();
    });
  }

  void _updateBoxBounds() {
    final RenderBox? renderBox = _boxKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        final size = renderBox.size;
        _boxBounds = Rect.fromLTWH(0, 0, size.width, size.height);
      });
    }
  }

  void _initializeRainSystem() {
    final random = Random();

    // Create initial raindrops with physics properties
    for (int i = 0; i < 25; i++) {
      _rainDrops.add(EnhancedRainDrop(
        x: random.nextDouble() * 1.2 - 0.1,
        y: -0.2 - random.nextDouble() * 0.3,
        vx: (random.nextDouble() - 0.5) * 0.02, // Initial horizontal velocity
        vy: 0.8 + random.nextDouble() * 0.6,    // Vertical velocity
        size: 2.5 + random.nextDouble() * 4.5,
        mass: 1.0 + random.nextDouble() * 2.0,  // Mass affects collision
        opacity: 0.7 + random.nextDouble() * 0.3,
        life: 1.0,
        trail: <Offset>[],
      ));
    }

    _startPhysicsSimulation();
  }

  void _startAnimations() {
    _primaryController.repeat();
    _secondaryController.repeat();
    _physicsController.repeat();
  }

  void _startPhysicsSimulation() {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (mounted && widget.enableRainEffect) {
        _updatePhysics();
        _startPhysicsSimulation();
      }
    });
  }

  void _updatePhysics() {
    final random = Random();
    const dt = 0.016; // 60fps

    setState(() {
      // Update raindrops with realistic physics
      for (int i = _rainDrops.length - 1; i >= 0; i--) {
        final drop = _rainDrops[i];

        // Apply gravity
        drop.vy += 0.98 * dt; // Gravity acceleration

        // Apply air resistance
        drop.vx *= 0.995;
        drop.vy *= 0.998;

        // Wind effect (sine wave)
        drop.vx += sin(_primaryController.value * 4 * pi + i * 0.5) * 0.001;

        // Update position
        drop.x += drop.vx * dt;
        drop.y += drop.vy * dt;

        // Add to trail
        if (drop.trail.length > 8) {
          drop.trail.removeAt(0);
        }
        drop.trail.add(Offset(drop.x, drop.y));

        // Check collision with text box
        if (_boxBounds != null && _isDropletInBox(drop)) {
          _createCollisionEffect(drop);
          _rainDrops.removeAt(i);
          continue;
        }

        // Remove drops that are too far down
        if (drop.y > 1.2) {
          _rainDrops.removeAt(i);
        }

        // Decrease life over time
        drop.life -= dt * 0.1;
        if (drop.life <= 0) {
          _rainDrops.removeAt(i);
        }
      }

      // Update collision effects
      for (int i = _collisions.length - 1; i >= 0; i--) {
        final collision = _collisions[i];
        collision.life -= dt * 3.0; // Collision effects fade quickly

        if (collision.life <= 0) {
          _collisions.removeAt(i);
        } else {
          collision.radius += collision.expansionRate * dt;
          collision.opacity = collision.life * collision.initialOpacity;
        }
      }

      // Update water trails
      for (int i = _trails.length - 1; i >= 0; i--) {
        final trail = _trails[i];
        trail.life -= dt * 0.5;
        trail.y += trail.speed * dt;

        if (trail.life <= 0 || trail.y > 1.0) {
          _trails.removeAt(i);
        }
      }

      // Update splash particles
      for (int i = _splashes.length - 1; i >= 0; i--) {
        final splash = _splashes[i];
        splash.x += splash.vx * dt;
        splash.y += splash.vy * dt;
        splash.vy += 0.5 * dt; // Gravity on splash particles
        splash.life -= dt * 2.0;

        if (splash.life <= 0) {
          _splashes.removeAt(i);
        }
      }

      // Add new raindrops periodically
      if (_rainDrops.length < 30 && random.nextDouble() < 0.3) {
        _rainDrops.add(EnhancedRainDrop(
          x: random.nextDouble() * 1.2 - 0.1,
          y: -0.1 - random.nextDouble() * 0.2,
          vx: (random.nextDouble() - 0.5) * 0.015,
          vy: 0.7 + random.nextDouble() * 0.5,
          size: 2.0 + random.nextDouble() * 4.0,
          mass: 0.8 + random.nextDouble() * 1.5,
          opacity: 0.6 + random.nextDouble() * 0.4,
          life: 1.0,
          trail: <Offset>[],
        ));
      }
    });
  }

  bool _isDropletInBox(EnhancedRainDrop drop) {
    if (_boxBounds == null) return false;

    // Convert normalized coordinates to actual coordinates
    final actualX = drop.x * (_boxBounds!.width);
    final actualY = drop.y * (_boxBounds!.height);

    // Check if droplet is within the rounded rectangle bounds
    return _boxBounds!.contains(Offset(actualX, actualY));
  }

  void _createCollisionEffect(EnhancedRainDrop drop) {
    final random = Random();

    // Create main collision ripple
    _collisions.add(CollisionEffect(
      x: drop.x,
      y: drop.y,
      radius: 0,
      maxRadius: drop.size * 2 + random.nextDouble() * 3,
      expansionRate: 20 + drop.mass * 10,
      opacity: drop.opacity * 0.8,
      initialOpacity: drop.opacity * 0.8,
      life: 1.0,
    ));

    // Create water trail from collision point
    _trails.add(WaterTrail(
      x: drop.x,
      y: drop.y,
      width: drop.size * 0.8,
      speed: 0.3 + random.nextDouble() * 0.2,
      opacity: drop.opacity * 0.6,
      life: 1.0,
    ));

    // Create splash particles based on drop mass
    final splashCount = (drop.mass * 3).round();
    for (int i = 0; i < splashCount; i++) {
      final angle = (i / splashCount) * 2 * pi + random.nextDouble() * 0.5;
      final speed = 0.1 + random.nextDouble() * 0.15;

      _splashes.add(SplashParticle(
        x: drop.x,
        y: drop.y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed * 0.5, // Less upward velocity
        size: drop.size * 0.3 + random.nextDouble() * 0.5,
        opacity: drop.opacity * 0.7,
        life: 0.8 + random.nextDouble() * 0.4,
      ));
    }
  }

  @override
  void didUpdateWidget(EnhancedRainTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableRainEffect != oldWidget.enableRainEffect) {
      if (widget.enableRainEffect) {
        _startAnimations();
        _initializeRainSystem();
      } else {
        _primaryController.stop();
        _secondaryController.stop();
        _physicsController.stop();
      }
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _physicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Original text box with key for bounds detection
        Container(
          key: _boxKey,
          child: widget.child,
        ),

        // Rain effects overlay
        if (widget.enableRainEffect)
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) => CustomPaint(
                  painter: EnhancedRainPainter(
                    rainDrops: _rainDrops,
                    collisions: _collisions,
                    trails: _trails,
                    splashes: _splashes,
                    animationValue: _primaryController.value,
                    secondaryValue: _secondaryController.value,
                    intensity: widget.rainIntensity,
                    boxBounds: _boxBounds,
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Enhanced raindrop with physics
class EnhancedRainDrop {
  double x, y;           // Position
  double vx, vy;         // Velocity
  final double size;
  final double mass;
  final double opacity;
  double life;
  List<Offset> trail;    // Trail for motion blur

  EnhancedRainDrop({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.mass,
    required this.opacity,
    required this.life,
    required this.trail,
  });
}

class CollisionEffect {
  final double x, y;
  double radius;
  final double maxRadius;
  final double expansionRate;
  double opacity;
  final double initialOpacity;
  double life;

  CollisionEffect({
    required this.x,
    required this.y,
    required this.radius,
    required this.maxRadius,
    required this.expansionRate,
    required this.opacity,
    required this.initialOpacity,
    required this.life,
  });
}

class WaterTrail {
  final double x;
  double y;
  final double width;
  final double speed;
  final double opacity;
  double life;

  WaterTrail({
    required this.x,
    required this.y,
    required this.width,
    required this.speed,
    required this.opacity,
    required this.life,
  });
}

class SplashParticle {
  double x, y;
  double vx, vy;
  final double size;
  final double opacity;
  double life;

  SplashParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.life,
  });
}

class EnhancedRainPainter extends CustomPainter {
  final List<EnhancedRainDrop> rainDrops;
  final List<CollisionEffect> collisions;
  final List<WaterTrail> trails;
  final List<SplashParticle> splashes;
  final double animationValue;
  final double secondaryValue;
  final double intensity;
  final Rect? boxBounds;

  EnhancedRainPainter({
    required this.rainDrops,
    required this.collisions,
    required this.trails,
    required this.splashes,
    required this.animationValue,
    required this.secondaryValue,
    required this.intensity,
    this.boxBounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawRainDrops(canvas, size);
    _drawCollisionEffects(canvas, size);
    _drawWaterTrails(canvas, size);
    _drawSplashParticles(canvas, size);
  }

  void _drawRainDrops(Canvas canvas, Size size) {
    for (final drop in rainDrops) {
      final center = Offset(
        drop.x * size.width,
        drop.y * size.height,
      );

      // Draw motion trail
      if (drop.trail.length > 1) {
        final path = Path();
        for (int i = 0; i < drop.trail.length - 1; i++) {
          final point1 = Offset(
            drop.trail[i].dx * size.width,
            drop.trail[i].dy * size.height,
          );
          final point2 = Offset(
            drop.trail[i + 1].dx * size.width,
            drop.trail[i + 1].dy * size.height,
          );

          if (i == 0) {
            path.moveTo(point1.dx, point1.dy);
          }
          path.lineTo(point2.dx, point2.dy);
        }

        final trailPaint = Paint()
          ..shader = ui.Gradient.linear(
            drop.trail.first.scale(size.width, size.height),
            drop.trail.last.scale(size.width, size.height),
            [
              Colors.transparent,
              Colors.white.withValues(alpha: drop.opacity * 0.6),
            ],
          )
          ..strokeWidth = drop.size * 0.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        canvas.drawPath(path, trailPaint);
      }

      // Main droplet with 3D effect
      final gradient = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: drop.opacity * 0.9),
          Colors.white.withValues(alpha: drop.opacity * 0.7),
          Colors.white.withValues(alpha: drop.opacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: drop.size),
        )
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 0.8);

      canvas.drawCircle(center, drop.size, paint);

      // Highlight for realism
      final highlight = Paint()
        ..color = Colors.white.withValues(alpha: drop.opacity * 0.6)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 0.5);

      canvas.drawCircle(
        Offset(center.dx - drop.size * 0.3, center.dy - drop.size * 0.3),
        drop.size * 0.4,
        highlight,
      );
    }
  }

  void _drawCollisionEffects(Canvas canvas, Size size) {
    for (final collision in collisions) {
      final center = Offset(
        collision.x * size.width,
        collision.y * size.height,
      );

      // Outer ripple
      final ripplePaint = Paint()
        ..color = Colors.white.withValues(alpha: collision.opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.0);

      canvas.drawCircle(center, collision.radius, ripplePaint);

      // Inner splash
      if (collision.life > 0.7) {
        final splashPaint = Paint()
          ..color = Colors.white.withValues(alpha: collision.opacity * 0.8)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);

        canvas.drawCircle(center, collision.radius * 0.3, splashPaint);
      }

      // Secondary ripple for larger collisions
      if (collision.maxRadius > 4) {
        final secondaryPaint = Paint()
          ..color = Colors.white.withValues(alpha: collision.opacity * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

        canvas.drawCircle(center, collision.radius * 1.5, secondaryPaint);
      }
    }
  }

  void _drawWaterTrails(Canvas canvas, Size size) {
    for (final trail in trails) {
      final startPoint = Offset(
        trail.x * size.width,
        trail.y * size.height,
      );

      final endPoint = Offset(
        trail.x * size.width,
        (trail.y + 0.1) * size.height,
      );

      final trailPaint = Paint()
        ..shader = ui.Gradient.linear(
          startPoint,
          endPoint,
          [
            Colors.white.withValues(alpha: trail.opacity * trail.life),
            Colors.transparent,
          ],
        )
        ..strokeWidth = trail.width
        ..strokeCap = StrokeCap.round
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 0.5);

      canvas.drawLine(startPoint, endPoint, trailPaint);
    }
  }

  void _drawSplashParticles(Canvas canvas, Size size) {
    for (final splash in splashes) {
      final center = Offset(
        splash.x * size.width,
        splash.y * size.height,
      );

      final splashPaint = Paint()
        ..color = Colors.white.withValues(alpha: splash.opacity * splash.life)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.0);

      canvas.drawCircle(center, splash.size, splashPaint);
    }
  }

  @override
  bool shouldRepaint(EnhancedRainPainter oldDelegate) {
    return true; // Always repaint for smooth physics
  }
}

extension OffsetExtension on Offset {
  Offset scale(double width, double height) {
    return Offset(dx * width, dy * height);
  }
}