import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_user_data_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/user_data_response.dart';
import '../i_response_processor.dart';

class UserDataProcessor implements IResponseProcessor<UserDataResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(UserDataResponse pResponse, ApiRequest? pRequest) {
    SaveUserDataCommand command = SaveUserDataCommand(userData: pResponse, reason: "Server sent user data");
    return [command];
  }
}
