import 'dart:convert';

import 'package:http/http.dart';

import '../../../../model/api/api_response_names.dart';
import '../../../../model/api/response/api_response.dart';
import '../../../../model/command/base_command.dart';
import '../i_controller.dart';
import '../i_processor.dart';
import '../processor/application_meta_data_processor.dart';
import '../processor/application_parameters_processor.dart';
import '../processor/close_screen_processor.dart';
import '../processor/menu_processor.dart';
import '../processor/screen_generic_processor.dart';

class ApiController implements IController {
  final IProcessor _applicationParameterProcessor = ApplicationParametersProcessor();
  final IProcessor _applicationMetaDataProcessor = ApplicationMetaDataProcessor();
  final IProcessor _menuProcessor = MenuProcessor();
  final IProcessor _screenGenericProcessor = ScreenGenericProcessor();
  final IProcessor _closeScreenProcessor = CloseScreenProcessor();

  @override
  Future<List<BaseCommand>> processResponse(Future<Response> response) {
    var commands = response
        .then((fullResponse) => fullResponse.body)
        .then((body) => jsonDecode(body) as List<dynamic>)
        .then((value) => value.map((e) => _sentToProcessor(e)).toList())
        .then((value) {
      if (value.isNotEmpty) {
        return value.reduce((element1, element2) {
          element1.addAll(element2);
          return element1;
        });
      } else {
        return <BaseCommand>[];
      }
    }); //Reduce List<List<BaseCommands>> to only a single Type of List<BaseCommands>
    return commands;
  }

  /// Send single [ApiResponse] to their respective [IProcessor], returns resulting [BaseCommands] as [List].
  List<BaseCommand> _sentToProcessor(dynamic json) {
    var responseObj = ApiResponse.fromJson(json);

    switch (responseObj.name) {
      case (ApiResponseNames.applicationParameters):
        return _applicationParameterProcessor.processResponse(json);
      case (ApiResponseNames.applicationMetaData):
        return _applicationMetaDataProcessor.processResponse(json);
      case (ApiResponseNames.menu):
        return _menuProcessor.processResponse(json);
      case (ApiResponseNames.screenGeneric):
        return _screenGenericProcessor.processResponse(json);
      case (ApiResponseNames.closeScreen):
        return _closeScreenProcessor.processResponse(json);
      default:
        return [];
    }
  }
}
