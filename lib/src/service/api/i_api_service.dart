import '../../model/command/base_command.dart';

abstract class IApiService {


  Future<List<BaseCommand>> startUp(String appName);
  Future<List<BaseCommand>> login(String username, String password, String clientId);
  Future<List<BaseCommand>> openScreen(String componentId, String clientId);
  Future<List<BaseCommand>> deviceStatus(String clientId, double screenWidth, double screenHeight);

}