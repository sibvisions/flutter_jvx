import '../base_command.dart';

///
/// SuperClass for all ApiCommands
///
abstract class ApiCommand extends BaseCommand {
  ApiCommand({
    required String reason,
    super.callback,
  }) : super(reason: reason);
}
