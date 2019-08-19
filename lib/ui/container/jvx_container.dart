import 'package:flutter/material.dart';
import 'i_container.dart';
import '../component/jvx_component.dart';
import '../layouts/i_layout.dart';

abstract class JVxContainer extends JVxComponent implements IContainer {
  ILayout layout;
  JVxContainer(Key componentId) : super(componentId);
}