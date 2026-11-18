import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
//  SplashScreen â€” Redesigned with AppColors tokens
// â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _ambient;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<double> _textSlide;

  // â”€â”€â”€ Updated duration: 2800ms (was 2500ms) â”€â”€â”€
  static const Duration _totalDuration = Duration(milliseconds: 2800);

  // â”€â”€â”€ Updated particle count: 65 (was 55) â”€â”€â”€
  final List<_Particle3D> _particles = List.generate(65, (index) {
    final random = math.Random();
    final isCyan = random.nextDouble() < 0.5;
    // â”€â”€â”€ Use AppColors tokens â”€â”€â”€
    final color = isCyan
        ? const Color(0xFF00E5FF)  // AppColors.accentCyan
        : const Color(0xFFFF007F); // AppColors.accentMagenta
    return _Particle3D(
      (random.nextDouble() - 0.5) * 600,
      (random.nextDouble() - 0.5) * 600,
      random.nextDouble() * 600 - 200,
      random.nextDouble() * 1.5 + 0.5,
      color,
      random.nextDouble() * 1.3 + 0.7,
      random.nextDouble() * 2 * math.pi,
    );
  });

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: _totalDuration);

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    Curve span(double a, double b, [Curve c = Curves.easeOut]) =>
        Interval(a, b, curve: c);

    _logoFade = const AlwaysStoppedAnimation<double>(1.0);
    _logoScale = const AlwaysStoppedAnimation<double>(1.0);

    _textFade = CurvedAnimation(
      parent: _entrance,
      curve: span(0.45, 0.80, Curves.easeIn),
    );

    _textSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: span(0.45, 0.80, Curves.easeOutBack),
      ),
    );

    _entrance.forward();

    // â”€â”€â”€ Updated transition duration: 500ms (was 400ms) â”€â”€â”€
    Future.delayed(_totalDuration + const Duration(milliseconds: 200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  void _updateParticles(double progress) {
    final double assemblyProgress = (progress / 0.50).clamp(0.0, 1.0);
    final double easeDecel = 1.0 - math.pow(1.0 - assemblyProgress, 3).toDouble();
    final double speedFactor = _lerp(22.0, 4.0, easeDecel);

    for (var p in _particles) {
      p.z -= speedFactor * p.speedMultiplier;
      p.twinklePhase += 0.05 + (1.0 - easeDecel) * 0.07;
      if (p.z < -100) {
        final random = math.Random();
        p.z = 500;
        p.x = (random.nextDouble() - 0.5) * 600;
        p.y = (random.nextDouble() - 0.5) * 600;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_entrance, _ambient]),
        builder: (context, _) {
          final progress = _entrance.value;
          _updateParticles(progress);

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AmbientGlowPainter(_ambient.value),
                ),
              ),

              Positioned.fill(
                child: Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: CustomPaint(
                      painter: _LogoAssemblyPainter3DOccluded(
                        progress: progress,
                        particles: _particles,
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: Offset(0, 85 + _textSlide.value),
                  child: Opacity(
                    opacity: _textFade.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // â”€â”€â”€ Updated: fontSize 36, letterSpacing 5 â”€â”€â”€
                        Text(
                          'SKY LIVE',
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 5,
                            height: 1.0,
                            shadows: const [
                              Shadow(
                                color: Color(0xFF00E5FF), // AppColors.accentCyan
                                blurRadius: 20,
                              ),
                              Shadow(
                                color: Colors.white,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // â”€â”€â”€ Updated: letterSpacing 6 (was 5) â”€â”€â”€
                        Text(
                          'THE PULSE OF ENTERTAINMENT',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFC8C8C8),
                            fontSize: 10,
                            letterSpacing: 6.0,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.9),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// â”€â”€â”€ Particle3D model â”€â”€â”€
class _Particle3D {
  double x;
  double y;
  double z;
  final double speedMultiplier;
  final Color color;
  final double baseSize;
  double twinklePhase;

  _Particle3D(
    this.x,
    this.y,
    this.z,
    this.speedMultiplier,
    this.color,
    this.baseSize,
    this.twinklePhase,
  );

  Offset project(Size size, double cameraDistance) {
    final factor = cameraDistance / (z + cameraDistance);
    return Offset(
      size.width / 2 + x * factor,
      size.height / 2 + y * factor,
    );
  }
}

// â”€â”€â”€ Point3D helper â”€â”€â”€
class Point3D {
  double x, y, z;
  Point3D(this.x, this.y, this.z);

  Point3D rotateY(double rad) {
    final cosA = math.cos(rad);
    final sinA = math.sin(rad);
    return Point3D(
      x * cosA - z * sinA,
      y,
      x * sinA + z * cosA,
    );
  }

  Point3D rotateX(double rad) {
    final cosA = math.cos(rad);
    final sinA = math.sin(rad);
    return Point3D(
      x,
      y * cosA - z * sinA,
      y * sinA + z * cosA,
    );
  }

  Offset project(Size size, double cameraDistance) {
    final factor = cameraDistance / (z + cameraDistance);
    return Offset(
      size.width / 2 + x * factor,
      size.height / 2 + y * factor,
    );
  }
}

// â”€â”€â”€ Logo Assembly Painter (3D Occluded) â”€â”€â”€
class _LogoAssemblyPainter3DOccluded extends CustomPainter {
  final double progress;
  final List<_Particle3D> particles;

  _LogoAssemblyPainter3DOccluded({
    required this.progress,
    required this.particles,
  });

  double _easeOutQuint(double t) {
    return 1.0 - math.pow(1.0 - t, 5).toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.shortestSide * 0.16;
    const cameraDistance = 300.0;

    for (var p in particles) {
      if (p.z > 0) {
        final projectedPos = p.project(size, cameraDistance);
        final factor = cameraDistance / (p.z + cameraDistance);

        final twinkle = 0.7 + 0.3 * math.sin(p.twinklePhase);

        final trailPaint = Paint()
          ..color = p.color.withValues(alpha: 0.14 * factor * twinkle)
          ..strokeWidth = 1.6 * factor
          ..strokeCap = StrokeCap.round;

        final prevPos = Offset(
          size.width / 2 + p.x * (cameraDistance / (p.z + 15.0 + cameraDistance)),
          size.height / 2 + p.y * (cameraDistance / (p.z + 15.0 + cameraDistance)),
        );

        canvas.drawLine(projectedPos, prevPos, trailPaint);

        final sparkPaint = Paint()
          ..color = p.color.withValues(alpha: 0.9 * twinkle)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, factor * 0.4);

        canvas.drawCircle(projectedPos, p.baseSize * factor * twinkle, sparkPaint);
      }
    }

    final double assemblyProgress = 1.0;
    final double assemblyEase = 1.0;
    final double dofBlur = 0.0;

    final R = baseRadius * 1.8;
    final int segments = 120;

    final double spinY = progress * 8.0 * math.pi;
    final double rotX = -0.3;

    Point3D rotate(Point3D p, double rx, double ry) {
      final cosX = math.cos(rx);
      final sinX = math.sin(rx);
      double y1 = p.y * cosX - p.z * sinX;
      double z1 = p.y * sinX + p.z * cosX;
      final cosY = math.cos(ry);
      final sinY = math.sin(ry);
      double x2 = p.x * cosY - z1 * sinY;
      double z2 = p.x * sinY + z1 * cosY;
      return Point3D(x2, y1, z2);
    }

    Offset project(Point3D p) {
      final factor = cameraDistance / (p.z + cameraDistance);
      return Offset(center.dx + p.x * factor, center.dy + p.y * factor);
    }

    final int visibleSegments = segments;

    void buildPaths(Path back, Path front, bool invertZ, int drawLimit) {
      final pts = <Point3D>[];
      for (int i = 0; i <= drawLimit; i++) {
        final t = (i / segments) * 2 * math.pi;
        double x = R * math.cos(t);
        double y = R * 0.4 * math.sin(2 * t);
        double z = R * 0.4 * math.sin(t);
        if (invertZ) z = -z;
        pts.add(rotate(Point3D(x, y, z), rotX, spinY));
      }

      bool? wasBack;
      for (int i = 0; i < pts.length - 1; i++) {
        final p1 = pts[i];
        final p2 = pts[i + 1];
        final avgZ = (p1.z + p2.z) / 2;
        final isBack = avgZ > 0;
        final proj1 = project(p1);
        final proj2 = project(p2);

        if (isBack) {
          if (wasBack != true) back.moveTo(proj1.dx, proj1.dy);
          back.lineTo(proj2.dx, proj2.dy);
        } else {
          if (wasBack != false) front.moveTo(proj1.dx, proj1.dy);
          front.lineTo(proj2.dx, proj2.dy);
        }
        wasBack = isBack;
      }
    }

    Path path1Back = Path();
    Path path1Front = Path();
    Path path2Back = Path();
    Path path2Front = Path();

    buildPaths(path1Back, path1Front, false, visibleSegments);
    buildPaths(path2Back, path2Front, true, visibleSegments);

    Paint getRibbonPaint(Color color, double width, {double blur = 0}) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color;
      final totalBlur = blur + dofBlur;
      if (totalBlur > 0) {
        p.maskFilter = MaskFilter.blur(BlurStyle.normal, totalBlur);
      }
      return p;
    }

    // â”€â”€â”€ Use AppColors tokens â”€â”€â”€
    const cyanMain = Color(0xFF00E5FF);    // AppColors.accentCyan
    const magentaMain = Color(0xFFFF007F); // AppColors.accentMagenta

    void drawRibbon(Path path, Color color) {
      canvas.drawPath(path, getRibbonPaint(color.withValues(alpha: 0.3), baseRadius * 0.3, blur: baseRadius * 0.15));
      canvas.drawPath(path, getRibbonPaint(color.withValues(alpha: 0.6), baseRadius * 0.12, blur: baseRadius * 0.05));
      canvas.drawPath(path, getRibbonPaint(Colors.white, baseRadius * 0.04));
    }

    void drawOrb() {
      final orbRadius = baseRadius * 0.45;
      if (orbRadius <= 0) return;

      // â”€â”€â”€ Use AppColors.orbPurple â”€â”€â”€
      final orbPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            const Color(0xFF8A2BE2).withValues(alpha: 0.8), // AppColors.orbPurple
            const Color(0xFF4B0082).withValues(alpha: 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: orbRadius * 1.5));

      if (dofBlur > 0) {
        orbPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, dofBlur);
      }

      canvas.drawCircle(center, orbRadius, orbPaint);

      final highlightPaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.6), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center - Offset(orbRadius*0.3, orbRadius*0.3), radius: orbRadius*0.5));
      canvas.drawCircle(center, orbRadius, highlightPaint);
    }

    drawRibbon(path1Back, cyanMain);
    drawRibbon(path2Back, magentaMain);
    drawOrb();
    drawRibbon(path1Front, cyanMain);
    drawRibbon(path2Front, magentaMain);

    // Dual-chromatic continuous shockwaves
    final double waveProgressCyan = (progress * 2.0) % 1.0;
    if (waveProgressCyan > 0.0 && waveProgressCyan < 1.0) {
      final double waveRadius = baseRadius * (1.0 + 2.6 * waveProgressCyan);
      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = baseRadius * 0.06 * (1.0 - waveProgressCyan)
        ..color = cyanMain.withValues(alpha: (1.0 - waveProgressCyan) * 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, baseRadius * 0.08);
      canvas.drawCircle(center, waveRadius, wavePaint);
    }

    final double waveProgressMagenta = ((progress * 2.0) + 0.5) % 1.0;
    if (waveProgressMagenta > 0.0 && waveProgressMagenta < 1.0) {
      final double waveRadius = baseRadius * (1.0 + 1.6 * waveProgressMagenta);
      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = baseRadius * 0.035 * (1.0 - waveProgressMagenta)
        ..color = magentaMain.withValues(alpha: (1.0 - waveProgressMagenta) * 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, baseRadius * 0.04);
      canvas.drawCircle(center, waveRadius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// â”€â”€â”€ Ambient Glow Painter â”€â”€â”€
class _AmbientGlowPainter extends CustomPainter {
  final double animationVal;
  _AmbientGlowPainter(this.animationVal);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double pulse = 0.55 + 0.45 * animationVal;
    final double radius = size.shortestSide * 0.85 * pulse;

    // â”€â”€â”€ Use AppColors tokens â”€â”€â”€
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8A2BE2).withValues(alpha: 0.18), // AppColors.orbPurple
          const Color(0xFFFF007F).withValues(alpha: 0.05), // AppColors.accentMagenta
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _AmbientGlowPainter oldDelegate) =>
      oldDelegate.animationVal != animationVal;
}
