import '../../../../model/command/base_command.dart';
import '../../i_api_service.dart';
import '../../shared/i_controller.dart';
import '../../shared/i_repository.dart';

///
/// Will execute all actions on the main Isolate
///
class DefaultApi implements IApiService {
  IRepository repository;
  IController controller;

  DefaultApi({required this.repository, required this.controller});

  @override
  Future<List<BaseCommand>> login(String username, String password, String clientId) {
    var response = repository.login(username, password, clientId);
    var actions = controller.processResponse(response);
    return actions;
  }

  @override
  Future<List<BaseCommand>> startUp(String appName) async {
    var response = repository.startUp(appName);
    var actions = controller.processResponse(response);
    return actions;
  }

  @override
  Future<List<BaseCommand>> openScreen(String componentId, String clientId) {
    var response = repository.openScreen(componentId, clientId);
    var actions = controller.processResponse(response);
    return actions;
  }

  @override
  Future<List<BaseCommand>> deviceStatus(String clientId, double screenWidth, double screenHeight) {
    var response = repository.deviceStatus(clientId, screenWidth, screenHeight);
    var actions = controller.processResponse(response);
    return actions;
  }

  @override
  Future<List<BaseCommand>> pressButton(String clientId, String componentId) {
    var response = repository.pressButton(componentId, clientId);
    var actions = controller.processResponse(response);
    return actions;
  }

  @override
  Future<List<BaseCommand>> setValue(String clientId, String componentId, value) {
    var response = repository.setValue(clientId, componentId, value);
    var actions = controller.processResponse(response);
    return actions;
  }

  @override
  Future<List<BaseCommand>> setValues(
      {required String clientId,
      required String componentId,
      required List<String> columnNames,
      required List values,
      required String dataProvider}) {
    var response = repository.setValues(
        clientId: clientId,
        componentId: componentId,
        columnNames: columnNames,
        values: values,
        dataProvider: dataProvider);
    var actions = controller.processResponse(response);
    return actions;
  }

  @override
  Future<List<BaseCommand>> downloadImages(
      {required String clientId, required String baseDir, required String appName, required String appVersion}) {
    var response = repository.downloadImages(clientId: clientId);
    var actions =
        controller.processImageDownload(baseDir: baseDir, response: response, appVersion: appVersion, appName: appName);
    return actions;
  }

  @override
  Future<List<BaseCommand>> closeTab({required String clientId, required String componentName, required int index}) {
    var response = repository.closeTab(clientId: clientId, componentName: componentName, index: index);
    var actions = controller.processResponse(response);
    return actions;
  }

  @override
  Future<List<BaseCommand>> openTab({required String clientId, required String componentName, required int index}) {
    var response = repository.openTab(clientId: clientId, componentName: componentName, index: index);
    var actions = controller.processResponse(response);
    return actions;
  }
}
