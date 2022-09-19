import '../../../../../model/command/api/download_images_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_download_images_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class DownloadImagesCommandProcessor implements ICommandProcessor<DownloadImagesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadImagesCommand command) {
    return IApiService().sendRequest(request: ApiDownloadImagesRequest());
  }
}
