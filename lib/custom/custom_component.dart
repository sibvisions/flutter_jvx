import 'package:flutter/material.dart';

/// Used to replace specific components in a screen
class CustomComponent {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the component
  final String componentName;

  /// Component that will replace the server sent component with matching name
  final Widget Function() componentFactory;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomComponent({
    required this.componentName,
    required this.componentFactory,
  });
}
