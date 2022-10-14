import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/download_action_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/download_action_response.dart';
import '../i_response_processor.dart';

class DownloadActionProcessor implements IResponseProcessor<DownloadActionResponse> {
  @override
  List<BaseCommand> processResponse(DownloadActionResponse pResponse, ApiRequest? pRequest) {
    String url = pResponse.url.split(";").first;

    return [
      DownloadActionCommand(
        fileId: pResponse.fileId,
        fileName: pResponse.fileName,
        url: url,
        reason: "Upload from server",
      )
    ];
  }
}
