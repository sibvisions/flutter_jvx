import '../../../service/ui/i_ui_service.dart';
import '../../request/api_navigation_request.dart';
import 'api_command.dart';

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
    required this.openScreen,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'NavigationCommand{openScreen: $openScreen, ${super.toString()}}';
  }
}
