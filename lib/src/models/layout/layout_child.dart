import 'dart:ui';

import 'package:flutter_jvx/src/models/layout/layout_data.dart';

class LayoutChild {
  final String id;
  String? constraints;
  Size? preferredSize;
  LayoutData? setSize;

  LayoutChild({
    required this.id,
    this.constraints,
    this.setSize,
    this.preferredSize
  });
}