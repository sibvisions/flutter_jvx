import 'package:flutter_client/src/model/api/response/user_data_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/config/save_user_data_command.dart';
import 'package:flutter_client/src/model/config/user/user_info.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class UserDataProcessor implements IProcessor<UserDataResponse> {
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
