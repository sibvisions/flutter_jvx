import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'layout_command.dart';

class PreferredSizeCommand extends LayoutCommand {
  final String componentId;
  final String parentId;
  final LayoutData layoutData;

  PreferredSizeCommand({
    required this.layoutData,
    required this.parentId,
    required this.componentId,
    required String reason,
  }) : super(reason: reason);
}