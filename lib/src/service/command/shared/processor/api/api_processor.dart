import 'package:flutter_client/src/model/command/api/change_password_command.dart';
import 'package:flutter_client/src/model/command/api/fetch_command.dart';
import 'package:flutter_client/src/model/command/api/filter_command.dart';
import 'package:flutter_client/src/model/command/api/logout_command.dart';
import 'package:flutter_client/src/model/command/api/navigation_command.dart';
import 'package:flutter_client/src/model/command/api/reset_password_command.dart';
import 'package:flutter_client/src/model/command/api/set_api_config_command.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/change_password_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/fetch_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/filter_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/logout_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/navigation_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/reset_password_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/api/set_api_config_command_processor.dart';

import '../../../../../model/command/api/api_command.dart';
import '../../../../../model/command/api/button_pressed_command.dart';
import '../../../../../model/command/api/close_tab_command.dart';
import '../../../../../model/command/api/device_status_command.dart';
import '../../../../../model/command/api/download_images_command.dart';
import '../../../../../model/command/api/login_command.dart';
import '../../../../../model/command/api/open_screen_command.dart';
import '../../../../../model/command/api/open_tab_command.dart';
import '../../../../../model/command/api/press_button_command.dart';
import '../../../../../model/command/api/set_value_command.dart';
import '../../../../../model/command/api/set_values_command.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';
import 'close_tab_processor.dart';
import 'device_status_processor.dart';
import 'download_images_processor.dart';
import 'login_command_processor.dart';
import 'open_screen_commmand_processor.dart';
import 'open_tab_processor.dart';
import 'press_button_processor.dart';
import 'set_value_command_processor.dart';
import 'set_values_command_processor.dart';
import 'start_up_command_processor.dart';

///
/// Processes all [ApiCommand], delegates all commands to their respective [ICommandProcessor].
///
// Author: Michael Schober
class ApiProcessor implements ICommandProcessor<ApiCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Processes [StartupCommand]
  final ICommandProcessor _startUpProcessorCommand = StartUpCommandProcessor();

  /// Processes [LoginCommand]
  final ICommandProcessor _loginCommandProcessor = LoginCommandProcessor();

  /// Processes [OpenScreenCommand]
  final ICommandProcessor _openScreenCommandProcessor = OpenScreenCommandProcessor();

  /// Processes [DeviceStatusCommand]
  final ICommandProcessor _deviceStatusProcessor = DeviceStatusProcessor();

  /// Processes [PressButtonCommand]
  final ICommandProcessor _pressButtonProcessor = PressButtonProcessor();

  /// Processes [SetValueCommand]
  final ICommandProcessor _setValueProcessor = SetValueProcessor();

  /// Processes [SetValuesCommand]
  final ICommandProcessor _setValuesProcessor = SetValuesProcessor();

  /// Processes [DownloadImagesCommand]
  final ICommandProcessor _downloadImagesProcessor = DownloadImagesProcessor();

  /// Processes [CloseTabCommand]
  final ICommandProcessor _tabCloseProcessor = CloseTabProcessor();

  /// Processes [OpenTabCommand]
  final ICommandProcessor _tabOpenProcessor = OpenTabProcessor();

  /// Processes [ChangePasswordCommand]
  final ICommandProcessor _changePasswordProcessor = ChangePasswordCommandProcessor();

  /// Processes [ResetPasswordCommand]
  final ICommandProcessor _resetPasswordProcessor = ResetPasswordCommandProcessor();

  /// Processes [NavigationCommand]
  final ICommandProcessor _navigationProcessor = NavigationCommandProcessor();

  /// Processes [SetApiConfigCommand]
  final ICommandProcessor _setApiConfigProcessor = SetApiConfigCommandProcessor();

  /// Processes [FilterCommand]
  final ICommandProcessor _filterProcessor = FilterCommandProcessor();

  /// Processes [FilterCommand]
  final ICommandProcessor _fetchProcessor = FetchCommandProcessor();

  /// Processes [FilterCommand]
  final ICommandProcessor _logoutProcessor = LogoutCommandProcessor();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(ApiCommand command) async {
    // Switch-Case doesn't work with types
    if (command is StartupCommand) {
      return _startUpProcessorCommand.processCommand(command);
    } else if (command is LoginCommand) {
      return _loginCommandProcessor.processCommand(command);
    } else if (command is OpenScreenCommand) {
      return _openScreenCommandProcessor.processCommand(command);
    } else if (command is DeviceStatusCommand) {
      return _deviceStatusProcessor.processCommand(command);
    } else if (command is ButtonPressedCommand) {
      return _pressButtonProcessor.processCommand(command);
    } else if (command is SetValueCommand) {
      return _setValueProcessor.processCommand(command);
    } else if (command is SetValuesCommand) {
      return _setValuesProcessor.processCommand(command);
    } else if (command is DownloadImagesCommand) {
      return _downloadImagesProcessor.processCommand(command);
    } else if (command is CloseTabCommand) {
      return _tabCloseProcessor.processCommand(command);
    } else if (command is OpenTabCommand) {
      return _tabOpenProcessor.processCommand(command);
    } else if (command is ChangePasswordCommand) {
      return _changePasswordProcessor.processCommand(command);
    } else if (command is ResetPasswordCommand) {
      return _resetPasswordProcessor.processCommand(command);
    } else if (command is NavigationCommand) {
      return _navigationProcessor.processCommand(command);
    } else if (command is SetApiConfigCommand) {
      return _setApiConfigProcessor.processCommand(command);
    } else if (command is FilterCommand) {
      return _filterProcessor.processCommand(command);
    } else if (command is FetchCommand) {
      return _fetchProcessor.processCommand(command);
    } else if (command is LogoutCommand) {
      return _logoutProcessor.processCommand(command);
    }

    return [];
  }
}
