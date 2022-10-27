import '../../../../flutter_jvx.dart';
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
      FlutterJVx.clearHistory();
      FlutterJVx.clearServices();
    };
    onFinish = () {
      // We have to clear the history only after routing, as before the past location would have not benn counted as "history".
      FlutterJVx.clearLocationHistory();
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
