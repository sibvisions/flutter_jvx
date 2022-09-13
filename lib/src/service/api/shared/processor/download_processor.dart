import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_download_command.dart';
import '../../../../model/response/download_response.dart';
import '../i_response_processor.dart';

class DownloadProcessor implements IResponseProcessor<DownloadResponse> {
  @override
  List<BaseCommand> processResponse({required DownloadResponse pResponse}) {
    return [
      SaveDownloadCommand(
        bodyBytes: pResponse.bodyBytes,
        fileId: pResponse.originalRequest.fileId,
        fileName: pResponse.originalRequest.fileName,
        reason: "Saving a file",
      )
    ];
  }
}
