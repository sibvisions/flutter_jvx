import 'dart:ui';

import 'package:flutter_client/src/model/command/layout/layout_command.dart';

class SetSizeCommand extends LayoutCommand {

  Size size;
  String componentId;

  SetSizeCommand({
    required this.size,
    required this.componentId,
    required String reason,
  }) : super(reason: reason);
}