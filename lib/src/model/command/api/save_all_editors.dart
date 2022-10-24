import 'api_command.dart';

class SaveAllEditorsCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String? componentId;

  SaveAllEditorsCommand({this.componentId, required super.reason});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "SaveAllEditorsCommand{${super.toString()}}";
  }
}
