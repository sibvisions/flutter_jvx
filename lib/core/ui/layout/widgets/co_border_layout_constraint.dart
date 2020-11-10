
import '../../component/component_widget.dart';

/// Layout contraints to define widget position:
///           NORTH
/// WEST    CENTER      EAST
///           SOUTH
enum CoBorderLayoutConstraints { North, South, West, East, Center }

CoBorderLayoutConstraints getBorderLayoutConstraintsFromString(
    String borderLayoutConstraintsString) {
  borderLayoutConstraintsString =
      'CoBorderLayoutConstraints.$borderLayoutConstraintsString';
  return CoBorderLayoutConstraints.values.firstWhere(
      (f) => f.toString() == borderLayoutConstraintsString,
      orElse: () => null);
}

class CoBorderLayoutConstraintData {
  CoBorderLayoutConstraints constraints;
  ComponentWidget comp;

  CoBorderLayoutConstraintData(this.constraints, this.comp);
}
