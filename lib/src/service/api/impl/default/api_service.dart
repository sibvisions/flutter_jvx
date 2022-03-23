import 'dart:developer';

import 'package:flutter_client/src/model/api/requests/api_download_images_request.dart';
import 'package:flutter_client/src/model/api/requests/api_request.dart';

import '../../../../model/command/base_command.dart';
import '../../i_api_service.dart';
import '../../shared/i_controller.dart';
import '../../shared/i_repository.dart';

///
/// Will execute all actions on the main Isolate
///
class ApiService implements IApiService {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes remote requests
  late IRepository repository;
  /// Processes responses into commands
  late IController controller;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Standard constructor
  ApiService({
    required this.repository,
    required this.controller
  });

  /// Initializes a Instance where [repository] and [controller] are null
  /// and need to be set before any request can be sent.
  ApiService.empty();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> sendRequest({required ApiRequest request}) async {
    List<BaseCommand> commands = [];

    try{
      if(request is ApiDownloadImagesRequest){
        var response = await repository.downloadImages(pRequest: request);
        commands = controller.processImageDownload(
            response: response,
            baseDir: request.baseDir,
            appName: request.appName,
            appVersion: request.appVersion
        );
      } else {
        var response = await repository.sendRequest(pRequest: request);
        commands = controller.processResponse(responses: response);
      }

    } catch(e) {
      log(e.toString());
    }
    return commands;
  }
}
