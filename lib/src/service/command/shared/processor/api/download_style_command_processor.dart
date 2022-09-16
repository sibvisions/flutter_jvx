import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/download_style_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_download_style_request.dart';
import '../../i_command_processor.dart';

class DownloadStyleCommandProcessor with ApiServiceMixin implements ICommandProcessor<DownloadStyleCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadStyleCommand command) {
    return getApiService().sendRequest(request: ApiDownloadStyleRequest());
  }
}
