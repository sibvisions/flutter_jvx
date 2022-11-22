import 'package:flutter/cupertino.dart';

/// Creates a path like this
///
/// ```
/// x
/// x         This is the
/// x            inside
/// xx
///  xxxx
///     xxxxxxxxxxxxxxxxxxxxxxxxxx
///
///        Rest of the screen
/// ```
class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 75.0;
    double height = size.height / 3;

    return Path()
      ..lineTo(0.0, height - radius)
      ..quadraticBezierTo(0.0, height, radius, height)
      ..lineTo(size.width, height)
      ..lineTo(size.width, 0.0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
