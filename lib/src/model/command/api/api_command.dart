import 'dart:ui';

import '../base_command.dart';

///
/// SuperClass for all ApiCommands
///
abstract class ApiCommand extends BaseCommand {
  ApiCommand({
    required String reason,
    VoidCallback? callback,
  }) : super(reason: reason, callback: callback);
}
