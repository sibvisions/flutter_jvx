import '../../../../model/command/base_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/application_parameters_response.dart';
import '../i_response_processor.dart';

class ApplicationParametersProcessor implements IResponseProcessor<ApplicationParametersResponse> {
  @override
  List<BaseCommand> processResponse(ApplicationParametersResponse pResponse, ApiRequest? pRequest) {
    List<BaseCommand> commands = [];
    //TODO use application parameters

    return commands;
  }
}
