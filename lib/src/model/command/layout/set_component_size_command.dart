import 'package:flutter/material.dart';

import 'layout_command.dart';

class SetComponentSizeCommand extends LayoutCommand {
  /// Id of component to set Size.
  final String componentId;

  /// Constraint size of component.
  final Size size;

  SetComponentSizeCommand({
    required this.componentId,
    required this.size,
    required String reason,
  }) : super(reason: reason);

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
