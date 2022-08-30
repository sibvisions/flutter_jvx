import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../../mixin/layout_service_mixin.dart';
import '../../../../../model/command/api/device_status_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_device_status_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

/// Calls [IApiService] deviceStatus and [IConfigService] for current clientId
class DeviceStatusCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin, LayoutServiceGetterMixin
    implements ICommandProcessor<DeviceStatusCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double? lastSentWidth;
  double? lastSentHeight;

  @override
  Future<List<BaseCommand>> processCommand(DeviceStatusCommand command) async {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      if (lastSentWidth != command.screenWidth || lastSentHeight != command.screenHeight) {
        lastSentWidth = command.screenWidth;
        lastSentHeight = command.screenHeight;

        ApiDeviceStatusRequest deviceStatusRequest = ApiDeviceStatusRequest(
          clientId: clientId,
          screenWidth: command.screenWidth,
          screenHeight: command.screenHeight,
        );
        return getApiService().sendRequest(request: deviceStatusRequest);
      } else {
        return [];
      }
    } else {
      throw Exception("No Client Id found, while trying to send deviceStatus request");
    }
  }
}
