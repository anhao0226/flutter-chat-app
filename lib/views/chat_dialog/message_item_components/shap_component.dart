// MessageWrap
import 'package:desktop_app/views/chat_dialog/theme.dart';
import 'package:flutter/material.dart';

class ShapeWrapComponent extends StatelessWidget {
  const ShapeWrapComponent({
    super.key,
    required this.child,
    required this.onTap,
    required this.onLongPress,
    required this.theme,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final MessageTheme theme;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        clipBehavior: Clip.hardEdge,
        constraints: const BoxConstraints(minHeight: 36.0),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: theme.borderRadius,
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: theme.borderRadius,
          child: child,
        ),
      ),
    );
  }
}

// TrianglePainter
class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 1,
      this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(x, y / 2)
      ..lineTo(0, y)
      ..lineTo(0, 0);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
