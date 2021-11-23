import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/layout/layout_command.dart';

class PreferredSizeCommand extends LayoutCommand {
  final String componentId;
  final Size size;

  PreferredSizeCommand({
    required this.size,
    required this.componentId,
    required String reason,
  }) : super(reason: reason);
}