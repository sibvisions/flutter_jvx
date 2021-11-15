import 'package:flutter_jvx/src/layout/i_layout.dart';
import 'package:flutter_jvx/src/models/layout/layout_child.dart';
import 'package:flutter_jvx/src/models/layout/layout_constraints.dart';
import 'package:flutter_jvx/src/models/layout/layout_parent.dart';
import '../util/extensions/list_extensions.dart';

/// Layout contraints to define widget position:
///
/// \_\_\_\_\_\_\_ NORTH \_\_\_\_\_\_\_\_
///
/// WEST \| CENTER \| EAST
///
/// ‾‾‾‾‾‾‾ SOUTH ‾‾‾‾‾‾‾‾
enum BorderLayoutConstraint { north, east, south, west, center }

/// The BorderLayout allows the positioning of container in 5 different Positions.
/// North, East, West, South and Center.
/// North and South are above/underneath West, Center and East
/// East and West are left/right of center.
///
/// \_\_\_\_\_\_\_ NORTH \_\_\_\_\_\_\_\_
///
/// WEST \| CENTER \| EAST
///
/// ‾‾‾‾‾‾‾ SOUTH ‾‾‾‾‾‾‾‾
///
class BorderLayout extends ILayout {
  // ignore: constant_identifier_names
  static const BorderLayoutConstraint NORTH = BorderLayoutConstraint.north;
  // ignore: constant_identifier_names
  static const BorderLayoutConstraint EAST = BorderLayoutConstraint.east;
  // ignore: constant_identifier_names
  static const BorderLayoutConstraint SOUTH = BorderLayoutConstraint.south;
  // ignore: constant_identifier_names
  static const BorderLayoutConstraint WEST = BorderLayoutConstraint.west;
  // ignore: constant_identifier_names
  static const BorderLayoutConstraint CENTER = BorderLayoutConstraint.center;

  @override
  List<LayoutConstraints> calculateLayout(LayoutParent parent) {
    LayoutChild? north = parent.children.firstWhereOrNull(
        (element) => NORTH == getLayout(element.constraints ?? "CENTER"));

    LayoutChild? south = parent.children.firstWhereOrNull(
        (element) => SOUTH == getLayout(element.constraints ?? "CENTER"));

    LayoutChild? east = parent.children.firstWhereOrNull(
        (element) => EAST == getLayout(element.constraints ?? "CENTER"));

    LayoutChild? west = parent.children.firstWhereOrNull(
        (element) => WEST == getLayout(element.constraints ?? "CENTER"));

    LayoutChild? center = parent.children.firstWhereOrNull(
        (element) => NORTH == getLayout(element.constraints ?? "NORTH"));

    throw UnsupportedError("Not implemented yet");
  }

  static BorderLayoutConstraint? getLayout(String constraint) {
    switch (constraint) {
      case "BorderLayoutConstraint.north":
      case "NORTH":
        return NORTH;
      case "BorderLayoutConstraint.east":
      case "EAST":
        return EAST;
      case "BorderLayoutConstraint.south":
      case "SOUTH":
        return SOUTH;
      case "BorderLayoutConstraint.west":
      case "WEST":
        return WEST;
      case "BorderLayoutConstraint.center":
      case "CENTER":
        return CENTER;
      default:
        throw UnsupportedError(
            "The constraint \"$constraint\" was not vaild as a BorderLayoutConstraint");
    }
  }
}
