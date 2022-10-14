import 'dart:async';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/download_action_command.dart';
import '../../../../../model/request/api_download_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class DownloadActionCommandProcessor implements ICommandProcessor<DownloadActionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadActionCommand command) async {
    return IApiService().sendRequest(
      ApiDownloadRequest(
        url: command.url,
        fileId: command.fileId,
        fileName: command.fileName,
      ),
    );
  }
}
