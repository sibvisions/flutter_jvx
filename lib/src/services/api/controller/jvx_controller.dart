import 'dart:convert';

import 'package:flutter_jvx/src/models/api/i_response_names.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/application_parameter_processor.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/menu_processor.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/metadata_processor.dart';
import 'package:flutter_jvx/src/models/api/responses.dart';
import 'package:flutter_jvx/src/models/api/responses/names/jvx_response_names.dart';
import 'package:flutter_jvx/src/models/api/responses/response_menu.dart';
import 'package:flutter_jvx/src/services/api/i_controller.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:http/http.dart';

class JVxController implements IController  {

  IProcessor metaDataProcessor = MetaDataProcessor();
  IProcessor applicationParameterProcessor = ApplicationParameterProcessor();
  IProcessor menuProcessor = MenuProcessor();

  IResponseNames responseNames = JVxResponseNames();

  @override
  void determineResponse(Future<Response> response) {
    response
        .then((value) => jsonDecode(value.body) as List<dynamic>)
        .then((value) => value.forEach(_sentToProcessor));
  }

  void _sentToProcessor(dynamic json) {
    ApiResponse res = ApiResponse.fromJson(json);

    if(res.name == responseNames.applicationMetaData){
      metaDataProcessor.processResponse(json);
    } else if(res.name == responseNames.applicationParameter){
      applicationParameterProcessor.processResponse(json);
    } else if(res.name == responseNames.menu){
      menuProcessor.processResponse(json);
    }
  }


}