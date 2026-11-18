import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../screens/main_shell.dart';
import 'package:google_fonts/google_fonts.dart';

class GyroSplashScreen extends StatefulWidget {
  const GyroSplashScreen({Key? key}) : super(key: key);

  @override
  State<GyroSplashScreen> createState() => _GyroSplashScreenState();
}

class _GyroSplashScreenState extends State<GyroSplashScreen> with TickerProviderStateMixin {
  late AnimationController _curtainController;
  late AnimationController _strokeController;
  late AnimationController _zoomController;

  // Curtain Animations
  late Animation<double> _curtain0Progress;
  late Animation<double> _curtain1Progress;
  late Animation<double> _curtain1bProgress;
  late Animation<double> _curtain2Progress;

  // Stroke Animations
  late Animation<double> _skyStrokeWidth;
  late Animation<double> _skyStrokeProgress;
  late Animation<double> _skyFillOpacity;

  late Animation<double> _liveScale;
  late Animation<double> _liveFillOpacity;

  late Animation<double> _underlineProgress;

  // Zoom Animations
  late Animation<double> _zoomScale;
  late Animation<double> _fadeOpacity;

  @override
  void initState() {
    super.initState();

    // 1. Curtains Controller
    _curtainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Curve to match CSS: 0% -> left:-1.5, 40% -> left:-0.1, 55% -> left:-0.1, 100% -> left:1.5
    final curtainCurve = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -1.5, end: -0.1)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(-0.1),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 1.5)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 45,
      ),
    ]);

    _curtain0Progress = curtainCurve.animate(
      CurvedAnimation(parent: _curtainController, curve: const Interval(0.0, 0.8)),
    );
    _curtain1Progress = curtainCurve.animate(
      CurvedAnimation(parent: _curtainController, curve: const Interval(0.05, 0.85)),
    );
    _curtain1bProgress = curtainCurve.animate(
      CurvedAnimation(parent: _curtainController, curve: const Interval(0.12, 0.92)),
    );
    _curtain2Progress = curtainCurve.animate(
      CurvedAnimation(parent: _curtainController, curve: const Interval(0.2, 1.0)),
    );

    // 2. Stroke Controller
    _strokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Sky Text Drawing
    _skyStrokeProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _strokeController, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );
    _skyStrokeWidth = Tween<double>(begin: 2.0, end: 0.0).animate(
      CurvedAnimation(parent: _strokeController, curve: const Interval(0.4, 0.6)),
    );
    _skyFillOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _strokeController, curve: const Interval(0.4, 0.6)),
    );

    // Live Text Appearance (Cinematic Stamp)
    _liveScale = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(parent: _strokeController, curve: const Interval(0.3, 0.65, curve: Curves.easeOutBack)),
    );
    _liveFillOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _strokeController, curve: const Interval(0.3, 0.5, curve: Curves.easeIn)),
    );

    // Underline
    _underlineProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _strokeController, curve: const Interval(0.65, 0.95, curve: Curves.easeOutQuart)),
    );

    // 3. Zoom Controller
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _zoomScale = Tween<double>(begin: 1.0, end: 15.0).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInExpo),
    );
    
    _fadeOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _zoomController, curve: const Interval(0.2, 1.0, curve: Curves.easeIn)),
    );

    // Orchestrate Timeline
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start curtains
    _curtainController.forward();
    
    // Start stroke drawing while curtains are finishing
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) _strokeController.forward();

    // Start fly-through zoom
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) _zoomController.forward();

    // Navigate to MainShell
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _curtainController.dispose();
    _strokeController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final curtainWidth = screenWidth * 1.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
          // Background (Static, no scaling)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF1A0202), Colors.black],
                ),
              ),
            ),
          ),
          
          // Brand Logo (Scaled up and faded out at the end)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _zoomController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _zoomScale.value,
                  child: Opacity(
                    opacity: _fadeOpacity.value,
                    child: child,
                  ),
                );
              },
              child: RepaintBoundary(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                            fit: BoxFit.scaleDown,
                            clipBehavior: Clip.none,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                // SKY
                                AnimatedBuilder(
                                  animation: _strokeController,
                                  builder: (context, child) {
                                      return _buildTextMask(
                                        text: "SKY",
                                        fontWeight: FontWeight.w900,
                                        strokeColor: Colors.white,
                                        fillColors: [Colors.white, Colors.white],
                                        strokeProgress: _skyStrokeProgress.value,
                                        strokeWidth: _skyStrokeWidth.value,
                                        fillOpacity: _skyFillOpacity.value,
                                        glowColor: Colors.white.withValues(alpha: 0.2),
                                        fontSize: 80,
                                      );
                                  },
                                ),
                                const SizedBox(width: 12),
                                // LIVE
                                AnimatedBuilder(
                                  animation: _strokeController,
                                  builder: (context, child) {
                                    return IntrinsicWidth(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Transform.scale(
                                            scale: _liveScale.value,
                                            alignment: Alignment.centerLeft,
                                            child: Opacity(
                                              opacity: _liveFillOpacity.value,
                                              child: ShaderMask(
                                                shaderCallback: (bounds) {
                                                  return const LinearGradient(
                                                    colors: [Color(0xFFFF4B4B), Color(0xFFE50914)],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ).createShader(bounds);
                                                },
                                                child: Text(
                                                  "LIVE ",
                                                  softWrap: false,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 66,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 2,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                        color: const Color(0xFFE50914).withValues(alpha: 0.6),
                                                        blurRadius: 15,
                                                        offset: const Offset(0, 4),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Underline (Tapered)
                                          Container(
                                            margin: const EdgeInsets.only(top: 2),
                                            height: 6,
                                            child: CustomPaint(
                                              painter: TaperedLinePainter(
                                                progress: _underlineProgress.value,
                                                color: const Color(0xFFFF1E27),
                                                glowColor: const Color(0xE6E50914),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtitle
                          AnimatedBuilder(
                            animation: _strokeController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _underlineProgress.value,
                                child: Text(
                                  "The Pulse of Entertainment",
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),

          // Curtain Layers overlaying the screen (Not scaled!)
          // Cinematic Curtain Overlaying the Screen
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _curtainController,
              builder: (context, child) {
                final screenWidth = MediaQuery.of(context).size.width;
                final curtainWidth = screenWidth * 1.5;
                
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Curtain 2: Absolute Black Void
                    _buildCurtain(
                      progress: _curtain2Progress.value,
                      width: curtainWidth,
                      colors: [const Color(0xFF000000), const Color(0xFF050000), const Color(0xFF110000)],
                      shadowColor: Colors.black,
                      shadowSpread: 50,
                    ),
                    // Curtain 1b: Deep Velvet Crimson
                    _buildCurtain(
                      progress: _curtain1bProgress.value,
                      width: curtainWidth,
                      colors: [const Color(0xEA2A0000), const Color(0xEA5A0000), const Color(0xEA990000)],
                      shadowColor: Colors.black,
                      shadowSpread: 30,
                      isGlass: true,
                    ),
                    // Curtain 1: Glowing Red Glass
                    _buildCurtain(
                      progress: _curtain1Progress.value,
                      width: curtainWidth,
                      colors: [const Color(0xDD770000), const Color(0xDDCC0000), const Color(0xDDFF1E27)],
                      shadowColor: const Color(0xFFE50914),
                      shadowSpread: 20,
                      isGlass: true,
                    ),
                    // Curtain 0: Laser Edge (Thin and Sharp)
                    _buildCurtain(
                      progress: _curtain0Progress.value,
                      width: curtainWidth * 0.1, // Much thinner, no massive milky stripe
                      colors: [Colors.transparent, Colors.white.withValues(alpha: 0.2)],
                      shadowColor: Colors.white.withValues(alpha: 0.5),
                      shadowSpread: 10,
                      leadingGlow: true,
                    ),
                  ],
                );
              },
            ),
          ),

          // Final Black Fade Overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _zoomController,
              builder: (context, child) {
                return IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: 1.0 - _fadeOpacity.value),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }



  Widget _buildCurtain({
    required double progress,
    required double width,
    required List<Color> colors,
    required Color shadowColor,
    required double shadowSpread,
    bool leadingGlow = false,
    bool isGlass = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Positioned(
      top: -200,
      bottom: -200,
      left: progress * screenWidth,
      child: Transform(
        transform: Matrix4.skewX(-20 * math.pi / 180),
        alignment: Alignment.center,
        child: Container(
          width: width * 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-1.0, -0.2),
              end: const Alignment(1.0, 0.2),
              colors: colors,
              stops: colors.length == 3 ? const [0.0, 0.6, 1.0] : null,
            ),
            border: isGlass ? Border(
              right: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 2.0),
            ) : null,
          ),
          child: Stack(
            children: [
              if (isGlass)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.2), // Brighter glass reflection
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              if (leadingGlow)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.white, blurRadius: 8, spreadRadius: 2),
                        BoxShadow(color: const Color(0xFFFF1E27), blurRadius: 20, spreadRadius: 8),
                        BoxShadow(color: const Color(0xFFE50914), blurRadius: 40, spreadRadius: 15),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextMask({
    required String text,
    required FontWeight fontWeight,
    required Color strokeColor,
    required List<Color> fillColors,
    required double strokeProgress,
    required double strokeWidth,
    required double fillOpacity,
    required Color glowColor,
    required double fontSize,
  }) {
    final baseStyle = GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 2,
    );

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.white,
            Colors.white,
            Colors.transparent,
            Colors.transparent,
          ],
          stops: [0.0, strokeProgress, strokeProgress + 0.1, 1.0],
        ).createShader(bounds);
      },
      child: Stack(
        children: [
          // Stroke Text
          if (strokeWidth > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12.0, left: 4.0),
              child: Text(
                text,
                softWrap: false,
                style: baseStyle.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = strokeWidth
                    ..color = strokeColor,
                ),
              ),
            ),
          // Fill Text
          Opacity(
            opacity: fillOpacity,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: fillColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, left: 4.0),
                child: Text(
                  text,
                  softWrap: false,
                  style: baseStyle.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: glowColor,
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class TaperedLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color glowColor;

  TaperedLinePainter({
    required this.progress,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final double currentWidth = size.width * progress;
    final double startThickness = 1.0; 
    final double maxThickness = size.height;
    
    final double endThicknessAtProgress = startThickness + progress * (maxThickness - startThickness);
    final double centerY = size.height / 2;
    final double halfStart = startThickness / 2;
    final double halfEnd = endThicknessAtProgress / 2;

    final Path path = Path();

    if (currentWidth <= halfStart + halfEnd) {
      path.addOval(Rect.fromCircle(center: Offset(currentWidth / 2, centerY), radius: currentWidth / 2));
    } else {
      path.moveTo(halfStart, centerY - halfStart);
      path.lineTo(currentWidth - halfEnd, centerY - halfEnd);
      path.arcToPoint(
        Offset(currentWidth - halfEnd, centerY + halfEnd),
        radius: Radius.circular(halfEnd),
        clockwise: true,
      );
      path.lineTo(halfStart, centerY + halfStart);
      path.arcToPoint(
        Offset(halfStart, centerY - halfStart),
        radius: Radius.circular(halfStart),
        clockwise: true,
      );
      path.close();
    }

    final Paint shadowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, shadowPaint);

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant TaperedLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

