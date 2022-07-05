import 'package:flutter_client/src/model/api/requests/api_navigation_request.dart';
import 'package:flutter_client/src/model/command/api/api_command.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

/// Command to send [ApiNavigationRequest] to remote server, will get screenName
/// from [IUiService]
class NavigationCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Screen name to navigate
  final String openScreen;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  NavigationCommand({
    required String reason,
    required this.openScreen,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => "NavigationCommand: openscreen: $openScreen, reason: $reason";
}
