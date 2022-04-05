import '../../../../model/api/response/application_parameter_response.dart';
import '../../../../model/command/base_command.dart';
import '../i_processor.dart';

class ApplicationParametersProcessor implements IProcessor<ApplicationParametersResponse> {
  @override
  List<BaseCommand> processResponse({required ApplicationParametersResponse pResponse}) {
    List<BaseCommand> commands = [];
    ApplicationParametersResponse response = pResponse;



    return commands;
  }
}
