import '../../../flutter_ui.dart';
import 'api_command.dart';

class LogoutCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LogoutCommand({
    required super.reason,
  }) {
    afterProcessing = () {
      // Beamer's history also contains the present!
      FlutterUI.clearHistory();
      FlutterUI.clearServices();
    };
    onFinish = () {
      // We have to clear the history only after routing, as before the past location would have not benn counted as "history".
      FlutterUI.clearLocationHistory();
    };
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "LogoutCommand{${super.toString()}}";
  }
}
