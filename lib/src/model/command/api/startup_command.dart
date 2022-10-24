import '../../../../flutter_jvx.dart';
import '../../../../services.dart';
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
      routerDelegate.beamingHistory.clear();
      ILayoutService().clear();
      IStorageService().clear();
      IDataService().clear();
      IUiService().clear();
    };
    onFinish = () {
      // We have to clear the history only after routing, as before the past location would have not benn counted as "history".
      routerDelegate.currentBeamLocation.history.clear();
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
