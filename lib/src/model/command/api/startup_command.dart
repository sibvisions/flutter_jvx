import 'api_command.dart';

class StartupCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The password
  final String? password;

  /// The username
  final String? username;

  /// Width of the screen (display area)
  final double? screenWidth;

  /// Height of the screen (display area)
  final double? screenHeight;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  StartupCommand({
    required String reason,
    this.password,
    this.username,
    this.screenHeight,
    this.screenWidth,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => "StartupCommand | Reason: $reason | Username: $username | Password: $password";
}
