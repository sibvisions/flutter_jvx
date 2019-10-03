import 'dart:core';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/layout/jvx_layout.dart';

abstract class IContainer extends IComponent {
  JVxLayout layout;
  void add(IComponent pComponent);
  void addWithConstraints(IComponent pComponent, String pConstraints);
  void addWithIndex(IComponent pComponent, int pIndex);
  void addWithContraintsAndIndex(IComponent pComponent, String pConstraints, int pIndex);
  void remove(int pIndex);
  void removeWithComponent(IComponent pComponent);
  void removeAll();
  void updateComponentProperties(Key componentId, ChangedComponent changedComponent);
}