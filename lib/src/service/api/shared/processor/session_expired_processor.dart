import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../../../model/response/view/message/session_expired_response.dart';
import '../i_response_processor.dart';

class SessionExpiredProcessor implements IResponseProcessor<SessionExpiredResponse> {
  @override
  List<BaseCommand> processResponse({required SessionExpiredResponse pResponse}) {
    OpenSessionExpiredDialogCommand command = OpenSessionExpiredDialogCommand(
      title: pResponse.title,
      message: pResponse.message ?? "Session has expired",
      reason: "Server sent session expired",
    );

    return [command];
  }
}
