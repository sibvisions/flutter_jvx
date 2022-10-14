import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/upload_action_command.dart';
import '../../../../model/request/i_api_request.dart';
import '../../../../model/response/upload_action_response.dart';
import '../i_response_processor.dart';

class UploadActionProcessor implements IResponseProcessor<UploadActionResponse> {
  @override
  List<BaseCommand> processResponse(UploadActionResponse pResponse, IApiRequest? pRequest) {
    return [
      UploadActionCommand(
        fileId: pResponse.fileId,
        reason: "Upload from server",
      )
    ];
  }
}
