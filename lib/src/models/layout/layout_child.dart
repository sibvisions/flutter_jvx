import 'dart:ui';

class LayoutChild {
  final String id;
  String? constraints;
  Size? preferredSize;

  LayoutChild({
    required this.id,
    this.constraints,
    this.preferredSize
  });
}