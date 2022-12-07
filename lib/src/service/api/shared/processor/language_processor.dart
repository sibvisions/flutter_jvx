import '../../../../model/command/base_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/language_response.dart';
import '../../../config/i_config_service.dart';
import '../i_response_processor.dart';

class LanguageProcessor implements IResponseProcessor<LanguageResponse> {
  @override
  List<BaseCommand> processResponse(LanguageResponse pResponse, ApiRequest? pRequest) {
    IConfigService().setLanguage(pResponse.langCode);
    return [];
  }
}
