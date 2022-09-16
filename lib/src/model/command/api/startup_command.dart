import '../../../../mixin/services.dart';
import 'api_command.dart';

class StartupCommand extends ApiCommand with UiServiceMixin {
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
    required super.reason,
  }) {
    callback = () => getUiService().getAppManager()?.onSuccessfulStartup();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'StartupCommand{appName: $appName, username: $username, ${super.toString()}}';
  }
}
