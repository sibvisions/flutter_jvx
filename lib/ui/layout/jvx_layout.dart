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
    
  }
}