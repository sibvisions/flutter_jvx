import 'package:flutter_client/src/model/api/response/api_response.dart';

import '../../../model/command/base_command.dart';

abstract class IProcessor<T extends ApiResponse> {
  List<BaseCommand> processResponse({required T pResponse});
}