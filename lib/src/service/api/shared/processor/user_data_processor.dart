import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_user_data_command.dart';
import '../../../../model/response/user_data_response.dart';
import '../i_response_processor.dart';

class UserDataProcessor implements IResponseProcessor<UserDataResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse({required UserDataResponse pResponse}) {
    SaveUserDataCommand command = SaveUserDataCommand(userData: pResponse, reason: "Server sent user data");
    return [command];
  }
}
