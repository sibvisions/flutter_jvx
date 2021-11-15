import 'dart:ui';

import 'package:flutter_jvx/src/models/layout/layout_constraints.dart';

class LayoutChild {
  final String id;
  String parentId;
  String? constraints;
  Size? preferredSize;
  LayoutConstraints? setSize;

  LayoutChild(
      {required this.id,
      required this.parentId,
      this.constraints,
      this.setSize,
      this.preferredSize});
}
