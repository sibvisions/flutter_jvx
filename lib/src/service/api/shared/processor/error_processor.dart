import 'package:flutter_client/src/model/api/response/error_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class ErrorProcessor implements IProcessor<ErrorResponse> {


  @override
  List<BaseCommand> processResponse({required ErrorResponse pResponse}) {


    OpenErrorDialogCommand command = OpenErrorDialogCommand(
        reason: "Server sent error in response",
        message: pResponse.message
    );

    return [command];
  }

}