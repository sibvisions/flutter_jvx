import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/api/upload_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_upload_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class UploadCommandProcessor implements ICommandProcessor<UploadCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UploadCommand command) async {
    return IApiService().sendRequest(
      ApiUploadRequest(
        file: command.file,
        fileId: command.fileId,
      ),
    );
  }
}
