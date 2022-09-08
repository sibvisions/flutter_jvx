import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_download_translation_request.dart';
import '../../i_command_processor.dart';

class DownloadTranslationCommandProcessor
    with ApiServiceGetterMixin
    implements ICommandProcessor<DownloadTranslationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadTranslationCommand command) {
    return getApiService().sendRequest(request: ApiDownloadTranslationRequest());
  }
}
