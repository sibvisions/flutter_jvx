import '../../../../flutter_ui.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/bad_client_response.dart';
import '../i_response_processor.dart';

class BadClientProcessor implements IResponseProcessor<BadClientResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(BadClientResponse pResponse, ApiRequest? pRequest) {
    FlutterUI.log.e(pResponse.info);
    return [
      OpenServerErrorDialogCommand(
        reason: "Server sent bad client in response",
        title: FlutterUI.translate("Invalid Server Version"),
        message: FlutterUI.translate("Server/Client Version mismatch. An Update is required!"),
        userError: true,
      )
    ];
  }
}
