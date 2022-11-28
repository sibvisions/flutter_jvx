import '../../../flutter_jvx.dart';
import '../../../service/ui/i_ui_service.dart';
import 'api_command.dart';

class StartupCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The app name
  final String? appName;

  /// The username
  final String? username;

  /// The password
  final String? password;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  StartupCommand({
    this.appName,
    this.username,
    this.password,
    super.showLoading,
    required super.reason,
  }) {
    beforeProcessing = () => IUiService().getAppManager()?.onInitStartup();
    afterProcessing = () {
      // Beamer's history also contains the present!
      FlutterJVx.clearHistory();
      FlutterJVx.clearServices();
      FlutterJVx.resetPageBucket();
    };
    onFinish = () {
      // We have to clear the history only after routing, as before the past location would have not benn counted as "history".
      FlutterJVx.clearLocationHistory();
      IUiService().getAppManager()?.onSuccessfulStartup();
    };
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "StartupCommand{appName: $appName, username: $username, ${super.toString()}}";
  }
}
