import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/open_message_dialog_command.dart';
import '../../../../model/response/view/message/message_dialog_response.dart';
import '../i_response_processor.dart';

class MessageDialogProcessor implements IResponseProcessor<MessageDialogResponse> {
  @override
  List<BaseCommand> processResponse({required MessageDialogResponse pResponse}) {
    return [
      OpenMessageDialogCommand(
        reason: "Message.dialog from server",
        message: pResponse.message!,
        componentId: pResponse.componentId,
      )
    ];
  }
}
