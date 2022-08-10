import 'package:flutter/widgets.dart';

import '../base_command.dart';

abstract class LayoutCommand extends BaseCommand {
  LayoutCommand({
    required String reason,
    VoidCallback? callback,
  }) : super(reason: reason, callback: callback);
}
