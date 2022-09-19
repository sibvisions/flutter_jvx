import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/delete_frame_command.dart';
import '../../../../model/response/close_frame_response.dart';
import '../i_response_processor.dart';

class CloseFrameProcessor implements IResponseProcessor<CloseFrameResponse> {
  @override
  List<BaseCommand> processResponse({required CloseFrameResponse pResponse}) {
    return [
      DeleteFrameCommand(
        componentId: pResponse.componentId,
        reason: "Server sent CloseFrame",
      ),
    ];
  }
}
