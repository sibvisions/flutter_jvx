import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/view/message/message_dialog_response.dart';
import '../i_response_processor.dart';

class MessageDialogProcessor implements IResponseProcessor<MessageDialogResponse> {
  @override
  List<BaseCommand> processResponse(MessageDialogResponse pResponse, ApiRequest? pRequest) {
    return [
      OpenMessageDialogCommand(
        componentId: pResponse.componentId,
        closable: pResponse.closable,
        buttonType: pResponse.buttonType,
        okComponentId: pResponse.okComponentId,
        notOkComponentId: pResponse.notOkComponentId,
        cancelComponentId: pResponse.cancelComponentId,
        okText: pResponse.okText,
        notOkText: pResponse.notOkText,
        cancelText: pResponse.cancelText,
        title: pResponse.title,
        message: pResponse.message,
        reason: "Message.dialog from server",
      )
    ];
  }
}
