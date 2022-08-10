import 'package:flutter/widgets.dart';

import '../base_command.dart';

abstract class ConfigCommand extends BaseCommand {
  ConfigCommand({
    required String reason,
    VoidCallback? callback,
  }) : super(reason: reason, callback: callback);
}
