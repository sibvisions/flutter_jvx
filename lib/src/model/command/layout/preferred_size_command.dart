import 'package:flutter/material.dart';
import 'layout_command.dart';

class PreferredSizeCommand extends LayoutCommand {
  final String componentId;
  final Size size;
  final String parentId;
  final String constraints;

  PreferredSizeCommand({
    required this.constraints,
    required this.parentId,
    required this.size,
    required this.componentId,
    required String reason,
  }) : super(reason: reason);
}