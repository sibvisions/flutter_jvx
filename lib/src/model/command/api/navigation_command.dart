import 'package:flutter_client/src/model/api/requests/api_navigation_request.dart';
import 'package:flutter_client/src/model/command/api/api_command.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

/// Command to send [ApiNavigationRequest] to remote server, will get screenName
/// from [IUiService]
class NavigationCommand extends ApiCommand {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  NavigationCommand({
    required String reason
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}