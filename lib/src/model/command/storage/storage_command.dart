import 'package:flutter/foundation.dart';

import '../base_command.dart';

///
/// Super class for all StorageCommands
///
abstract class StorageCommand extends BaseCommand {
  StorageCommand({required String reason, VoidCallback? callback}) : super(reason: reason, callback: callback);
}
