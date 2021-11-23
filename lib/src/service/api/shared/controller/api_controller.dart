import 'dart:convert';

import 'package:flutter_client/src/model/api/api_response_names.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/shared/i_controller.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/application_meta_data_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/application_parameters_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/menu_processor.dart';
import 'package:flutter_client/src/service/api/shared/processor/screen_generic_processor.dart';
import 'package:http/http.dart';


class ApiController implements IController {


  final IProcessor _applicationParameterProcessor = ApplicationParametersProcessor();
  final IProcessor _applicationMetaDataProcessor = ApplicationMetaDataProcessor();
  final IProcessor _menuProcessor = MenuProcessor();
  final IProcessor _screenGenericProcessor = ScreenGenericProcessor();



  @override
  Future<List<BaseCommand>> processResponse(Future<Response> response) {
    var commands = response
        .then((fullResponse) => fullResponse.body)
        .then((body) => jsonDecode(body) as List<dynamic>)
        .then((value) => value.map((e) => _sentToProcessor(e)).toList())
        .then((value) => value.reduce((value, element) { value.addAll(element); return value;})); //Reduce List<List<BaseCommands>> to only a single Type of List<BaseCommands>
    return commands;
  }

  /// Send single [ApiResponse] to their respective [IProcessor], returns resulting [BaseCommands] as [List].
  List<BaseCommand> _sentToProcessor(dynamic json) {
    var responseObj = ApiResponse.fromJson(json);

    switch(responseObj.name) {
      case(ApiResponseNames.applicationParameters) :
          return _applicationParameterProcessor.processResponse(json);
      case(ApiResponseNames.applicationMetaData) :
          return _applicationMetaDataProcessor.processResponse(json);
      case(ApiResponseNames.menu) :
          return _menuProcessor.processResponse(json);
      case(ApiResponseNames.screenGeneric) :
          return _screenGenericProcessor.processResponse(json);
      default :
        return [];
    }
  }
}
