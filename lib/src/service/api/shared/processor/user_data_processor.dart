import '../../../../model/response/user_data_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_user_data_command.dart';
import '../../../../model/config/user/user_info.dart';
import '../i_response_processor.dart';

class UserDataProcessor implements IResponseProcessor<UserDataResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse({required UserDataResponse pResponse}) {
    UserInfo userInfo = UserInfo(
      userName: pResponse.userName,
      displayName: pResponse.displayName,
      eMail: pResponse.eMail,
      profileImage: pResponse.profileImage,
    );

    SaveUserDataCommand command = SaveUserDataCommand(userInfo: userInfo, reason: "Server sent user data");

    return [command];
  }
}
