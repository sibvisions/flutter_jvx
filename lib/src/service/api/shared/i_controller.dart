import '../../../model/command/base_command.dart';
import 'package:http/http.dart';

abstract class IController {
  Future<List<BaseCommand>> processResponse(Future<Response> response);
}