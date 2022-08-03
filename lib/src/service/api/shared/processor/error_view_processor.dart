import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/open_error_dialog_command.dart';
import '../../../../model/response/error_view_response.dart';
import '../i_response_processor.dart';

class ErrorViewProcessor implements IResponseProcessor<ErrorViewResponse> {
  @override
  List<BaseCommand> processResponse({required ErrorViewResponse pResponse}) {
    OpenErrorDialogCommand command = OpenErrorDialogCommand(
      reason: "Server sent error in response",
      message: pResponse.message,
      isTimeout: pResponse.isTimeout,
      canBeFixedInSettings: isUserError(pResponse.message),
    );

    return [command];
  }

  /// Dirty error message check
  isUserError(String message) {
    if (message.toLowerCase().startsWith("invalid application:")) {
      return true;
    }
    return false;
  }
}
