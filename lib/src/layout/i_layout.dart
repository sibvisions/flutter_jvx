import 'package:flutter_jvx/src/models/layout/layout_constraints.dart';
import 'package:flutter_jvx/src/models/layout/layout_parent.dart';

/// Defines the base construct of a layout.
abstract class ILayout {
  ///Calculates the constraints and widths and heigths of the children components.
  List<LayoutConstraints> calculateLayout(LayoutParent parent);
}
