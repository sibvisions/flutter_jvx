import 'package:flutter/cupertino.dart';

import '../base_command.dart';

abstract class ConfigCommand extends BaseCommand {
  ConfigCommand({
    required String reason,
    VoidCallback? callback,
  }) : super(reason: reason, callback: callback);
}
