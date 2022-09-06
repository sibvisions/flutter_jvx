import '../../../../mixin/ui_service_mixin.dart';
import 'api_command.dart';

class StartupCommand extends ApiCommand with UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The app name
  final String? appName;

  /// The username
  final String? username;

  /// The password
  final String? password;

  /// If the server must create a new session
  bool? forceNewSession;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  StartupCommand({
    this.appName,
    this.username,
    this.password,
    this.forceNewSession,
    required super.reason,
  }) {
    callback = () => getUiService().getAppManager()?.onSuccessfulStartup();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'StartupCommand{appName: $appName, username: $username, forceNewSession: $forceNewSession, ${super.toString()}}';
  }
}
