import 'dart:async';

import '../../../../../../mixin/services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/download_action_command.dart';
import '../../../../../model/request/api_download_request.dart';
import '../../i_command_processor.dart';

class DownloadActionCommandProcessor with ApiServiceMixin implements ICommandProcessor<DownloadActionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadActionCommand command) async {
    return getApiService().sendRequest(
      request: ApiDownloadRequest(
        url: command.url,
        fileId: command.fileId,
        fileName: command.fileName,
      ),
    );
  }
}
