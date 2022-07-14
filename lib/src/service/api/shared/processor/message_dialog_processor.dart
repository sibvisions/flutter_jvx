import '../../../../model/api/response/message_dialog_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/open_message_dialog_command.dart';
import '../i_response_processor.dart';

class MessageDialogProcessor implements IResponseProcessor<MessageDialogResponse> {
  @override
  List<BaseCommand> processResponse({required MessageDialogResponse pResponse}) {
    return [
      OpenMessageDialogCommand(
        reason: "Message.dialog from server",
        message: pResponse.message,
        messageScreenName: pResponse.messageScreenName,
      )
    ];
  }
}
