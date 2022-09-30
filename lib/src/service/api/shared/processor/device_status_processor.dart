import '../../../../model/command/base_command.dart';
import '../../../../model/command/layout/layout_mode_command.dart';
import '../../../../model/response/device_status_response.dart';
import '../i_response_processor.dart';

class DeviceStatusProcessor implements IResponseProcessor<DeviceStatusResponse> {
  @override
  List<BaseCommand> processResponse({required DeviceStatusResponse pResponse}) {
    return [
      LayoutModeCommand(
        layoutMode: pResponse.layoutMode,
        reason: "Server sent Device Status",
      )
    ];
  }
}
