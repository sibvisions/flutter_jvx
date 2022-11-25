import '../../../../custom/app_manager.dart';
import '../ui/function_command.dart';
import 'api_command.dart';

class SaveAllEditorsCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String? componentId;

  FunctionCommand? thenFunctionCommand;

  SaveAllEditorsCommand({this.componentId, required super.reason, Future<List<BaseCommand>> Function()? pFunction}) {
    if (pFunction != null) {
      thenFunctionCommand = FunctionCommand(function: pFunction, reason: "After save all editing");
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "SaveAllEditorsCommand{${super.toString()}}";
  }
}
