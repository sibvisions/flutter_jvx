import '../../../../../model/command/api/download_style_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_download_style_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class DownloadStyleCommandProcessor implements ICommandProcessor<DownloadStyleCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadStyleCommand command) {
    return IApiService().sendRequest(request: ApiDownloadStyleRequest());
  }
}
