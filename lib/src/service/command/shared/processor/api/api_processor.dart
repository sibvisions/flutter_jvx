/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import '../../../../../model/command/api/activate_screen_command.dart';
import '../../../../../model/command/api/alive_command.dart';
import '../../../../../model/command/api/api_command.dart';
import '../../../../../model/command/api/cancel_login_command.dart';
import '../../../../../model/command/api/change_password_command.dart';
import '../../../../../model/command/api/changes_command.dart';
import '../../../../../model/command/api/close_content_command.dart';
import '../../../../../model/command/api/close_frame_command.dart';
import '../../../../../model/command/api/close_screen_command.dart';
import '../../../../../model/command/api/close_tab_command.dart';
import '../../../../../model/command/api/dal_save_command.dart';
import '../../../../../model/command/api/delete_record_command.dart';
import '../../../../../model/command/api/device_status_command.dart';
import '../../../../../model/command/api/download_images_command.dart';
import '../../../../../model/command/api/download_style_command.dart';
import '../../../../../model/command/api/download_templates_command.dart';
import '../../../../../model/command/api/download_translation_command.dart';
import '../../../../../model/command/api/exit_command.dart';
import '../../../../../model/command/api/feedback_command.dart';
import '../../../../../model/command/api/fetch_command.dart';
import '../../../../../model/command/api/filter_command.dart';
import '../../../../../model/command/api/focus_gained_command.dart';
import '../../../../../model/command/api/focus_lost_command.dart';
import '../../../../../model/command/api/insert_record_command.dart';
import '../../../../../model/command/api/login_command.dart';
import '../../../../../model/command/api/logout_command.dart';
import '../../../../../model/command/api/mouse_command.dart';
import '../../../../../model/command/api/navigation_command.dart';
import '../../../../../model/command/api/open_screen_command.dart';
import '../../../../../model/command/api/open_tab_command.dart';
import '../../../../../model/command/api/press_button_command.dart';
import '../../../../../model/command/api/reload_command.dart';
import '../../../../../model/command/api/reload_menu_command.dart';
import '../../../../../model/command/api/reset_password_command.dart';
import '../../../../../model/command/api/restore_data_command.dart';
import '../../../../../model/command/api/rollback_command.dart';
import '../../../../../model/command/api/save_command.dart';
import '../../../../../model/command/api/select_record_command.dart';
import '../../../../../model/command/api/select_tree_command.dart';
import '../../../../../model/command/api/set_parameter_command.dart';
import '../../../../../model/command/api/set_screen_parameter_command.dart';
import '../../../../../model/command/api/set_value_command.dart';
import '../../../../../model/command/api/set_values_command.dart';
import '../../../../../model/command/api/sort_command.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/api/upload_command.dart';
import '../../i_command_processor.dart';
import '../../i_command_processor_handler.dart';
import 'activate_screen_command_processor.dart';
import 'alive_command_processor.dart';
import 'cancel_login_command_processor.dart';
import 'change_password_command_processor.dart';
import 'changes_command_processor.dart';
import 'close_content_command_processor.dart';
import 'close_frame_command_processor.dart';
import 'close_screen_command_processor.dart';
import 'close_tab_command_processor.dart';
import 'dal_save_command_processor.dart';
import 'delete_record_command_processor.dart';
import 'device_status_command_processor.dart';
import 'download_images_command_processor.dart';
import 'download_style_command_processor.dart';
import 'download_templates_command_processor.dart';
import 'download_translation_command_processor.dart';
import 'exit_command_processor.dart';
import 'feedback_command_processor.dart';
import 'fetch_command_processor.dart';
import 'filter_command_processor.dart';
import 'focus_gained_command_processor.dart';
import 'focus_lost_command_processor.dart';
import 'insert_record_command_processor.dart';
import 'login_command_processor.dart';
import 'logout_command_processor.dart';
import 'mouse_command_processor.dart';
import 'navigation_command_processor.dart';
import 'open_screen_command_processor.dart';
import 'open_tab_command_processor.dart';
import 'press_button_command_processor.dart';
import 'reload_command_processor.dart';
import 'reload_menu_command_processor.dart';
import 'reset_password_command_processor.dart';
import 'restore_data_processor.dart';
import 'rollback_command_processor.dart';
import 'save_command_processor.dart';
import 'select_record_command_processor.dart';
import 'select_tree_command_processor.dart';
import 'set_parameter_command_processor.dart';
import 'set_screen_parameter_command_processor.dart';
import 'set_value_command_processor.dart';
import 'set_values_command_processor.dart';
import 'sort_command_processor.dart';
import 'start_up_command_processor.dart';
import 'upload_command_processor.dart';

