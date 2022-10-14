import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_download_command.dart';
import '../../../../model/request/api_download_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/download_response.dart';
import '../i_response_processor.dart';

class DownloadProcessor implements IResponseProcessor<DownloadResponse> {
  @override
  List<BaseCommand> processResponse(DownloadResponse pResponse, ApiRequest? pRequest) {
    if (pRequest is ApiDownloadRequest) {
      return [
        SaveDownloadCommand(
          bodyBytes: pResponse.bodyBytes,
          fileId: pRequest.fileId,
          fileName: pRequest.fileName,
          reason: "Saving a file",
        )
      ];
    } else {
      return [];
    }
  }
}
