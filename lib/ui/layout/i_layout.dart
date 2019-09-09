import 'package:flutter/material.dart';
import '../component/i_component.dart';

abstract class ILayout<E>  {

  /// The constraints for all components used by this layout.
  Map<IComponent, E> layoutConstraints = <IComponent, E>{};
  /// the layout margins. */
  EdgeInsets margins = EdgeInsets.zero;
  /// the horizontal gap between components.
  int	horizontalGap = 0;
  /// the vertical gap between components.
  int	verticalGap = 0;

  E getConstraints(IComponent comp);
  void addLayoutComponent(IComponent pComponent, E pConstraints);
  void removeLayoutComponent(IComponent pComponent);
  void updateLayoutData(String layoutData);
  Widget getWidget();
}