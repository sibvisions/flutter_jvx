import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/view/message/session_expired_response.dart';
import '../i_response_processor.dart';

class SessionExpiredProcessor implements IResponseProcessor<SessionExpiredResponse> {
  @override
  List<BaseCommand> processResponse(SessionExpiredResponse pResponse, ApiRequest? pRequest) {
    return [
      OpenSessionExpiredDialogCommand(
        title: pResponse.title,
        message: pResponse.message,
        reason: "Server sent session expired",
      )
    ];
  }
}