/// Handles the processors of [ApiCommand].
class ApiProcessor implements ICommandProcessorHandler<ApiCommand> {
  //resources
  final DownloadImagesCommandProcessor _downloadImagesProcessor = DownloadImagesCommandProcessor();
  final DownloadTemplatesCommandProcessor _downloadTemplatesProcessor = DownloadTemplatesCommandProcessor();
  final DownloadTranslationCommandProcessor _downloadTranslationProcessor = DownloadTranslationCommandProcessor();
  final DownloadStyleCommandProcessor _downloadStyleProcessor = DownloadStyleCommandProcessor();

  //application
  final StartupCommandProcessor _startupProcessorCommand = StartupCommandProcessor();
  final ExitCommandProcessor _exitProcessor = ExitCommandProcessor();
  final AliveCommandProcessor _aliveProcessor = AliveCommandProcessor();
  final DeviceStatusCommandProcessor _deviceStatusProcessor = DeviceStatusCommandProcessor();
  final NavigationCommandProcessor _navigationProcessor = NavigationCommandProcessor();
  final ReloadMenuCommandProcessor _reloadMenuCommandProcessor = ReloadMenuCommandProcessor();
  final UploadCommandProcessor _uploadProcessor = UploadCommandProcessor();
  final FeedbackCommandProcessor _feedbackProcessor = FeedbackCommandProcessor();
  final ChangesCommandProcessor _changesProcessor = ChangesCommandProcessor();

  final LoginCommandProcessor _loginCommandProcessor = LoginCommandProcessor();
  final CancelLoginCommandProcessor _cancelLoginCommandProcessor = CancelLoginCommandProcessor();
  final ChangePasswordCommandProcessor _changePasswordProcessor = ChangePasswordCommandProcessor();
  final ResetPasswordCommandProcessor _resetPasswordProcessor = ResetPasswordCommandProcessor();
  final LogoutCommandProcessor _logoutProcessor = LogoutCommandProcessor();

  final SetParameterCommandProcessor _setParameterProcessor = SetParameterCommandProcessor();
  final OpenScreenCommandProcessor _openScreenCommandProcessor = OpenScreenCommandProcessor();
  final CloseScreenCommandProcessor _closeScreenProcessor = CloseScreenCommandProcessor();
  final ActivateScreenCommandProcessor _activateScreenCommandProcessor = ActivateScreenCommandProcessor();
  final SetScreenParameterCommandProcessor _setScreenParameterProcessor = SetScreenParameterCommandProcessor();
  final PressButtonCommandProcessor _pressButtonProcessor = PressButtonCommandProcessor();
  final SetValueCommandProcessor _setValueProcessor = SetValueCommandProcessor();
  final OpenTabCommandProcessor _tabOpenProcessor = OpenTabCommandProcessor();
  final CloseTabCommandProcessor _tabCloseProcessor = CloseTabCommandProcessor();
  final CloseFrameCommandProcessor _closeFrameProcessor = CloseFrameCommandProcessor();
  final CloseContentCommandProcessor _closeContentProcessor = CloseContentCommandProcessor();

  final SaveCommandProcessor _saveProcessor = SaveCommandProcessor();
  final ReloadCommandProcessor _reloadProcessor = ReloadCommandProcessor();
  final RollbackCommandProcessor _rollbackProcessor = RollbackCommandProcessor();

  //data access
  final SetValuesCommandProcessor _setValuesProcessor = SetValuesCommandProcessor();
  final FilterCommandProcessor _filterProcessor = FilterCommandProcessor();
  final FetchCommandProcessor _fetchProcessor = FetchCommandProcessor();
  final SelectRecordCommandProcessor _selectRecordProcessor = SelectRecordCommandProcessor();
  final DeleteRecordCommandProcessor _deleteRecordCommandProcessor = DeleteRecordCommandProcessor();
  final DalSaveCommandProcessor _dalSaveProcessor = DalSaveCommandProcessor();
  final InsertRecordCommandProcessor _insertRecordProcessor = InsertRecordCommandProcessor();
  final SortCommandProcessor _sortProcessor = SortCommandProcessor();
  final RestoreDataCommandProcessor _restoreDataProcessor = RestoreDataCommandProcessor();
  final SelectTreeCommandProcessor _selectTreeCommand = SelectTreeCommandProcessor();

