import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlixoraLogo extends StatelessWidget {
  final double size;
  final bool withTagline;
  final String? tagline;

  const FlixoraLogo({
    super.key,
    this.size = 32,
    this.withTagline = false,
    this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // SKY
              Text(
                "SKY",
                style: GoogleFonts.outfit(
                  fontSize: size,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(width: size * 0.15),
              // LIVE
              IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShaderMask(
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
                          fontSize: size * 0.825,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFE50914).withValues(alpha: 0.6),
                              blurRadius: size * 0.2,
                              offset: Offset(0, size * 0.05),
                            )
                          ],
                        ),
                      ),
                    ),
                    // Underline
                    Container(
                      margin: EdgeInsets.only(top: size * 0.025),
                      height: size * 0.075,
                      child: CustomPaint(
                        painter: _StaticTaperedLinePainter(
                          color: const Color(0xFFFF1E27),
                          glowColor: const Color(0xE6E50914),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (withTagline && tagline != null) ...[
            SizedBox(height: size * 0.15),
            Text(
              tagline!.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFFB1B1B1),
                fontSize: size * 0.2,
                letterSpacing: size * 0.08,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StaticTaperedLinePainter extends CustomPainter {
  final Color color;
  final Color glowColor;

  _StaticTaperedLinePainter({
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double startThickness = size.height * 0.15; 
    final double endThickness = size.height;
    final double centerY = size.height / 2;
    final double halfStart = startThickness / 2;
    final double halfEnd = endThickness / 2;
    final double w = size.width;

    final Path path = Path();
    path.moveTo(halfStart, centerY - halfStart);
    path.lineTo(w - halfEnd, centerY - halfEnd);
    path.arcToPoint(
      Offset(w - halfEnd, centerY + halfEnd),
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

    final Paint shadowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, shadowPaint);

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _StaticTaperedLinePainter oldDelegate) => false;
}
