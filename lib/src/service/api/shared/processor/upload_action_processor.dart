import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/upload_action_command.dart';
import '../../../../model/response/upload_action_response.dart';
import '../i_response_processor.dart';

class UploadActionProcessor implements IResponseProcessor<UploadActionResponse> {
  @override
  List<BaseCommand> processResponse({required UploadActionResponse pResponse}) {
    return [
      UploadActionCommand(
        fileId: pResponse.fileId,
        reason: "Upload from server",
      )
    ];
  }
}
