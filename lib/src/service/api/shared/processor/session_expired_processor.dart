import 'package:flutter_client/src/model/api/response/session_expired_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_session_expired_dialog_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class SessionExpiredProcessor implements IProcessor<SessionExpiredResponse> {

  @override
  List<BaseCommand> processResponse({required SessionExpiredResponse pResponse}) {
    OpenSessionExpiredDialogCommand command = OpenSessionExpiredDialogCommand(
        message: pResponse.message ?? "Session has expired",
        reason: "Server sent session expired"
    );

    return [command];
  }
}