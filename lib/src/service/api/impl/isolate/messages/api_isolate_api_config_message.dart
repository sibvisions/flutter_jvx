import '../../../../../model/config/api/api_config.dart';
import 'api_isolate_message.dart';

class ApiIsolateApiConfigMessage extends ApiIsolateMessage {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiConfig apiConfig;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiIsolateApiConfigMessage({required this.apiConfig});
}
