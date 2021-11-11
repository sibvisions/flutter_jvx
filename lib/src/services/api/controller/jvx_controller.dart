import 'dart:convert';

import 'package:flutter_jvx/src/models/api/i_response_names.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/application_parameter_processor.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/menu_processor.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/metadata_processor.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/screen_generic_processort.dart';
import 'package:flutter_jvx/src/models/api/responses/api_response.dart';
import 'package:flutter_jvx/src/models/api/responses/names/jvx_response_names.dart';
import 'package:flutter_jvx/src/services/api/i_controller.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:http/http.dart';

//ACTIONS [ROUTE, DATAPROVIDER, COMPONENT, META, REQEUESTS]
//Route - Route to Screen
//Dataprovider - DataChanges -> includes modification, delete, selected Row
//Component - Changes to Components Models
//Meta - authentication, clientId
//Requests - follow up http requests(mostly data)


//Response comes in -> Controller determines response ->
//compute() Isolate Processor -> Processor Returns actionSet ->
//Do actions with PRIORTY

class JVxController implements IController  {

  IProcessor metaDataProcessor = MetaDataProcessor();
  IProcessor applicationParameterProcessor = ApplicationParameterProcessor();
  IProcessor menuProcessor = MenuProcessor();
  IProcessor screenGenericProcessor = ScreenGenericProcessor();

  IResponseNames responseNames = JVxResponseNames();

  @override
  void determineResponse(Future<Response> response) {
    response
        .then((value) => jsonDecode(value.body) as List<dynamic>)
        .then((value) => value.forEach(_sentToProcessor));
  }

  void _sentToProcessor(dynamic json) {
    ApiResponse res = ApiResponse.fromJson(json);

    if (res.name == responseNames.screenGeneric) {
      screenGenericProcessor.processResponse(json);
    } else if (res.name == responseNames.applicationParameter) {
      applicationParameterProcessor.processResponse(json);
    } else if (res.name == responseNames.menu) {
      menuProcessor.processResponse(json);
    } else if (res.name == responseNames.screenGeneric) {
      screenGenericProcessor.processResponse(json);
    } else if (res.name == responseNames.applicationMetaData) {
      metaDataProcessor.processResponse(json);
    }
  }


}