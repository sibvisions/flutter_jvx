import 'package:flutter/material.dart';

class CustomShapeBorder extends ShapeBorder {
  final double borderWidth;
  final Color color;

  CustomShapeBorder(
    this.borderWidth,
    this.color,
  );

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.only();

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.width / 2 - 80, rect.top)
      ..addRect(Rect.fromLTRB((rect.width / 2) - 80, rect.top,
          (rect.width / 2) + 80, rect.top - 40))
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    TextSpan span = new TextSpan(style: TextStyle(color: Colors.black), text: 'HALLO');
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();

    Paint paint = new Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    
    canvas.drawPath(getOuterPath(rect), paint);
    tp.paint(canvas, new Offset((rect.width / 2) - 20, rect.top - 20));
  }

  @override
  ShapeBorder scale(double t) {
    return null;
  }
}
