import 'dart:core';
import 'package:flutter/material.dart';
import '../../model/component_properties.dart';
import '../layout/jvx_layout.dart';
import '../component/i_component.dart';

abstract class IContainer extends IComponent {
  JVxLayout layout;
  void add(IComponent pComponent);
  void addWithConstraints(IComponent pComponent, String pConstraints);
  void addWithIndex(IComponent pComponent, int pIndex);
  void addWithContraintsAndIndex(IComponent pComponent, String pConstraints, int pIndex);
  void remove(int pIndex);
  void removeWithComponent(IComponent pComponent);
  void removeAll();
  void updateComponentProperties(Key componentId, ComponentProperties properties);
}