import 'package:flutter/widgets.dart';

import '../../../../../../model/command/base_command.dart';
import '../../../../../isolate/isolate_message.dart';

class SetScreenSizeMessage extends IsolateMessage<List<BaseCommand>> {
  final String componentId;

  final Size size;

  SetScreenSizeMessage({required this.size, required this.componentId});
}
