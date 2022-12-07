import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/save_components_command.dart';
import '../../../../model/command/ui/route_to_work_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/generic_screen_view_response.dart';
import '../../../config/i_config_service.dart';
import '../i_response_processor.dart';

/// Processes [GenericScreenViewResponse], will separate (and parse) new and changed components, can also open screens
/// based on the 'update' property of the request.
///
/// Possible return Commands : [SaveComponentsCommand], [RouteCommand]
class GenericScreenViewProcessor implements IResponseProcessor<GenericScreenViewResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(GenericScreenViewResponse pResponse, ApiRequest? pRequest) {
    List<BaseCommand> commands = [];

    // Handle New & Changed Components
    // Get new full components
    SaveComponentsCommand saveComponentsCommand = SaveComponentsCommand.fromJson(
      components: pResponse.changedComponents!,
      screenName: pResponse.screenName,
      originRequest: pRequest,
      reason: "Api received screen.generic response",
    );
    commands.add(saveComponentsCommand);

    // Handle Screen Opening
    // if update == false => new screen that should be routed to
    if (!pResponse.update && !IConfigService().isOffline()) {
      RouteToWorkCommand workCommand = RouteToWorkCommand(
        screenName: pResponse.screenName,
        reason: "Server sent screen.generic response with update = 'false'",
      );
      commands.add(workCommand);
    }
    return commands;
  }
}
