import '../../../../../../services.dart';
import '../../../../../model/command/api/device_status_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_device_status_request.dart';
import '../../i_command_processor.dart';

/// Calls [IApiService] deviceStatus and [IConfigService] for current clientId
class DeviceStatusCommandProcessor implements ICommandProcessor<DeviceStatusCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double? lastSentWidth;
  double? lastSentHeight;

  @override
  Future<List<BaseCommand>> processCommand(DeviceStatusCommand command) async {
    if (lastSentWidth != command.screenWidth || lastSentHeight != command.screenHeight) {
      lastSentWidth = command.screenWidth;
      lastSentHeight = command.screenHeight;

      ApiDeviceStatusRequest deviceStatusRequest = ApiDeviceStatusRequest(
        screenWidth: command.screenWidth,
        screenHeight: command.screenHeight,
      );
      return IApiService().sendRequest(deviceStatusRequest);
    } else {
      return [];
    }
  }
}