  final MouseCommandProcessor _mouseProcessor = MouseCommandProcessor();
  final FocusGainedCommandProcessor _focusGainedProcessor = FocusGainedCommandProcessor();
  final FocusLostCommandProcessor _focusLostProcessor = FocusLostCommandProcessor();

  @override
  ICommandProcessor<ApiCommand>? getProcessor(ApiCommand command) {
    if (command is StartupCommand) {
      return _startupProcessorCommand;
    } else if (command is LoginCommand) {
      return _loginCommandProcessor;
    } else if (command is CancelLoginCommand) {
      return _cancelLoginCommandProcessor;
    } else if (command is OpenScreenCommand) {
      return _openScreenCommandProcessor;
    } else if (command is ActivateScreenCommand) {
      return _activateScreenCommandProcessor;
    } else if (command is ReloadMenuCommand) {
      return _reloadMenuCommandProcessor;
    } else if (command is DeviceStatusCommand) {
      return _deviceStatusProcessor;
    } else if (command is PressButtonCommand) {
      return _pressButtonProcessor;
    } else if (command is SetValueCommand) {
      return _setValueProcessor;
    } else if (command is SetValuesCommand) {
      return _setValuesProcessor;
    } else if (command is CloseTabCommand) {
      return _tabCloseProcessor;
    } else if (command is OpenTabCommand) {
      return _tabOpenProcessor;
    } else if (command is ChangePasswordCommand) {
      return _changePasswordProcessor;
    } else if (command is ResetPasswordCommand) {
      return _resetPasswordProcessor;
    } else if (command is NavigationCommand) {
      return _navigationProcessor;
    } else if (command is FilterCommand) {
      return _filterProcessor;
    } else if (command is FetchCommand) {
      return _fetchProcessor;
    } else if (command is LogoutCommand) {
      return _logoutProcessor;
    } else if (command is SelectRecordCommand) {
      return _selectRecordProcessor;
    } else if (command is DeleteRecordCommand) {
      return _deleteRecordCommandProcessor;
    } else if (command is DalSaveCommand) {
      return _dalSaveProcessor;
    } else if (command is CloseScreenCommand) {
      return _closeScreenProcessor;
    } else if (command is InsertRecordCommand) {
      return _insertRecordProcessor;
    } else if (command is DownloadImagesCommand) {
      return _downloadImagesProcessor;
    } else if (command is DownloadTemplatesCommand) {
      return _downloadTemplatesProcessor;
    } else if (command is DownloadTranslationCommand) {
      return _downloadTranslationProcessor;
    } else if (command is DownloadStyleCommand) {
      return _downloadStyleProcessor;
    } else if (command is CloseFrameCommand) {
      return _closeFrameProcessor;
    } else if (command is UploadCommand) {
      return _uploadProcessor;
    } else if (command is ChangesCommand) {
      return _changesProcessor;
    } else if (command is MouseCommand) {
      return _mouseProcessor;
    } else if (command is FocusGainedCommand) {
      return _focusGainedProcessor;
    } else if (command is FocusLostCommand) {
      return _focusLostProcessor;
    } else if (command is AliveCommand) {
      return _aliveProcessor;
    } else if (command is ExitCommand) {
      return _exitProcessor;
    } else if (command is FeedbackCommand) {
      return _feedbackProcessor;
    } else if (command is SaveCommand) {
      return _saveProcessor;
    } else if (command is ReloadCommand) {
      return _reloadProcessor;
    } else if (command is RollbackCommand) {
      return _rollbackProcessor;
    } else if (command is SortCommand) {
      return _sortProcessor;
    } else if (command is SetParameterCommand) {
      return _setParameterProcessor;
    } else if (command is SetScreenParameterCommand) {
      return _setScreenParameterProcessor;
    } else if (command is RestoreDataCommand) {
      return _restoreDataProcessor;
    } else if (command is SelectTreeCommand) {
      return _selectTreeCommand;
    } else if (command is CloseContentCommand) {
      return _closeContentProcessor;
    }

    return null;
  }
}
