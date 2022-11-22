import 'package:flutter/cupertino.dart';

/// Creates a path like this
///
/// ```
/// x
/// x
/// x
/// xx
///  xxxx
///     xxxxxxxxxxxxxxxxxxxxxxxxxx
///                              x
///                              x
///           This is the        x
///              inside          x
///                              x
///                              x
///     xxxxxxxxxxxxxxxxxxxxxxxxxx
///  xxxx
/// xx
/// x
/// x
/// x
/// ```
class MiddleClipperWithDoubleCurve extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 75.0;
    double topInset = size.height / 3;
    double bottomInset = 150.0;
    double additionalRadius = 20.0;

    return Path()
      ..lineTo(0.0, topInset - radius)
      ..quadraticBezierTo(0.0, topInset, radius + additionalRadius, topInset)
      ..lineTo(size.width, topInset)
      ..lineTo(size.width, size.height - bottomInset)
      ..lineTo(0.0 + radius + additionalRadius, size.height - bottomInset)
      ..quadraticBezierTo(0.0, size.height - bottomInset, 0.0, size.height - bottomInset + radius)
      ..lineTo(0.0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
