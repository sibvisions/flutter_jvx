import 'package:flutter_client/src/model/command/ui/route_to_menu_command.dart';

import '../../../../model/api/response/close_screen_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/storage/delete_screen_command.dart';
import '../i_processor.dart';

class CloseScreenProcessor implements IProcessor<CloseScreenResponse> {
  @override
  List<BaseCommand> processResponse({required CloseScreenResponse pResponse}) {
    List<BaseCommand> commands = [];

    CloseScreenResponse closeScreenResponse = pResponse;
    DeleteScreenCommand deleteScreenCommand = DeleteScreenCommand(
        screenName: closeScreenResponse.componentId,
        reason: "reason"
    );
    commands.add(deleteScreenCommand);

    RouteToMenuCommand routeToMenuCommand = RouteToMenuCommand(
        reason: "The Screen was closed",
        replaceRoute: true
    );
    commands.add(routeToMenuCommand);

    return commands;
  }
}
