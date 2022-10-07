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
    onFinish = () => IUiService().getAppManager()?.onSuccessfulStartup();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "StartupCommand{appName: $appName, username: $username, ${super.toString()}}";
  }
}
