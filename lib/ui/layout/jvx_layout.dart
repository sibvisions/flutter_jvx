import 'package:flutter/material.dart';
import 'i_layout.dart';
import '../component/i_component.dart';

abstract class JVxLayout<E> implements ILayout<E> {
  
  /// The constraints for all components used by this layout.
  Map<IComponent, E> layoutConstraints = <IComponent, E>{};
  /// the layout margins. */
  EdgeInsets margins = EdgeInsets.zero;
  /// the horizontal gap between components.
  int	horizontalGap = 0;
  /// the vertical gap between components.
  int	verticalGap = 0;

  void parseFromString(String layoutString) {
    List<String> parameter = layoutString?.split(",");

    double top = double.parse(parameter[1]);
    double left = double.parse(parameter[2]);
    double bottom = double.parse(parameter[3]);
    double right = double.parse(parameter[4]);

    margins = EdgeInsets.fromLTRB(left, top, right, bottom);
    horizontalGap = int.parse(parameter[5]);
    verticalGap = int.parse(parameter[6]);
  }

  static String getLayoutName(String layoutString) {
    List<String> parameter = layoutString?.split(",");
    return parameter[0];
  }

}