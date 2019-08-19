import 'dart:core';
import '../layouts/i_layout.dart';
import '../component/i_component.dart';

abstract class IContainer extends IComponent {
  ILayout layout;
  void add(IComponent pComponent);
  void addWithConstraints(IComponent pComponent, Object pConstraints);
  void remove(IComponent pComponent);
}