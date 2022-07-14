import '../../../../model/api/response/application_parameter_response.dart';
import '../../../../model/command/base_command.dart';
import '../i_response_processor.dart';

class ApplicationParametersProcessor implements IResponseProcessor<ApplicationParametersResponse> {
  @override
  List<BaseCommand> processResponse({required ApplicationParametersResponse pResponse}) {
    List<BaseCommand> commands = [];
    //TODO use application parameters

    return commands;
  }
}
