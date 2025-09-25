import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';

class WaterAccumulationBox extends StatefulWidget {
  final Widget child;
  final bool enableWaterEffect;
  final double rainIntensity;
  final double windStrength;

  const WaterAccumulationBox({
    super.key,
    required this.child,
    this.enableWaterEffect = true,
    this.rainIntensity = 1.0,
    this.windStrength = 0.1,
  });

  @override
  State<WaterAccumulationBox> createState() => _WaterAccumulationBoxState();
}

class _WaterAccumulationBoxState extends State<WaterAccumulationBox>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _waterController;
  late AnimationController _dropletsController;

  late Ticker _physicsTicker;

  // Water accumulation system
  final List<WaterPool> _waterPools = [];
  final List<FallingDrop> _fallingDrops = [];
  final List<SurfaceWave> _surfaceWaves = [];
  final List<WaterTrail> _waterTrails = [];
  final List<EdgeOverflow> _overflows = [];

  final GlobalKey _boxKey = GlobalKey();
  Rect? _boxBounds;

  // Water physics
  double _totalWaterVolume = 0.0;
  double _waterLevel = 0.0;
  static const double _surfaceTension = 0.072;

  // Pool management
  final int _maxPools = 15;
  final double _poolMergeDistance = 20.0;
  final double _overflowThreshold = 5.0;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waterController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _dropletsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    if (widget.enableWaterEffect) {
      _initializeWaterSystem();
      _startAnimations();
      _startPhysicsEngine();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBoxBounds();
    });
  }

  void _startPhysicsEngine() {
    _physicsTicker = createTicker(_updateWaterPhysics);
    _physicsTicker.start();
  }

  void _updateWaterPhysics(Duration elapsed) {
    if (!mounted || !widget.enableWaterEffect) return;

    const double timeStep = 1.0 / 60.0;

    setState(() {
      _simulateRainAccumulation(timeStep);
      _updateWaterPools(timeStep);
      _processSurfaceWaves(timeStep);
      _simulateOverflow(timeStep);
      _updateFallingDrops(timeStep);
      _manageWaterTrails(timeStep);
      _optimizeParticles();
    });
  }

  void _initializeWaterSystem() {
    _totalWaterVolume = 0.0;
    _waterLevel = 0.0;
    _waterPools.clear();
    _fallingDrops.clear();
    _surfaceWaves.clear();
  }

  void _simulateRainAccumulation(double dt) {
    final random = Random();

    // Simulate rain drops hitting the box surface
    if (random.nextDouble() < 0.25 * widget.rainIntensity) {
      var accumulation = random.nextDouble() * 0.08 * widget.rainIntensity;
      _totalWaterVolume += accumulation;

      // Rain drops first hit the outer area, then flow toward the box
      final hitType = random.nextDouble();
      double hitX, hitY, finalX, finalY;

      if (hitType < 0.35) {
        // Rain hits upper-left area and flows toward box top edge
        hitX = 0.0 + random.nextDouble() * 0.2;
        hitY = -0.15 + random.nextDouble() * 0.08;
        finalX = 0.1 + random.nextDouble() * 0.2;
        finalY = -0.02 + random.nextDouble() * 0.01; // Just above box edge
      } else if (hitType < 0.7) {
        // Rain hits upper-right area and flows toward box top edge
        hitX = 0.8 + random.nextDouble() * 0.2;
        hitY = -0.15 + random.nextDouble() * 0.08;
        finalX = 0.7 + random.nextDouble() * 0.2;
        finalY = -0.02 + random.nextDouble() * 0.01; // Just above box edge
      } else {
        // Rain hits upper-center area and flows toward box top edge
        hitX = 0.3 + random.nextDouble() * 0.4;
        hitY = -0.12 + random.nextDouble() * 0.06;
        finalX = 0.35 + random.nextDouble() * 0.3;
        finalY = -0.015 + random.nextDouble() * 0.008; // Just above box edge
        accumulation *= 0.8; // Less water in center
      }

      // Create initial hit droplet that will flow to final position
      _createFlowingDroplet(hitX, hitY, finalX, finalY, accumulation);
    }

    // Update water level based on total volume
    _waterLevel = min(_totalWaterVolume * 0.3, _overflowThreshold);
  }

  void _createFlowingDroplet(double startX, double startY, double endX, double endY, double volume) {
    final random = Random();

    // Create intermediate flowing droplets
    final flowSteps = 3 + random.nextInt(3);
    for (int i = 0; i <= flowSteps; i++) {
      final progress = i / flowSteps;
      final flowX = startX + (endX - startX) * progress;
      final flowY = startY + (endY - startY) * progress;

      // Add some natural curve to the flow path
      final curve = sin(progress * pi) * 0.02;
      final finalFlowX = flowX + curve;

      // Create droplet with delay based on flow progress
      Future.delayed(Duration(milliseconds: (progress * 300).round()), () {
        if (mounted && i == flowSteps) {
          // Final droplet becomes a water pool at the box edge
          _createWaterPool(
            finalFlowX,
            flowY,
            volume * 15,
            8.0 + volume * 18,
          );
        } else if (mounted) {
          // Intermediate flowing droplets
          _createTemporaryDroplet(finalFlowX, flowY, volume * 2);
        }
      });
    }
  }

  void _createTemporaryDroplet(double x, double y, double size) {
    // Create a small temporary droplet that shows the flow path
    _fallingDrops.add(FallingDrop(
      position: Vector2D(x, y),
      velocity: Vector2D(0, 0.1),
      size: size,
      mass: 0.01,
      opacity: 0.4,
      life: 0.8,
      trail: [],
      rotation: 0.0,
      angularVelocity: 0.0,
    ));
  }

  void _createWaterPool(double x, double y, double volume, double surfaceArea) {
    final pool = WaterPool(
      position: Vector2D(x, y),
      volume: volume,
      surfaceArea: surfaceArea,
      height: volume / surfaceArea,
      opacity: 0.6 + (volume * 0.05),
      life: 10.0 + volume,
      flowDirection: Vector2D(0, 0.02),
      adhesion: 0.8,
      meniscus: _calculateMeniscus(surfaceArea),
    );

    _waterPools.add(pool);
    _mergePools();
  }

  void _mergePools() {
    for (int i = _waterPools.length - 1; i >= 0; i--) {
      for (int j = i - 1; j >= 0; j--) {
        final pool1 = _waterPools[i];
        final pool2 = _waterPools[j];

        final distance = (pool1.position - pool2.position).magnitude();

        if (distance < _poolMergeDistance) {
          // Merge pools
          final totalVolume = pool1.volume + pool2.volume;
          final combinedArea = pool1.surfaceArea + pool2.surfaceArea;

          pool2.volume = totalVolume;
          pool2.surfaceArea = combinedArea;
          pool2.height = totalVolume / combinedArea;
          pool2.opacity = min(0.9, pool2.opacity + pool1.opacity * 0.5);
          pool2.life = max(pool2.life, pool1.life);

          _waterPools.removeAt(i);
          break;
        }
      }
    }
  }

  double _calculateMeniscus(double surfaceArea) {
    return _surfaceTension * sqrt(surfaceArea) * 0.1;
  }

  void _updateWaterPools(double dt) {
    final random = Random();

    for (int i = _waterPools.length - 1; i >= 0; i--) {
      final pool = _waterPools[i];

      // Evaporation
      pool.volume -= dt * 0.02;
      pool.height = pool.volume / pool.surfaceArea;

      // Restrict water movement to external top edge only
      // Apply boundary constraints to keep water on box's top rim
      if (pool.position.y < -0.04) {
        // Don't let water go too far above box
        pool.flowDirection.y = max(pool.flowDirection.y, 0.02);
        pool.position.y = max(pool.position.y, -0.04);
      } else if (pool.position.y > 0.0) {
        // Keep water above the box edge, not inside
        pool.flowDirection.y = min(pool.flowDirection.y, -0.01);
        pool.position.y = min(pool.position.y, 0.0);
      } else {
        // Natural surface movement only on external top edge
        pool.flowDirection.y += dt * 0.003; // Very reduced gravity effect
      }

      // Constrain horizontal movement to box boundaries
      if (pool.position.x < 0.05) {
        pool.position.x = 0.05;
        pool.flowDirection.x = max(pool.flowDirection.x, 0);
      } else if (pool.position.x > 0.95) {
        pool.position.x = 0.95;
        pool.flowDirection.x = min(pool.flowDirection.x, 0);
      }

      // Apply constrained movement
      pool.position.add(pool.flowDirection * dt * 0.5); // Slower movement

      // Check for overflow only when water accumulates sufficiently on external top edge
      if (pool.height > _overflowThreshold * 0.7 && pool.position.y <= -0.01) {
        _createOverflow(pool);
        _waterPools.removeAt(i);
        continue;
      }

      // Create surface waves occasionally (only on external top edge)
      if (random.nextDouble() < 0.08 && pool.position.y <= -0.01) {
        _createSurfaceWave(pool);
      }

      // Life reduction
      pool.life -= dt;
      if (pool.life <= 0 || pool.volume <= 0) {
        _waterPools.removeAt(i);
      }
    }

    // Limit pool count
    while (_waterPools.length > _maxPools) {
      _waterPools.removeAt(0);
    }
  }

  void _createSurfaceWave(WaterPool pool) {
    _surfaceWaves.add(SurfaceWave(
      center: Vector2D.copy(pool.position),
      radius: 0.0,
      maxRadius: sqrt(pool.surfaceArea) * 0.8,
      amplitude: pool.height * 0.3,
      speed: 50.0 + pool.volume * 10,
      life: 1.0,
      frequency: 0.5 + pool.volume * 0.1,
    ));
  }

  void _processSurfaceWaves(double dt) {
    for (int i = _surfaceWaves.length - 1; i >= 0; i--) {
      final wave = _surfaceWaves[i];

      wave.radius += wave.speed * dt;
      wave.life -= dt * 2.0;

      if (wave.life <= 0 || wave.radius > wave.maxRadius) {
        _surfaceWaves.removeAt(i);
      }
    }
  }

  void _createOverflow(WaterPool pool) {
    final random = Random();
    final dropCount = (pool.volume * 2).round().clamp(1, 8);

    for (int i = 0; i < dropCount; i++) {
      final angle = (i / dropCount) * 2 * pi + random.nextDouble() * 0.5;
      final speed = 0.3 + random.nextDouble() * 0.4;

      _fallingDrops.add(FallingDrop(
        position: Vector2D.copy(pool.position),
        velocity: Vector2D(cos(angle) * speed * 0.3, speed),
        size: 2.0 + pool.volume * 0.5 + random.nextDouble() * 2,
        mass: pool.volume * 0.1 + random.nextDouble() * 0.05,
        opacity: pool.opacity * 0.8,
        life: 3.0 + random.nextDouble() * 2.0,
        trail: [],
        rotation: random.nextDouble() * 2 * pi,
        angularVelocity: (random.nextDouble() - 0.5) * 3.0,
      ));
    }

    // Create overflow trail
    _createWaterTrail(pool.position, Vector2D(0, 1.0));
  }

  void _createWaterTrail(Vector2D start, Vector2D direction) {
    _waterTrails.add(WaterTrail(
      startPosition: Vector2D.copy(start),
      currentPosition: Vector2D.copy(start),
      direction: direction.normalized(),
      width: 3.0 + Random().nextDouble() * 4.0,
      opacity: 0.7,
      life: 2.0,
      speed: 0.4 + Random().nextDouble() * 0.3,
      points: [Vector2D.copy(start)],
    ));
  }

  void _simulateOverflow(double dt) {
    final random = Random();

    // Check if any pool should overflow (more frequent)
    for (final pool in _waterPools) {
      if (pool.height > _overflowThreshold * 0.4 && random.nextDouble() < 0.12) {
        _overflows.add(EdgeOverflow(
          startPosition: Vector2D.copy(pool.position),
          targetEdge: _findNearestEdge(pool.position),
          flowRate: pool.volume * 0.1,
          width: sqrt(pool.surfaceArea) * 0.2,
          opacity: pool.opacity * 0.6,
          life: 3.0,
          progress: 0.0,
        ));
      }
    }

    // Update overflows
    for (int i = _overflows.length - 1; i >= 0; i--) {
      final overflow = _overflows[i];

      overflow.progress += dt * 0.3;
      overflow.life -= dt;

      if (overflow.progress >= 1.0) {
        // Create falling drops at edge
        _createEdgeDrops(overflow);
        _overflows.removeAt(i);
      } else if (overflow.life <= 0) {
        _overflows.removeAt(i);
      }
    }
  }

  Vector2D _findNearestEdge(Vector2D position) {
    // For rounded corner boxes, find the most natural flow path
    final x = position.x;
    final y = position.y;

    // Define rounded corner boundaries (matching BorderRadius.circular(24.r))
    final cornerRadius = 0.08; // Approximate relative corner radius

    if (x <= 0.3 && y <= 0.05) {
      // Top-left corner region - flow to left-bottom curve
      return Vector2D(max(0.08, x - 0.02), 0.88 + (x * 0.1));
    } else if (x >= 0.7 && y <= 0.05) {
      // Top-right corner region - flow to right-bottom curve
      return Vector2D(min(0.92, x + 0.02), 0.88 + ((1.0 - x) * 0.1));
    } else if (x > 0.3 && x < 0.7 && y <= 0.05) {
      // Top-center region - flow straight down to bottom
      return Vector2D(x, 0.95);
    } else {
      // Default fallback - flow to nearest bottom edge
      return Vector2D(x, 0.95);
    }
  }

  void _createEdgeDrops(EdgeOverflow overflow) {
    final random = Random();
    final dropCount = (overflow.flowRate * 5).round().clamp(2, 6);

    for (int i = 0; i < dropCount; i++) {
      _fallingDrops.add(FallingDrop(
        position: Vector2D.copy(overflow.targetEdge),
        velocity: Vector2D(
          (random.nextDouble() - 0.5) * 0.2,
          0.5 + random.nextDouble() * 0.5,
        ),
        size: 2.5 + overflow.flowRate + random.nextDouble() * 2,
        mass: overflow.flowRate * 0.2,
        opacity: overflow.opacity,
        life: 4.0 + random.nextDouble(),
        trail: [],
        rotation: random.nextDouble() * 2 * pi,
        angularVelocity: (random.nextDouble() - 0.5) * 4.0,
      ));
    }
  }

  void _updateFallingDrops(double dt) {
    final gravity = 9.81 * dt * 0.1;

    for (int i = _fallingDrops.length - 1; i >= 0; i--) {
      final drop = _fallingDrops[i];

      // Apply physics
      drop.velocity.y += gravity;
      drop.velocity.x *= 0.998; // Air resistance
      drop.position.add(drop.velocity * dt);

      // Update rotation
      drop.rotation += drop.angularVelocity * dt;

      // Add trail point
      drop.trail.add(Vector2D.copy(drop.position));
      if (drop.trail.length > 8) {
        drop.trail.removeAt(0);
      }

      // Life reduction
      drop.life -= dt;

      // Remove if out of bounds or dead
      if (drop.position.y > 1.5 || drop.life <= 0) {
        _fallingDrops.removeAt(i);
      }
    }
  }

  void _manageWaterTrails(double dt) {
    for (int i = _waterTrails.length - 1; i >= 0; i--) {
      final trail = _waterTrails[i];

      // Extend trail
      trail.currentPosition.add(trail.direction * trail.speed * dt);
      trail.points.add(Vector2D.copy(trail.currentPosition));

      // Limit trail length
      if (trail.points.length > 15) {
        trail.points.removeAt(0);
      }

      // Fade out
      trail.opacity -= dt * 0.3;
      trail.life -= dt;

      if (trail.life <= 0 || trail.opacity <= 0) {
        _waterTrails.removeAt(i);
      }
    }
  }

  void _optimizeParticles() {
    // Remove excess particles for performance
    while (_fallingDrops.length > 50) {
      _fallingDrops.removeAt(0);
    }

    while (_surfaceWaves.length > 20) {
      _surfaceWaves.removeAt(0);
    }

    while (_waterTrails.length > 15) {
      _waterTrails.removeAt(0);
    }
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

  void _startAnimations() {
    _masterController.repeat();
    _waterController.repeat();
    _dropletsController.repeat();
  }

  @override
  void didUpdateWidget(WaterAccumulationBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableWaterEffect != oldWidget.enableWaterEffect) {
      if (widget.enableWaterEffect) {
        _startAnimations();
        _startPhysicsEngine();
        _initializeWaterSystem();
      } else {
        _masterController.stop();
        _waterController.stop();
        _dropletsController.stop();
        _physicsTicker.stop();
      }
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _waterController.dispose();
    _dropletsController.dispose();
    _physicsTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allow water to appear outside box bounds
      children: [
        Container(
          key: _boxKey,
          child: widget.child,
        ),

        if (widget.enableWaterEffect)
          Positioned(
            left: -10, // Extend beyond box bounds
            right: -10,
            top: -15, // Extend above box to show water on top edge
            bottom: -10,
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) => CustomPaint(
                  painter: WaterAccumulationPainter(
                    waterPools: _waterPools,
                    fallingDrops: _fallingDrops,
                    surfaceWaves: _surfaceWaves,
                    waterTrails: _waterTrails,
                    overflows: _overflows,
                    waterLevel: _waterLevel,
                    boxBounds: _boxBounds,
                    masterTime: _masterController.value,
                    waterTime: _waterController.value,
                    intensity: widget.rainIntensity,
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

// Data structures
class Vector2D {
  double x, y;

  Vector2D(this.x, this.y);
  Vector2D.copy(Vector2D other) : x = other.x, y = other.y;

  Vector2D operator +(Vector2D other) => Vector2D(x + other.x, y + other.y);
  Vector2D operator -(Vector2D other) => Vector2D(x - other.x, y - other.y);
  Vector2D operator *(double scalar) => Vector2D(x * scalar, y * scalar);

  void add(Vector2D other) {
    x += other.x;
    y += other.y;
  }

  double magnitude() => sqrt(x * x + y * y);
  Vector2D normalized() {
    final mag = magnitude();
    return mag > 0 ? Vector2D(x / mag, y / mag) : Vector2D(0, 0);
  }
}

class WaterPool {
  Vector2D position;
  double volume;
  double surfaceArea;
  double height;
  double opacity;
  double life;
  Vector2D flowDirection;
  double adhesion;
  double meniscus;

  WaterPool({
    required this.position,
    required this.volume,
    required this.surfaceArea,
    required this.height,
    required this.opacity,
    required this.life,
    required this.flowDirection,
    required this.adhesion,
    required this.meniscus,
  });
}

class FallingDrop {
  Vector2D position;
  Vector2D velocity;
  double size;
  double mass;
  double opacity;
  double life;
  List<Vector2D> trail;
  double rotation;
  double angularVelocity;

  FallingDrop({
    required this.position,
    required this.velocity,
    required this.size,
    required this.mass,
    required this.opacity,
    required this.life,
    required this.trail,
    required this.rotation,
    required this.angularVelocity,
  });
}

class SurfaceWave {
  Vector2D center;
  double radius;
  double maxRadius;
  double amplitude;
  double speed;
  double life;
  double frequency;

  SurfaceWave({
    required this.center,
    required this.radius,
    required this.maxRadius,
    required this.amplitude,
    required this.speed,
    required this.life,
    required this.frequency,
  });
}

class WaterTrail {
  Vector2D startPosition;
  Vector2D currentPosition;
  Vector2D direction;
  double width;
  double opacity;
  double life;
  double speed;
  List<Vector2D> points;

  WaterTrail({
    required this.startPosition,
    required this.currentPosition,
    required this.direction,
    required this.width,
    required this.opacity,
    required this.life,
    required this.speed,
    required this.points,
  });
}

class EdgeOverflow {
  Vector2D startPosition;
  Vector2D targetEdge;
  double flowRate;
  double width;
  double opacity;
  double life;
  double progress;

  EdgeOverflow({
    required this.startPosition,
    required this.targetEdge,
    required this.flowRate,
    required this.width,
    required this.opacity,
    required this.life,
    required this.progress,
  });
}

// Advanced painter
class WaterAccumulationPainter extends CustomPainter {
  final List<WaterPool> waterPools;
  final List<FallingDrop> fallingDrops;
  final List<SurfaceWave> surfaceWaves;
  final List<WaterTrail> waterTrails;
  final List<EdgeOverflow> overflows;
  final double waterLevel;
  final Rect? boxBounds;
  final double masterTime;
  final double waterTime;
  final double intensity;

  WaterAccumulationPainter({
    required this.waterPools,
    required this.fallingDrops,
    required this.surfaceWaves,
    required this.waterTrails,
    required this.overflows,
    required this.waterLevel,
    this.boxBounds,
    required this.masterTime,
    required this.waterTime,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawWaterPools(canvas, size);
    _drawSurfaceWaves(canvas, size);
    _drawWaterTrails(canvas, size);
    _drawOverflows(canvas, size);
    _drawFallingDrops(canvas, size);
  }

  void _drawWaterPools(Canvas canvas, Size size) {
    for (final pool in waterPools) {
      final center = Offset(
        pool.position.x * size.width,
        pool.position.y * size.height,
      );

      final poolSize = sqrt(pool.surfaceArea);

      // Enhanced water pool rendering for external edge precision
      // Determine if pool is at external top edge/corner for specialized rendering
      final isTopEdge = pool.position.y <= -0.005; // External top edge
      final isLeftCorner = pool.position.x <= 0.25;
      final isRightCorner = pool.position.x >= 0.75;

      double poolWidth = poolSize * 2;
      double poolHeight = poolSize * 1.6;

      // Adjust pool shape based on position for more realistic edge accumulation
      if (isTopEdge) {
        poolHeight *= 0.8; // Flatten pools on top edge
        if (isLeftCorner || isRightCorner) {
          // Corner pools are more elongated
          poolWidth *= 1.3;
          poolHeight *= 0.6;
        }
      }

      // Main water pool with enhanced gradient for edge visibility
      final gradient = RadialGradient(
        center: isTopEdge ? const Alignment(-0.2, -0.8) : const Alignment(-0.3, -0.5),
        colors: [
          Colors.white.withValues(alpha: pool.opacity * 0.95),
          Colors.white.withValues(alpha: pool.opacity * 0.8),
          Colors.white.withValues(alpha: pool.opacity * 0.5),
          Colors.white.withValues(alpha: pool.opacity * 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCenter(center: center, width: poolWidth, height: poolHeight),
        )
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, poolSize * 0.15);

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: poolWidth,
          height: poolHeight,
        ),
        paint,
      );

      // Enhanced meniscus effect for top edge pools
      if (isTopEdge) {
        final edgeMeniscusPaint = Paint()
          ..color = Colors.white.withValues(alpha: pool.opacity * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = pool.meniscus * 1.2
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 0.8);

        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: poolWidth,
            height: poolHeight,
          ),
          edgeMeniscusPaint,
        );
      }

      // Surface tension highlight with position-specific adjustment
      final highlightOffset = isTopEdge
          ? Offset(center.dx - poolSize * 0.4, center.dy - poolSize * 0.1)
          : Offset(center.dx - poolSize * 0.3, center.dy - poolSize * 0.2);

      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: pool.opacity * 0.7)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, poolSize * 0.08);

      canvas.drawOval(
        Rect.fromCenter(
          center: highlightOffset,
          width: poolSize * 0.9,
          height: poolSize * (isTopEdge ? 0.3 : 0.5),
        ),
        highlightPaint,
      );

      // Add subtle rim effect for pools at corners
      if (isTopEdge && (isLeftCorner || isRightCorner)) {
        final rimPaint = Paint()
          ..color = Colors.white.withValues(alpha: pool.opacity * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.2);

        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: poolWidth * 1.1,
            height: poolHeight * 1.1,
          ),
          rimPaint,
        );
      }
    }
  }

  void _drawSurfaceWaves(Canvas canvas, Size size) {
    for (final wave in surfaceWaves) {
      final center = Offset(
        wave.center.x * size.width,
        wave.center.y * size.height,
      );

      final amplitude = wave.amplitude * (1.0 - wave.radius / wave.maxRadius);

      final wavePaint = Paint()
        ..color = Colors.white.withValues(alpha: amplitude * wave.life * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + amplitude
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.5);

      canvas.drawCircle(center, wave.radius, wavePaint);

      // Secondary wave
      if (wave.radius > wave.maxRadius * 0.3) {
        final secondaryPaint = Paint()
          ..color = Colors.white.withValues(alpha: amplitude * wave.life * 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        canvas.drawCircle(center, wave.radius * 1.3, secondaryPaint);
      }
    }
  }

  void _drawWaterTrails(Canvas canvas, Size size) {
    for (final trail in waterTrails) {
      if (trail.points.length < 2) continue;

      final path = Path();
      final points = trail.points.map((p) => Offset(
        p.x * size.width,
        p.y * size.height,
      )).toList();

      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      final trailPaint = Paint()
        ..shader = ui.Gradient.linear(
          points.first,
          points.last,
          [
            Colors.white.withValues(alpha: trail.opacity * 0.8),
            Colors.white.withValues(alpha: trail.opacity * 0.3),
            Colors.transparent,
          ],
          [0.0, 0.6, 1.0],
        )
        ..strokeWidth = trail.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);

      canvas.drawPath(path, trailPaint);
    }
  }

  void _drawOverflows(Canvas canvas, Size size) {
    for (final overflow in overflows) {
      final start = Offset(
        overflow.startPosition.x * size.width,
        overflow.startPosition.y * size.height,
      );

      final end = Offset(
        overflow.targetEdge.x * size.width,
        overflow.targetEdge.y * size.height,
      );

      final currentEnd = Offset.lerp(start, end, overflow.progress)!;

      final overflowPaint = Paint()
        ..shader = ui.Gradient.linear(
          start,
          currentEnd,
          [
            Colors.white.withValues(alpha: overflow.opacity * 0.7),
            Colors.white.withValues(alpha: overflow.opacity * 0.4),
            Colors.transparent,
          ],
        )
        ..strokeWidth = overflow.width
        ..strokeCap = StrokeCap.round
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);

      canvas.drawLine(start, currentEnd, overflowPaint);
    }
  }

  void _drawFallingDrops(Canvas canvas, Size size) {
    for (final drop in fallingDrops) {
      final center = Offset(
        drop.position.x * size.width,
        drop.position.y * size.height,
      );

      // Draw trail
      if (drop.trail.length > 1) {
        final path = Path();
        final trailPoints = drop.trail.map((p) => Offset(
          p.x * size.width,
          p.y * size.height,
        )).toList();

        path.moveTo(trailPoints.first.dx, trailPoints.first.dy);
        for (final point in trailPoints.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }

        final trailPaint = Paint()
          ..color = Colors.white.withValues(alpha: drop.opacity * 0.4)
          ..strokeWidth = drop.size * 0.3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, drop.size * 0.2);

        canvas.drawPath(path, trailPaint);
      }

      // Main drop with rotation effect
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(drop.rotation);

      final dropGradient = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          Colors.white.withValues(alpha: drop.opacity * 0.95),
          Colors.white.withValues(alpha: drop.opacity * 0.7),
          Colors.white.withValues(alpha: drop.opacity * 0.3),
          Colors.transparent,
        ],
      );

      final dropPaint = Paint()
        ..shader = dropGradient.createShader(
          Rect.fromCircle(center: Offset.zero, radius: drop.size),
        )
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, drop.size * 0.15);

      canvas.drawCircle(Offset.zero, drop.size, dropPaint);

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: drop.opacity * 0.8)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, drop.size * 0.1);

      canvas.drawCircle(
        Offset(-drop.size * 0.3, -drop.size * 0.3),
        drop.size * 0.4,
        highlightPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(WaterAccumulationPainter oldDelegate) => true;
}