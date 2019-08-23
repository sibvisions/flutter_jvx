import 'dart:core';
import '../layout/jvx_layout.dart';
import '../component/i_component.dart';

abstract class IContainer extends IComponent {
  JVxLayout layout;
  void add(IComponent pComponent);
  void addWithConstraints(IComponent pComponent, Object pConstraints);
  void addWithIndex(IComponent pComponent, int pIndex);
  void addWithContraintsAndIndex(IComponent pComponent, Object pConstraints, int pIndex);
  void remove(int pIndex);
  void removeWithComponent(IComponent pComponent);
  void removeAll();
}