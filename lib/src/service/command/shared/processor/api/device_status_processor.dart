import 'dart:ui';

import 'package:flutter_client/src/mixin/layout_service_mixin.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/device_status_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';
import '../../../../config/i_config_service.dart';

/// Calls [IApiService] deviceStatus and [IConfigService] for current clientId
// Author: Michael Schober
class DeviceStatusProcessor with ApiServiceMixin, ConfigServiceMixin, LayoutServiceMixin implements ICommandProcessor<DeviceStatusCommand> {

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