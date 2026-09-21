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

  Color _resolveColor(Color c, bool isDark) {
    if (isDark) return c;
    if (c == SystemColors.cyanGlow) return SystemColors.lightCyanGlow;
    if (c == SystemColors.monarchPurple || c == SystemColors.monarchViolet || c == SystemColors.purpleShadow) {
      return SystemColors.lightMonarchPurple;
    }
    if (c == SystemColors.crimsonGlow || c == SystemColors.penaltyRed) {
      return SystemColors.lightCrimson;
    }
    if (c == SystemColors.goldAccent) return SystemColors.lightGoldAccent;
    if (c == SystemColors.hpGreen) return SystemColors.lightHpGreen;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = SystemTheme.isDark(context);
    final effectiveBorderColor = _resolveColor(borderColor, isDark);
    final effectiveTitleColor = _resolveColor(titleColor, isDark);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark
            ? SystemColors.panelBg.withValues(alpha: 0.85)
            : SystemColors.lightPanelBg,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: isDark
              ? effectiveBorderColor.withValues(alpha: 0.5)
              : effectiveBorderColor.withValues(alpha: 0.55),
          width: isDark ? 1.2 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? effectiveBorderColor.withValues(alpha: 0.18)
                : effectiveBorderColor.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: isDark ? Colors.black87 : const Color(0x0C0F172A),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: isDark ? 2 : 0,
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
              child: _CornerBracket(color: effectiveBorderColor, isTop: true, isLeft: true),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: _CornerBracket(color: effectiveBorderColor, isTop: true, isLeft: false),
            ),
            Positioned(
              bottom: 2,
              left: 2,
              child: _CornerBracket(color: effectiveBorderColor, isTop: false, isLeft: true),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: _CornerBracket(color: effectiveBorderColor, isTop: false, isLeft: false),
            ),
          ],

          // Window Content
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
                              color: effectiveTitleColor,
                              boxShadow: [
                                BoxShadow(
                                  color: effectiveTitleColor.withValues(alpha: 0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              title.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                color: effectiveTitleColor,
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
                        effectiveBorderColor.withValues(alpha: 0.6),
                        effectiveBorderColor.withValues(alpha: 0.1),
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
      size: const Size(10, 10),
      painter: _CornerBracketPainter(
        color: color,
        isTop: isTop,
        isLeft: isLeft,
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final bool isLeft;

  _CornerBracketPainter({
    required this.color,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isTop != isTop ||
        oldDelegate.isLeft != isLeft;
  }
}
