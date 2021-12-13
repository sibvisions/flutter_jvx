import 'package:http/http.dart';

import '../../../model/command/base_command.dart';

abstract class IController {
  Future<List<BaseCommand>> processResponse(Future<Response> response);
}
