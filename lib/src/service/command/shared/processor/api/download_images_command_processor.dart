import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_download_images_request.dart';
import '../../../../../model/command/api/download_images_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class DownloadImagesCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceMixin
    implements ICommandProcessor<DownloadImagesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadImagesCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      ApiDownloadImagesRequest downloadImagesRequest = ApiDownloadImagesRequest(
        clientId: clientId,
      );

      return getApiService().sendRequest(request: downloadImagesRequest);
    }

    return [];
  }
}
