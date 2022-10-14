import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_download_translation_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class DownloadTranslationCommandProcessor implements ICommandProcessor<DownloadTranslationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DownloadTranslationCommand command) {
    return IApiService().sendRequest(ApiDownloadTranslationRequest());
  }
}
