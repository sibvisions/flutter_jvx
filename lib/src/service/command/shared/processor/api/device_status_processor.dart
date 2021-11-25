import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/device_status_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/i_api_service.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';
import 'package:flutter_client/src/service/config/i_config_service.dart';

/// Calls [IApiService] deviceStatus and [IConfigService] for current clientId
// Author: Michael Schober
class DeviceStatusProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<DeviceStatusCommand> {

  @override
  Future<List<BaseCommand>> processCommand(DeviceStatusCommand command) async {
    String? clientId = configService.getClientId();
    if(clientId != null){
      return apiService.deviceStatus(clientId, command.screenWidth, command.screenHeight);
    } else {
      throw Exception("No Client Id found, while trying to send deviceStatus request");
    }
  }
}