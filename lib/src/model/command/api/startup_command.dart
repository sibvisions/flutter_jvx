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

  /// Width of the screen (display area)
  final double? screenWidth;

  /// Height of the screen (display area)
  final double? screenHeight;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  StartupCommand({
    required String reason,
    this.appName,
    this.username,
    this.password,
    this.screenHeight,
    this.screenWidth,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => "StartupCommand | Reason: $reason | Username: $username | Password: $password";
}
