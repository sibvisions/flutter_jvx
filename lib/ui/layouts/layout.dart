import 'package:flutter/material.dart';
import 'i_layout.dart';
import '../component/i_component.dart';

class Layout<E> implements ILayout<E> {
  
  /// The constraints for all components used by this layout.
  Map<IComponent, E> layoutConstraints = <IComponent, E>{};
  /// the layout margins. */
  EdgeInsets margins = EdgeInsets.zero;
  /// the horizontal gap between components.
  int	horizontalGap;
  /// the vertical gap between components.
  int	verticalGap;

    Widget getWidget() {
      return null;
    }
}