import 'package:flutter_client/src/model/api/response/close_screen_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/storage/delete_screen_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class CloseScreenProcessor implements IProcessor{
  @override
  List<BaseCommand> processResponse(json) {
    CloseScreenResponse closeScreenResponse = CloseScreenResponse.fromJson(json: json);

    return [DeleteScreenCommand(screenName: closeScreenResponse.componentId, reason: "reason")];

  }
}