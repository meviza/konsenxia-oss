import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KONSENXIALogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showText;
  final bool isDark;

  const KONSENXIALogo({
    super.key,
    this.size = 40,
    this.color,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? (isDark ? Colors.white : const Color(0xFF2563EB));
    final secondaryColor = isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF0D9488);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon - Medical Cross with Neural Network Design
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                secondaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: size * 0.2,
                offset: Offset(0, size * 0.1),
              ),
            ],
          ),
          child: CustomPaint(
            size: Size(size, size),
            painter: _KONSENXIAIconPainter(
              primaryColor: Colors.white,
              secondaryColor: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        
        // Logo Text
        if (showText) ...[
          SizedBox(width: size * 0.15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'KONSENXIA',
                style: GoogleFonts.inter(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Healthcare AI',
                style: GoogleFonts.inter(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _KONSENXIAIconPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _KONSENXIAIconPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.08;
    final crossLength = size.width * 0.35;
    final nodeRadius = size.width * 0.06;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Draw medical cross
    final crossHorizontal = Path()
      ..moveTo(center.dx - crossLength / 2, center.dy)
      ..lineTo(center.dx + crossLength / 2, center.dy);

    final crossVertical = Path()
      ..moveTo(center.dx, center.dy - crossLength / 2)
      ..lineTo(center.dx, center.dy + crossLength / 2);

    canvas.drawPath(crossHorizontal, paint);
    canvas.drawPath(crossVertical, paint);

    // Draw neural network nodes
    final nodes = [
      // Top nodes
      Offset(center.dx - crossLength / 3, center.dy - crossLength / 3),
      Offset(center.dx + crossLength / 3, center.dy - crossLength / 3),
      // Bottom nodes
      Offset(center.dx - crossLength / 3, center.dy + crossLength / 3),
      Offset(center.dx + crossLength / 3, center.dy + crossLength / 3),
      // Side nodes
      Offset(center.dx - crossLength / 2, center.dy),
      Offset(center.dx + crossLength / 2, center.dy),
    ];

    // Draw connections
    final connectionPaint = Paint()
      ..color = secondaryColor.withOpacity(0.6)
      ..strokeWidth = strokeWidth * 0.5
      ..strokeCap = StrokeCap.round;

    // Connect nodes to center
    for (final node in nodes) {
      canvas.drawLine(center, node, connectionPaint);
    }

    // Draw nodes
    for (final node in nodes) {
      canvas.drawCircle(node, nodeRadius, nodePaint);
    }

    // Draw center node
    canvas.drawCircle(center, nodeRadius * 1.2, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KONSENXIABranding {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color accentGreen = Color(0xFF16A34A);
  static const Color accentCyan = Color(0xFF0891B2);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0F172A);

  // Typography
  static const String fontFamily = 'Inter';
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryTeal],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceWhite, Color(0xFFF8FAFC)],
  );

  // Brand Values
  static const List<String> brandValues = [
    'Innovation in Healthcare',
    'AI-Powered Insights',
    'Doctor Collaboration',
    'Patient Privacy',
    'Medical Excellence',
  ];

  // Brand Taglines
  static const List<String> taglines = [
    'Intelligent Healthcare Collaboration',
    'AI-Enhanced Medical Insights',
    'Connecting Medical Minds',
    'Future of Healthcare Today',
  ];

  // Brand Voice
  static const String brandVoice = 'Professional, Innovative, Caring, Trustworthy';
}
