import 'package:flutter_client/src/model/config/api/api_config.dart';
import 'package:flutter_client/src/service/api/impl/isolate/messages/api_isolate_message.dart';

class ApiIsolateApiConfigMessage extends ApiIsolateMessage {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiConfig apiConfig;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiIsolateApiConfigMessage({
    required this.apiConfig
  });

}