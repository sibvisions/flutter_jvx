import '../base_command.dart';
import 'ui_command.dart';

/// Command to execute a custom function as a command.
class FunctionCommand extends UiCommand {
  final Future<List<BaseCommand>> Function() function;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FunctionCommand({
    required this.function,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "FunctionCommand{${super.toString()}}";
  }
}
