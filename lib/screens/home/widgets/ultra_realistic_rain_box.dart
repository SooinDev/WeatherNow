import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';

class UltraRealisticRainBox extends StatefulWidget {
  final Widget child;
  final bool enableRainEffect;
  final double rainIntensity;
  final double windStrength;
  final double temperature;

  const UltraRealisticRainBox({
    super.key,
    required this.child,
    this.enableRainEffect = true,
    this.rainIntensity = 1.0,
    this.windStrength = 0.1,
    this.temperature = 20.0,
  });

  @override
  State<UltraRealisticRainBox> createState() => _UltraRealisticRainBoxState();
}

class _UltraRealisticRainBoxState extends State<UltraRealisticRainBox>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _windController;
  late AnimationController _microController;

  late Ticker _physicsTicker;

  // Advanced particle systems
  final List<HydrodynamicDroplet> _primaryDroplets = [];
  final List<MicroDroplet> _microDroplets = [];
  final List<SurfaceFilm> _surfaceFilms = [];
  final List<VolumetricSplash> _volumetricSplashes = [];
  final List<RefractionEffect> _refractions = [];

  final GlobalKey _containerKey = GlobalKey();
  Rect? _preciseBoxBounds;

  // Physics constants for ultra-realism
  static const double _gravity = 9.81;
  static const double _airDensity = 1.225;
  static const double _waterDensity = 1000.0;
  static const double _surfaceTension = 0.0728;
  static const double _viscosity = 0.001;

  // Rendering performance
  double _averageFPS = 60.0;
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _windController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _microController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    if (widget.enableRainEffect) {
      _initializeUltraRealisticSystem();
      _startAdvancedAnimations();
      _startPhysicsEngine();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePreciseBoxBounds();
    });
  }

  void _startPhysicsEngine() {
    _physicsTicker = createTicker(_updatePhysicsStep);
    _physicsTicker.start();
  }

  void _updatePhysicsStep(Duration elapsed) {
    if (!mounted || !widget.enableRainEffect) return;

    _updatePerformanceMetrics();

    // Ultra-high frequency physics (120 FPS equivalent)
    const double timeStep = 1.0 / 120.0;

    setState(() {
      _simulateHydrodynamics(timeStep);
      _updateMicroParticles(timeStep);
      _processSurfaceInteractions(timeStep);
      _calculateVolumetricEffects(timeStep);
      _updateOpticalEffects(timeStep);
      _managePrecisionParticles();
    });
  }

  void _updatePerformanceMetrics() {
    final now = DateTime.now();
    final deltaTime = now.difference(_lastFrameTime).inMicroseconds / 1000000.0;
    _averageFPS = 0.9 * _averageFPS + 0.1 * (1.0 / deltaTime);
    _lastFrameTime = now;
  }

  void _initializeUltraRealisticSystem() {
    final random = Random();

    // Create fewer, more natural hydrodynamic droplets
    for (int i = 0; i < 25; i++) { // Reduced from 40 to 25
      final naturalRadius = 1.8 + random.nextDouble() * 2.5; // Slightly larger, more realistic sizes
      _primaryDroplets.add(HydrodynamicDroplet(
        position: Vector2(random.nextDouble() * 1.1 - 0.05, -0.2 - random.nextDouble() * 0.5), // More natural spawn area
        velocity: Vector2((random.nextDouble() - 0.5) * 0.015, 0.6 + random.nextDouble() * 0.6), // Gentler horizontal movement
        radius: naturalRadius,
        mass: _calculateMass(naturalRadius),
        opacity: 0.7 + random.nextDouble() * 0.25, // Slightly more transparent
        temperature: widget.temperature + random.nextDouble() * 4 - 2.0,
        surfaceTension: _surfaceTension * (0.85 + random.nextDouble() * 0.3),
        viscosity: _viscosity * (0.6 + random.nextDouble() * 0.8),
        refractionIndex: 1.33 + random.nextDouble() * 0.04,
        life: 1.2, // Slightly longer life
        trail: [],
        deformation: 0.0,
        rotation: random.nextDouble() * 2 * pi,
        angularVelocity: (random.nextDouble() - 0.5) * 1.5, // Gentler rotation
      ));
    }

    // Initialize more subtle micro-droplet system
    for (int i = 0; i < 60; i++) { // Reduced from 100 to 60
      _microDroplets.add(MicroDroplet(
        position: Vector2(random.nextDouble(), random.nextDouble() * 0.8 - 0.2), // More focused spawn area
        velocity: Vector2((random.nextDouble() - 0.5) * 0.03, random.nextDouble() * 0.25), // Gentler movement
        size: 0.8 + random.nextDouble() * 1.0, // Slightly larger, more visible
        opacity: 0.25 + random.nextDouble() * 0.3, // More subtle
        life: 1.0 + random.nextDouble() * 0.6, // Longer life for smoother effect
        brownianMotion: random.nextDouble() * 0.0008, // Slightly reduced brownian motion
      ));
    }
  }

  double _calculateMass(double radius) {
    return (4.0 / 3.0) * pi * pow(radius, 3) * _waterDensity * 1e-9;
  }

  void _simulateHydrodynamics(double dt) {
    final random = Random();

    for (int i = _primaryDroplets.length - 1; i >= 0; i--) {
      final droplet = _primaryDroplets[i];

      // Advanced physics calculations
      _applyGravity(droplet, dt);
      _applyAerodynamics(droplet, dt);
      _applyWindForces(droplet, dt);
      _updateDeformation(droplet, dt);
      _calculateTrail(droplet, dt);

      // Position integration using Verlet integration
      _integratePosition(droplet, dt);

      // No collision effects - let droplets pass through cleanly
      // Removed collision detection to prevent water pooling under text

      // Boundary cleanup with life degradation
      if (droplet.position.y > 1.3 || droplet.life <= 0) {
        _primaryDroplets.removeAt(i);
        continue;
      }

      // Gradual life reduction
      droplet.life -= dt * 0.05;
    }

    // Spawn new droplets with more natural, less frequent generation
    final spawnChance = 0.08 * widget.rainIntensity * (0.8 + sin(_masterController.value * pi) * 0.4);
    if (_primaryDroplets.length < 35 && random.nextDouble() < spawnChance) { // Reduced max droplets and spawn rate
      _spawnAdvancedDroplet();
    }
  }

  void _applyGravity(HydrodynamicDroplet droplet, double dt) {
    droplet.velocity.y += _gravity * dt * 0.1; // Scale for visual effect
  }

  void _applyAerodynamics(HydrodynamicDroplet droplet, double dt) {
    // Calculate drag force using Reynolds number
    final speed = droplet.velocity.magnitude();
    final dragCoeff = _calculateDragCoefficient(droplet, speed);
    final dragForce = 0.5 * _airDensity * speed * speed * droplet.crossSectionalArea() * dragCoeff;

    if (speed > 0) {
      final dragAcceleration = dragForce / droplet.mass;
      final dragDirection = droplet.velocity.normalized() * -1;

      droplet.velocity.add(dragDirection * dragAcceleration * dt);
    }

    // Terminal velocity limiting
    if (speed > droplet.terminalVelocity()) {
      droplet.velocity = droplet.velocity.normalized() * droplet.terminalVelocity();
    }
  }

  double _calculateDragCoefficient(HydrodynamicDroplet droplet, double speed) {
    final reynoldsNumber = _airDensity * speed * droplet.radius * 2 / 1.8e-5;

    if (reynoldsNumber < 2) {
      return 24 / reynoldsNumber; // Stokes flow
    } else if (reynoldsNumber < 1000) {
      return 24 / reynoldsNumber * (1 + 0.15 * pow(reynoldsNumber, 0.687));
    } else {
      return 0.44; // Newton's regime
    }
  }

  void _applyWindForces(HydrodynamicDroplet droplet, double dt) {
    final windPhase = _windController.value * 1.5 * pi; // Slower wind oscillation
    final gustStrength = sin(windPhase) * 0.3 + 0.7; // Less dramatic gusts
    final windForce = widget.windStrength * gustStrength * (1 + sin(windPhase * 2) * 0.2); // Gentler variation

    droplet.velocity.x += windForce * dt * 0.8 * (1.0 + droplet.deformation * 0.3); // Reduced wind impact

    // Gentler turbulence effects
    final turbulence = Vector2(
      sin(windPhase * 4 + droplet.position.y * 6) * 0.001, // Reduced turbulence
      cos(windPhase * 3 + droplet.position.x * 4) * 0.0008,
    );
    droplet.velocity.add(turbulence * dt);
  }

  void _updateDeformation(HydrodynamicDroplet droplet, double dt) {
    final speed = droplet.velocity.magnitude();
    final targetDeformation = min(speed * 0.1, 0.3);

    droplet.deformation += (targetDeformation - droplet.deformation) * dt * 5.0;
    droplet.rotation += droplet.angularVelocity * dt;
  }

  void _calculateTrail(HydrodynamicDroplet droplet, double dt) {
    droplet.trail.add(TrailPoint(
      position: Vector2.copy(droplet.position),
      velocity: droplet.velocity.magnitude(),
      time: 0.0,
    ));

    // Update trail physics
    for (final point in droplet.trail) {
      point.time += dt;
    }

    // Limit trail length with smooth fade
    while (droplet.trail.length > 12) {
      droplet.trail.removeAt(0);
    }
  }

  void _integratePosition(HydrodynamicDroplet droplet, double dt) {
    // Verlet integration for stable physics
    droplet.position.add(droplet.velocity * dt);
  }

  bool _checkPreciseCollision(HydrodynamicDroplet droplet) {
    if (_preciseBoxBounds == null) return false;

    final actualPos = Vector2(
      droplet.position.x * (_preciseBoxBounds!.width),
      droplet.position.y * (_preciseBoxBounds!.height),
    );

    // Sub-pixel collision detection with droplet radius
    return _preciseBoxBounds!.inflate(droplet.radius).contains(
      Offset(actualPos.x, actualPos.y)
    );
  }

  void _createVolumetricSplash(HydrodynamicDroplet droplet) {
    final random = Random();
    final impactEnergy = droplet.mass * droplet.velocity.magnitudeSquared();

    _volumetricSplashes.add(VolumetricSplash(
      position: Vector2.copy(droplet.position),
      initialRadius: droplet.radius,
      maxRadius: droplet.radius * 3 + impactEnergy * 50,
      expansionRate: 15 + impactEnergy * 100,
      intensity: min(impactEnergy * 2, 1.0),
      life: 1.0,
      volumeDensity: droplet.mass * 1000,
      refractionStrength: droplet.refractionIndex - 1.0,
    ));

    // Secondary ripples for high-energy impacts
    if (impactEnergy > 0.001) {
      for (int i = 0; i < 3; i++) {
        _volumetricSplashes.add(VolumetricSplash(
          position: droplet.position + Vector2(
            (random.nextDouble() - 0.5) * 0.02,
            (random.nextDouble() - 0.5) * 0.02,
          ),
          initialRadius: droplet.radius * 0.7,
          maxRadius: droplet.radius * 2,
          expansionRate: 8 + impactEnergy * 30,
          intensity: min(impactEnergy * 1.5, 0.8),
          life: 0.8,
          volumeDensity: droplet.mass * 500,
          refractionStrength: (droplet.refractionIndex - 1.0) * 0.7,
        ));
      }
    }
  }

  void _generateSurfaceFilm(HydrodynamicDroplet droplet) {
    final filmArea = droplet.mass * 100;
    final filmThickness = droplet.radius * 0.1;

    _surfaceFilms.add(SurfaceFilm(
      position: Vector2.copy(droplet.position),
      area: filmArea,
      thickness: filmThickness,
      opacity: droplet.opacity * 0.6,
      life: 1.5 + droplet.mass * 10,
      flowDirection: Vector2(droplet.velocity.x * 0.3, max(0.1, (droplet.velocity.y).abs() * 0.2)),
      viscosity: droplet.viscosity,
      surfaceTension: droplet.surfaceTension,
    ));
  }

  void _createRefractionEffect(HydrodynamicDroplet droplet) {
    _refractions.add(RefractionEffect(
      position: Vector2.copy(droplet.position),
      strength: droplet.refractionIndex - 1.0,
      radius: droplet.radius * 2,
      life: 0.5,
      causticIntensity: droplet.opacity * 0.8,
    ));
  }

  void _spawnMicroDroplets(HydrodynamicDroplet parent, int count) {
    final random = Random();

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi + random.nextDouble() * 0.5;
      final speed = 0.05 + random.nextDouble() * 0.15;

      _microDroplets.add(MicroDroplet(
        position: Vector2.copy(parent.position),
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed * 0.5),
        size: parent.radius * 0.2 + random.nextDouble() * 0.5,
        opacity: parent.opacity * 0.7,
        life: 0.8 + random.nextDouble() * 0.6,
        brownianMotion: random.nextDouble() * 0.002,
      ));
    }
  }

  void _spawnAdvancedDroplet() {
    final random = Random();

    _primaryDroplets.add(HydrodynamicDroplet(
      position: Vector2(random.nextDouble() * 1.2 - 0.1, -0.1 - random.nextDouble() * 0.3),
      velocity: Vector2((random.nextDouble() - 0.5) * 0.02, 0.7 + random.nextDouble() * 0.7),
      radius: 1.8 + random.nextDouble() * 3.5,
      mass: _calculateMass(1.8 + random.nextDouble() * 3.5),
      opacity: 0.75 + random.nextDouble() * 0.25,
      temperature: widget.temperature + random.nextDouble() * 5 - 2.5,
      surfaceTension: _surfaceTension * (0.8 + random.nextDouble() * 0.4),
      viscosity: _viscosity * (0.5 + random.nextDouble()),
      refractionIndex: 1.33 + random.nextDouble() * 0.05,
      life: 1.0,
      trail: [],
      deformation: 0.0,
      rotation: random.nextDouble() * 2 * pi,
      angularVelocity: (random.nextDouble() - 0.5) * 2.0,
    ));
  }

  void _updateMicroParticles(double dt) {
    final random = Random();

    for (int i = _microDroplets.length - 1; i >= 0; i--) {
      final micro = _microDroplets[i];

      // Gentler gravity
      micro.velocity.y += _gravity * dt * 0.03; // Reduced from 0.05

      // More subtle brownian motion
      micro.velocity.add(Vector2(
        (random.nextDouble() - 0.5) * micro.brownianMotion * 0.7, // Reduced intensity
        (random.nextDouble() - 0.5) * micro.brownianMotion * 0.3,
      ));

      // Gentler air resistance
      micro.velocity *= 0.998; // Less resistance for smoother movement

      // Update position
      micro.position.add(micro.velocity * dt);

      // Slower life degradation for smoother transitions
      micro.life -= dt * 0.8; // Reduced from 1.2

      if (micro.life <= 0 || micro.position.y > 1.3) {
        _microDroplets.removeAt(i);
      }
    }

    // Spawn new micro droplets more naturally
    final spawnRate = widget.rainIntensity * 0.12 * (0.7 + sin(_masterController.value * 1.8 * pi) * 0.3);
    if (_microDroplets.length < 70 && random.nextDouble() < spawnRate) {
      _microDroplets.add(MicroDroplet(
        position: Vector2(random.nextDouble(), -0.1 - random.nextDouble() * 0.1),
        velocity: Vector2((random.nextDouble() - 0.5) * 0.02, random.nextDouble() * 0.2),
        size: 0.6 + random.nextDouble() * 0.8,
        opacity: 0.2 + random.nextDouble() * 0.25,
        life: 1.2 + random.nextDouble() * 0.8,
        brownianMotion: random.nextDouble() * 0.0006,
      ));
    }
  }

  void _processSurfaceInteractions(double dt) {
    // Disabled surface film processing to prevent water pooling
    _surfaceFilms.clear(); // Clear any remaining surface films
  }

  void _calculateVolumetricEffects(double dt) {
    // Disabled volumetric splash effects to prevent water pooling
    _volumetricSplashes.clear(); // Clear any remaining splashes
  }

  void _updateOpticalEffects(double dt) {
    // Disabled optical effects to keep rain simple and clean
    _refractions.clear(); // Clear any remaining refraction effects
  }

  void _managePrecisionParticles() {
    // Maintain optimal particle count for natural, smooth performance
    while (_microDroplets.length > 80) { // Reduced for smoother effect
      _microDroplets.removeAt(0);
    }

    // Clear all pooling effects to keep rain clean
    _surfaceFilms.clear();
    _volumetricSplashes.clear();
    _refractions.clear();
  }

  void _updatePreciseBoxBounds() {
    final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        final size = renderBox.size;
        _preciseBoxBounds = Rect.fromLTWH(0, 0, size.width, size.height);

      });
    }
  }

  void _startAdvancedAnimations() {
    _masterController.repeat();
    _windController.repeat();
    _microController.repeat();
  }

  @override
  void didUpdateWidget(UltraRealisticRainBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableRainEffect != oldWidget.enableRainEffect) {
      if (widget.enableRainEffect) {
        _startAdvancedAnimations();
        _startPhysicsEngine();
        _initializeUltraRealisticSystem();
      } else {
        _masterController.stop();
        _windController.stop();
        _microController.stop();
        _physicsTicker.stop();
      }
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _windController.dispose();
    _microController.dispose();
    _physicsTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          key: _containerKey,
          child: widget.child,
        ),

        if (widget.enableRainEffect)
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) => CustomPaint(
                  painter: UltraRealisticRainPainter(
                    primaryDroplets: _primaryDroplets,
                    microDroplets: _microDroplets,
                    surfaceFilms: _surfaceFilms,
                    volumetricSplashes: _volumetricSplashes,
                    refractions: _refractions,
                    boxBounds: _preciseBoxBounds,
                    masterTime: _masterController.value,
                    windTime: _windController.value,
                    microTime: _microController.value,
                    intensity: widget.rainIntensity,
                    averageFPS: _averageFPS,
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

// Advanced physics data structures
class Vector2 {
  double x, y;

  Vector2(this.x, this.y);

  Vector2.copy(Vector2 other) : x = other.x, y = other.y;

  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  Vector2 operator *(double scalar) => Vector2(x * scalar, y * scalar);

  void add(Vector2 other) {
    x += other.x;
    y += other.y;
  }


  double magnitude() => sqrt(x * x + y * y);
  double magnitudeSquared() => x * x + y * y;

  Vector2 normalized() {
    final mag = magnitude();
    return mag > 0 ? Vector2(x / mag, y / mag) : Vector2(0, 0);
  }
}

class TrailPoint {
  Vector2 position;
  double velocity;
  double time;

  TrailPoint({
    required this.position,
    required this.velocity,
    required this.time,
  });
}

class HydrodynamicDroplet {
  Vector2 position;
  Vector2 velocity;
  double radius;
  double mass;
  double opacity;
  double temperature;
  double surfaceTension;
  double viscosity;
  double refractionIndex;
  double life;
  List<TrailPoint> trail;
  double deformation;
  double rotation;
  double angularVelocity;

  HydrodynamicDroplet({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.mass,
    required this.opacity,
    required this.temperature,
    required this.surfaceTension,
    required this.viscosity,
    required this.refractionIndex,
    required this.life,
    required this.trail,
    required this.deformation,
    required this.rotation,
    required this.angularVelocity,
  });

  double crossSectionalArea() => pi * pow(radius * (1 + deformation), 2);
  double terminalVelocity() => sqrt(2 * mass * 9.81 / (1.225 * crossSectionalArea() * 0.44));
}

class MicroDroplet {
  Vector2 position;
  Vector2 velocity;
  double size;
  double opacity;
  double life;
  double brownianMotion;

  MicroDroplet({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.life,
    required this.brownianMotion,
  });
}

class SurfaceFilm {
  Vector2 position;
  double area;
  double thickness;
  double opacity;
  double life;
  Vector2 flowDirection;
  double viscosity;
  double surfaceTension;

  SurfaceFilm({
    required this.position,
    required this.area,
    required this.thickness,
    required this.opacity,
    required this.life,
    required this.flowDirection,
    required this.viscosity,
    required this.surfaceTension,
  });
}

class VolumetricSplash {
  Vector2 position;
  double initialRadius;
  double currentRadius;
  double maxRadius;
  double expansionRate;
  double intensity;
  double life;
  double volumeDensity;
  double refractionStrength;

  VolumetricSplash({
    required this.position,
    required this.initialRadius,
    required this.maxRadius,
    required this.expansionRate,
    required this.intensity,
    required this.life,
    required this.volumeDensity,
    required this.refractionStrength,
  }) : currentRadius = initialRadius;
}

class RefractionEffect {
  Vector2 position;
  double strength;
  double radius;
  double life;
  double causticIntensity;

  RefractionEffect({
    required this.position,
    required this.strength,
    required this.radius,
    required this.life,
    required this.causticIntensity,
  });
}

// Ultra high-end painter
class UltraRealisticRainPainter extends CustomPainter {
  final List<HydrodynamicDroplet> primaryDroplets;
  final List<MicroDroplet> microDroplets;
  final List<SurfaceFilm> surfaceFilms;
  final List<VolumetricSplash> volumetricSplashes;
  final List<RefractionEffect> refractions;
  final Rect? boxBounds;
  final double masterTime;
  final double windTime;
  final double microTime;
  final double intensity;
  final double averageFPS;

  UltraRealisticRainPainter({
    required this.primaryDroplets,
    required this.microDroplets,
    required this.surfaceFilms,
    required this.volumetricSplashes,
    required this.refractions,
    this.boxBounds,
    required this.masterTime,
    required this.windTime,
    required this.microTime,
    required this.intensity,
    required this.averageFPS,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Performance-adaptive rendering
    final renderQuality = _calculateRenderQuality();

    // Only draw clean raindrops - no pooling or splash effects
    _drawHydrodynamicDroplets(canvas, size, renderQuality);
    _drawMicroDroplets(canvas, size, renderQuality);
  }

  double _calculateRenderQuality() {
    // Adaptive quality based on performance
    if (averageFPS > 55) return 1.0;
    if (averageFPS > 45) return 0.8;
    if (averageFPS > 30) return 0.6;
    return 0.4;
  }

  void _drawHydrodynamicDroplets(Canvas canvas, Size size, double quality) {
    for (final droplet in primaryDroplets) {
      final center = Offset(
        droplet.position.x * size.width,
        droplet.position.y * size.height,
      );

      // Draw sophisticated trail with physics-based opacity
      if (droplet.trail.length > 1 && quality > 0.5) {
        _drawAdvancedTrail(canvas, droplet, size);
      }

      // Main droplet with volumetric rendering
      _drawVolumetricDroplet(canvas, center, droplet, quality);

      // Advanced optical effects
      if (quality > 0.7) {
        _drawDropletCaustics(canvas, center, droplet);
        _drawSurfaceReflection(canvas, center, droplet);
      }
    }
  }

  void _drawAdvancedTrail(Canvas canvas, HydrodynamicDroplet droplet, Size size) {
    if (droplet.trail.length < 2) return;

    final path = Path();
    final List<Offset> points = droplet.trail.map((point) => Offset(
      point.position.x * size.width,
      point.position.y * size.height,
    )).toList();

    // Smooth curve through trail points
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length - 1; i++) {
      final cp1 = Offset(
        (points[i].dx + points[i - 1].dx) / 2,
        (points[i].dy + points[i - 1].dy) / 2,
      );
      final cp2 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        (points[i].dy + points[i + 1].dy) / 2,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }

    // Variable width trail based on velocity
    for (int i = 0; i < droplet.trail.length - 1; i++) {
      final t = i / (droplet.trail.length - 1);
      final alpha = (1 - t) * droplet.opacity * 0.6;
      final width = droplet.radius * (1 - t * 0.7) * (1 + droplet.trail[i].velocity * 0.1);

      final segmentPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: alpha * 0.9),
            Colors.white.withValues(alpha: alpha * 0.4),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: points[i], radius: width))
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, width * 0.3);

      canvas.drawLine(points[i], points[i + 1], segmentPaint);
    }
  }

  void _drawVolumetricDroplet(Canvas canvas, Offset center, HydrodynamicDroplet droplet, double quality) {
    // Deformation-aware droplet shape
    final effectiveRadius = droplet.radius * (1 + droplet.deformation * 0.8);
    final aspectRatio = 1.0 + droplet.deformation;

    // Multi-layer volumetric rendering
    final layers = quality > 0.8 ? 4 : (quality > 0.5 ? 3 : 2);

    for (int layer = layers - 1; layer >= 0; layer--) {
      final layerAlpha = droplet.opacity * (0.3 + 0.7 * (layer + 1) / layers);
      final layerRadius = effectiveRadius * (0.5 + 0.5 * (layer + 1) / layers);

      final gradient = RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [
          Colors.white.withValues(alpha: layerAlpha * 0.95),
          Colors.white.withValues(alpha: layerAlpha * 0.8),
          Colors.white.withValues(alpha: layerAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: layerRadius))
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, layerRadius * 0.15);

      // Apply deformation transform
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(droplet.rotation);
      canvas.scale(1.0, aspectRatio);
      canvas.translate(-center.dx, -center.dy);

      canvas.drawCircle(center, layerRadius, paint);
      canvas.restore();
    }

    // Specular highlight with physics-based positioning
    if (quality > 0.6) {
      final highlightOffset = Offset(
        -droplet.radius * 0.4 * cos(droplet.rotation),
        -droplet.radius * 0.4 * sin(droplet.rotation),
      );

      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: droplet.opacity * 0.8)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, droplet.radius * 0.2);

      canvas.drawCircle(
        center + highlightOffset,
        droplet.radius * 0.35,
        highlightPaint,
      );
    }
  }

  void _drawDropletCaustics(Canvas canvas, Offset center, HydrodynamicDroplet droplet) {
    final causticStrength = (droplet.refractionIndex - 1.0) * droplet.opacity;

    final causticPaint = Paint()
      ..color = Colors.white.withValues(alpha: causticStrength * 0.3)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3.0);

    // Caustic pattern
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3 + droplet.rotation;
      final causticCenter = center + Offset(
        cos(angle) * droplet.radius * 1.5,
        sin(angle) * droplet.radius * 1.5,
      );

      canvas.drawCircle(causticCenter, droplet.radius * 0.2, causticPaint);
    }
  }

  void _drawSurfaceReflection(Canvas canvas, Offset center, HydrodynamicDroplet droplet) {
    if (boxBounds == null) return;

    final reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: droplet.opacity * 0.15)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, boxBounds!.bottom - 5),
        width: droplet.radius * 3,
        height: droplet.radius * 0.8,
      ),
      reflectionPaint,
    );
  }

  void _drawMicroDroplets(Canvas canvas, Size size, double quality) {
    if (quality < 0.5) return;

    for (final micro in microDroplets) {
      final center = Offset(
        micro.position.x * size.width,
        micro.position.y * size.height,
      );

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: micro.opacity * micro.life * 0.7)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, micro.size * 0.5);

      canvas.drawCircle(center, micro.size, paint);
    }
  }

  void _drawSurfaceFilms(Canvas canvas, Size size, double quality) {
    if (quality < 0.6) return;

    for (final film in surfaceFilms) {
      final center = Offset(
        film.position.x * size.width,
        film.position.y * size.height,
      );

      final filmPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: film.opacity * 0.6),
            Colors.white.withValues(alpha: film.opacity * 0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: sqrt(film.area) * 5))
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4.0);

      canvas.drawCircle(center, sqrt(film.area) * 5, filmPaint);
    }
  }

  void _drawVolumetricSplashes(Canvas canvas, Size size, double quality) {
    for (final splash in volumetricSplashes) {
      final center = Offset(
        splash.position.x * size.width,
        splash.position.y * size.height,
      );

      // Main ripple
      final ripplePaint = Paint()
        ..color = Colors.white.withValues(alpha: splash.intensity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + splash.refractionStrength * 3
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);

      canvas.drawCircle(center, splash.currentRadius, ripplePaint);

      // Volumetric inner splash
      if (quality > 0.7 && splash.life > 0.6) {
        final volumePaint = Paint()
          ..color = Colors.white.withValues(alpha: splash.intensity * splash.life * 0.9)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, splash.currentRadius * 0.3);

        canvas.drawCircle(center, splash.currentRadius * 0.4, volumePaint);
      }

      // Caustic rings for high-intensity splashes
      if (quality > 0.8 && splash.volumeDensity > 0.5) {
        for (int ring = 1; ring <= 3; ring++) {
          final ringPaint = Paint()
            ..color = Colors.white.withValues(alpha: splash.intensity * 0.2 / ring)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.0);

          canvas.drawCircle(center, splash.currentRadius * (1 + ring * 0.3), ringPaint);
        }
      }
    }
  }

  void _drawRefractionEffects(Canvas canvas, Size size, double quality) {
    if (quality < 0.8) return;

    for (final refraction in refractions) {
      final center = Offset(
        refraction.position.x * size.width,
        refraction.position.y * size.height,
      );

      // Caustic effect
      final causticPaint = Paint()
        ..color = Colors.white.withValues(alpha: refraction.causticIntensity * 0.4)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5.0);

      canvas.drawCircle(center, refraction.radius, causticPaint);
    }
  }

  @override
  bool shouldRepaint(UltraRealisticRainPainter oldDelegate) => true;
}