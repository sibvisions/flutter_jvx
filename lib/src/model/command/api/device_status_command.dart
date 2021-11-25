import 'package:flutter_client/src/model/command/api/api_command.dart';

class DeviceStatusCommand extends ApiCommand {

  final double screenWidth;
  final double screenHeight;

  DeviceStatusCommand({
    required this.screenWidth,
    required this.screenHeight,
    required String reason,
  }) : super(reason: reason);
}