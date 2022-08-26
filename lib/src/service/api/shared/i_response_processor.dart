import '../../../model/command/base_command.dart';
import '../../../model/response/api_response.dart';

abstract class IResponseProcessor<T extends ApiResponse> {
  List<BaseCommand> processResponse({required T pResponse});
}
