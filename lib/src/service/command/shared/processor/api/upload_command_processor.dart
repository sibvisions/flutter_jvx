import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/api/upload_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_upload_request.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class UploadCommandProcessor with ApiServiceMixin implements ICommandProcessor<UploadCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UploadCommand command) async {
    return getApiService().sendRequest(
      request: ApiUploadRequest(
        file: command.file,
        fileId: command.fileId,
      ),
    );
  }
}
