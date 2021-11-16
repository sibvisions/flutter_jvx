import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_jvx/src/models/api/action/meta_action.dart';
import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/models/api/i_response_names.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/application_parameter_processor.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/menu_processor.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/metadata_processor.dart';
import 'package:flutter_jvx/src/models/api/processor/v1/screen_generic_processort.dart';
import 'package:flutter_jvx/src/models/api/responses/api_response.dart';
import 'package:flutter_jvx/src/models/api/responses/names/jvx_response_names.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:http/http.dart';

import '../i_controller.dart';

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
  Future<List<ProcessorAction>> determineResponse(Future<Response> response) {
    return response
        .then((response) => jsonDecode(response.body) as List<dynamic>)
        .then(_sentToProcessor)
        .then((actions) => actions);
  }

  List<ProcessorAction> _sentToProcessor(List<dynamic> responses) {
    List<ProcessorAction> processorActions = [];

    for(dynamic response in responses) {
      ApiResponse res = ApiResponse.fromJson(response);
      List<ProcessorAction> actions = [];
      if (res.name == responseNames.screenGeneric) {
        actions = screenGenericProcessor.processResponse(response);
      } else if (res.name == responseNames.applicationParameter) {
        actions = applicationParameterProcessor.processResponse(response);
      } else if (res.name == responseNames.menu) {
        actions =  menuProcessor.processResponse(response);
      } else if (res.name == responseNames.screenGeneric) {
        actions = screenGenericProcessor.processResponse(response);
      } else if (res.name == responseNames.applicationMetaData) {
        actions = metaDataProcessor.processResponse(response);
      }
      processorActions.addAll(actions);
    }
    return processorActions;
  }


}