
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';

/// Layout contraints to define widget position:
///           NORTH
/// WEST    CENTER      EAST
///           SOUTH
enum JVxBorderLayoutConstraints {
  North,
  South,
  West,
  East,
  Center
}

JVxBorderLayoutConstraints getJVxBorderLayoutConstraintsFromString(String jvxBorderLayoutConstraintsString) {
  jvxBorderLayoutConstraintsString = 'JVxBorderLayoutConstraints.$jvxBorderLayoutConstraintsString';
  return JVxBorderLayoutConstraints.values.firstWhere((f)=> f.toString() == jvxBorderLayoutConstraintsString, orElse: () => null);
}

class JVxBorderLayoutConstraintData {

  JVxBorderLayoutConstraints constraints;
  JVxComponent comp;

  JVxBorderLayoutConstraintData(this.constraints, this.comp);
}

