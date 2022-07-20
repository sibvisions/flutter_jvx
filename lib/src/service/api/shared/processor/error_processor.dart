import '../../../../model/api/response/error_view_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/open_error_dialog_command.dart';
import '../i_response_processor.dart';

class ErrorProcessor implements IResponseProcessor<ErrorViewResponse> {
  @override
  List<BaseCommand> processResponse({required ErrorViewResponse pResponse}) {
    OpenErrorDialogCommand command = OpenErrorDialogCommand(
      reason: "Server sent error in response",
      message: pResponse.message,
      isTimeout: pResponse.isTimeout,
    );

    return [command];
  }
}
