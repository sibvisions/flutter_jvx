import '../../../../../model/command/api/close_frame_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_close_frame_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class CloseFrameCommandProcessor implements ICommandProcessor<CloseFrameCommand> {
  @override
  Future<List<BaseCommand>> processCommand(CloseFrameCommand command) async {
    return IApiService().sendRequest(
      ApiCloseFrameRequest(
        frameName: command.frameName,
      ),
    );
  }
}
