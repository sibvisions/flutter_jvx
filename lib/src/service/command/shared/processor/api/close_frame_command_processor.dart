import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/close_frame_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_close_frame_request.dart';
import '../../i_command_processor.dart';

class CloseFrameCommandProcessor with ApiServiceMixin implements ICommandProcessor<CloseFrameCommand> {
  @override
  Future<List<BaseCommand>> processCommand(CloseFrameCommand command) async {
    return getApiService().sendRequest(
      request: ApiCloseFrameRequest(
        frameName: command.frameName,
      ),
    );
  }
}
