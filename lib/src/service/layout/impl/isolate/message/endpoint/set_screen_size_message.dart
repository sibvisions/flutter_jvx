import 'package:flutter/material.dart';

import '../../../../../isolate/isolate_message.dart';
import '../../../../../../model/command/base_command.dart';

class SetScreenSizeMessage extends IsolateMessage<List<BaseCommand>> {
  final String componentId;

  final Size size;

  SetScreenSizeMessage({required this.size, required this.componentId});
}
