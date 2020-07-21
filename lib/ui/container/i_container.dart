import 'dart:core';
import 'package:flutter/material.dart';
import '../../model/changed_component.dart';
import '../../ui/component/i_component.dart';
import '../layout/co_layout.dart';

abstract class IContainer extends IComponent {
  CoLayout layout;
  List<IComponent> components = new List<IComponent>();

  void add(IComponent pComponent);
  void addWithConstraints(IComponent pComponent, String pConstraints);
  void addWithIndex(IComponent pComponent, int pIndex);
  void addWithContraintsAndIndex(
      IComponent pComponent, String pConstraints, int pIndex);
  void remove(int pIndex);
  void removeWithComponent(IComponent pComponent);
  void removeAll();
  void updateComponentProperties(
      Key componentId, ChangedComponent changedComponent);
}
