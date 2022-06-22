import 'package:flutter/material.dart';

import '../base_command.dart';

abstract class DataCommand extends BaseCommand {
  DataCommand({
    required String reason,
    VoidCallback? callback,
  }) : super(reason: reason, callback: callback);
}
