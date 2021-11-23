import 'package:flutter_client/src/model/command/base_command.dart';


///
/// SuperClass for all ApiCommands
///
abstract class ApiCommand extends BaseCommand {
  ApiCommand({
    required String reason,
  }) : super(reason: reason);
}