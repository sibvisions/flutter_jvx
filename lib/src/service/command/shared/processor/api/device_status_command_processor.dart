import 'package:flutter_client/src/mixin/layout_service_mixin.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_device_status_request.dart';
import '../../../../../model/command/api/device_status_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

/// Calls [IApiService] deviceStatus and [IConfigService] for current clientId
// Author: Michael Schober
class DeviceStatusCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin, LayoutServiceGetterMixin
    implements ICommandProcessor<DeviceStatusCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(DeviceStatusCommand command) async {
    String? clientId = getConfigService().getClientId();
    if (clientId != null) {
      ApiDeviceStatusRequest deviceStatusRequest = ApiDeviceStatusRequest(
        clientId: clientId,
        screenWidth: command.screenWidth,
        screenHeight: command.screenHeight,
      );
      return getApiService().sendRequest(request: deviceStatusRequest);
    } else {
      throw Exception("No Client Id found, while trying to send deviceStatus request");
    }
  }
}
