import '../../model/command/base_command.dart';

abstract class IApiService {
  Future<List<BaseCommand>> startUp(String appName);
  Future<List<BaseCommand>> login(String username, String password, String clientId);
  Future<List<BaseCommand>> openScreen(String componentId, String clientId);
  Future<List<BaseCommand>> deviceStatus(String clientId, double screenWidth, double screenHeight);
  Future<List<BaseCommand>> pressButton(String clientId, String componentId);
  Future<List<BaseCommand>> setValue(String clientId, String componentId, dynamic value);
  Future<List<BaseCommand>> downloadImages(
      {required String clientId, required String baseDir, required String appName, required String appVersion});
  Future<List<BaseCommand>> setValues({
    required String clientId,
    required String componentId,
    required List<String> columnNames,
    required List<dynamic> values,
    required String dataProvider,
  });
  Future<List<BaseCommand>> closeTab({
    required String clientId,
    required String componentName,
    required int index,
  });
  Future<List<BaseCommand>> openTab({
    required String clientId,
    required String componentName,
    required int index,
  });
}
