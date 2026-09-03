import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/system_theme.dart';

class SystemWindow extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final Color borderColor;
  final Color titleColor;
  final bool showCornerBrackets;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const SystemWindow({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.borderColor = SystemColors.cyanGlow,
    this.titleColor = SystemColors.cyanGlow,
    this.showCornerBrackets = true,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: SystemColors.panelBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.18),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.black87,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner accents (holographic brackets)
          if (showCornerBrackets) ...[
            Positioned(
              top: 2,
              left: 2,
              child: _CornerBracket(color: borderColor, isTop: true, isLeft: true),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: _CornerBracket(color: borderColor, isTop: true, isLeft: false),
            ),
            Positioned(
              bottom: 2,
              left: 2,
              child: _CornerBracket(color: borderColor, isTop: false, isLeft: true),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: _CornerBracket(color: borderColor, isTop: false, isLeft: false),
            ),
          ],

          // Content
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: titleColor,
                              boxShadow: [
                                BoxShadow(
                                  color: titleColor.withValues(alpha: 0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              title.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                color: titleColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 12),
                // Divider line with subtle glow
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        borderColor.withValues(alpha: 0.6),
                        borderColor.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final Color color;
  final bool isTop;
  final bool isLeft;

  const _CornerBracket({
    required this.color,
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _CornerPainter(color: color, isTop: isTop, isLeft: isLeft),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final bool isLeft;

  _CornerPainter({
    required this.color,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
