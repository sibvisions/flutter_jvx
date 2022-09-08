import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/api/upload_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_upload_request.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class UploadCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<UploadCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UploadCommand command) async {
    IConfigService configService = getConfigService();

    ApiUploadRequest startUpRequest = ApiUploadRequest(
      clientId: configService.getClientId()!,
      file: command.file,
      fileId: command.fileId,
    );

    return getApiService().sendRequest(request: startUpRequest);
  }
}
