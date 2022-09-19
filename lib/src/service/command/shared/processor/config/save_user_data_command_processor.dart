import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_user_data_command.dart';
import '../../../../../model/config/user/user_info.dart';
import '../../i_command_processor.dart';

class SaveUserDataCommandProcessor implements ICommandProcessor<SaveUserDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveUserDataCommand command) async {
    UserInfo userInfo = UserInfo(
      userName: command.userData.userName,
      displayName: command.userData.displayName,
      eMail: command.userData.eMail,
      profileImage: command.userData.profileImage,
    );
    await IConfigService().setUserInfo(
      pUserInfo: userInfo,
      pJson: command.userData.json,
    );
    return [];
  }
}
