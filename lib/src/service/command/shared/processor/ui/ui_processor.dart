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

import '../../../../../model/command/ui/delete_frame_command.dart';
import '../../../../../model/command/ui/download_action_command.dart';
import '../../../../../model/command/ui/function_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../../../../model/command/ui/route/route_to_command.dart';
import '../../../../../model/command/ui/route/route_to_login_command.dart';
import '../../../../../model/command/ui/route/route_to_menu_command.dart';
import '../../../../../model/command/ui/route/route_to_work_command.dart';
import '../../../../../model/command/ui/save_menu_command.dart';
import '../../../../../model/command/ui/set_focus_command.dart';
import '../../../../../model/command/ui/ui_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../../../../model/command/ui/update_layout_position_command.dart';
import '../../../../../model/command/ui/upload_action_command.dart';
import '../../../../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../../../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../../../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../i_command_processor.dart';
import '../../i_command_processor_handler.dart';
import 'delete_frame_command_processor.dart';
import 'download_action_command_processor.dart';
import 'function_command_processor.dart';
import 'open_error_dialog_command_processor.dart';
import 'route/route_to_command_processor.dart';
import 'route/route_to_login_command_processor.dart';
import 'route/route_to_menu_command_processor.dart';
import 'route/route_to_work_command_processor.dart';
import 'save_menu_command_processor.dart';
import 'set_focus_command_processor.dart';
import 'update_components_command_processor.dart';
import 'update_layout_position_command_processor.dart';
import 'upload_action_command_processor.dart';
import 'view/message/open_message_dialog_command_processor.dart';
import 'view/message/open_server_error_dialog_command_processor.dart';
import 'view/message/open_session_expired_dialog_command_processor.dart';

/// Handles the processors of [UiCommand].
class UiProcessor implements ICommandProcessorHandler<UiCommand> {
  final UpdateComponentsCommandProcessor _updateComponentsProcessor = UpdateComponentsCommandProcessor();
  final UpdateLayoutPositionCommandProcessor _updateLayoutPositionProcessor = UpdateLayoutPositionCommandProcessor();
  final RouteToMenuCommandProcessor _routeToMenuProcessor = RouteToMenuCommandProcessor();
  final RouteToWorkCommandProcessor _routeToWorkProcessor = RouteToWorkCommandProcessor();
  final SaveMenuCommandProcessor _saveMenuProcessor = SaveMenuCommandProcessor();
  final RouteToLoginCommandProcessor _routeToLoginProcessor = RouteToLoginCommandProcessor();
  final RouteToCommandProcessor _routeToProcessor = RouteToCommandProcessor();
  final OpenServerErrorDialogCommandProcessor _openServerErrorDialogProcessor = OpenServerErrorDialogCommandProcessor();
  final OpenErrorDialogCommandProcessor _openErrorDialogProcessor = OpenErrorDialogCommandProcessor();
  final OpenSessionExpiredDialogCommandProcessor _openSessionExpiredDialogProcessor =
      OpenSessionExpiredDialogCommandProcessor();
  final OpenMessageDialogCommandProcessor _openMessageDialogProcessor = OpenMessageDialogCommandProcessor();
  final UploadActionCommandProcessor _uploadActionProcessor = UploadActionCommandProcessor();
  final DownloadActionCommandProcessor _downloadActionProcessor = DownloadActionCommandProcessor();
  final DeleteFrameCommandProcessor _deleteFrameProcessor = DeleteFrameCommandProcessor();
  final FunctionCommandProcessor _functionProcessor = FunctionCommandProcessor();
  final SetFocusCommandProcessor _setFocusProcessor = SetFocusCommandProcessor();

  @override
  ICommandProcessor<UiCommand>? getProcessor(UiCommand command) {
    if (command is UpdateComponentsCommand) {
      return _updateComponentsProcessor;
    } else if (command is UpdateLayoutPositionCommand) {
      return _updateLayoutPositionProcessor;
    } else if (command is RouteToMenuCommand) {
      return _routeToMenuProcessor;
    } else if (command is SaveMenuCommand) {
      return _saveMenuProcessor;
    } else if (command is RouteToWorkCommand) {
      return _routeToWorkProcessor;
    } else if (command is RouteToLoginCommand) {
      return _routeToLoginProcessor;
    } else if (command is RouteToCommand) {
      return _routeToProcessor;
    } else if (command is OpenServerErrorDialogCommand) {
      return _openServerErrorDialogProcessor;
    } else if (command is OpenErrorDialogCommand) {
      return _openErrorDialogProcessor;
    } else if (command is OpenSessionExpiredDialogCommand) {
      return _openSessionExpiredDialogProcessor;
    } else if (command is OpenMessageDialogCommand) {
      return _openMessageDialogProcessor;
    } else if (command is UploadActionCommand) {
      return _uploadActionProcessor;
    } else if (command is DownloadActionCommand) {
      return _downloadActionProcessor;
    } else if (command is DeleteFrameCommand) {
      return _deleteFrameProcessor;
    } else if (command is FunctionCommand) {
      return _functionProcessor;
    } else if (command is SetFocusCommand) {
      return _setFocusProcessor;
    }

    return null;
  }
}
