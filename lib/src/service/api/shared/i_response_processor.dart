import '../../../model/response/api_response.dart';
import '../../../model/command/base_command.dart';

abstract class IResponseProcessor<T extends ApiResponse> {
  List<BaseCommand> processResponse({required T pResponse});
}
