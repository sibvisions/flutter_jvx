import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/delete_frame_command.dart';
import '../../../../../model/command/ui/download_action_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../../../../model/command/ui/route_to_login_command.dart';
import '../../../../../model/command/ui/route_to_menu_command.dart';
import '../../../../../model/command/ui/route_to_work_command.dart';
import '../../../../../model/command/ui/save_menu_command.dart';
import '../../../../../model/command/ui/ui_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../../../../model/command/ui/update_layout_position_command.dart';
import '../../../../../model/command/ui/upload_action_command.dart';
import '../../../../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../../../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../../../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../i_command_processor.dart';
import 'delete_frame_command_processor.dart';
import 'download_action_command_processor.dart';
import 'open_error_dialog_command_processor.dart';
import 'route_to_login_command_processor.dart';
import 'route_to_menu_command_processor.dart';
import 'route_to_work_command_processor.dart';
import 'save_menu_command_processor.dart';
import 'update_components_command_processor.dart';
import 'update_layout_position_command_processor.dart';
import 'upload_action_command_processor.dart';
import 'view/message/open_message_dialog_command_processor.dart';
import 'view/message/open_server_error_dialog_command_processor.dart';
import 'view/message/open_session_expired_dialog_command_processor.dart';

/// Process all sub-types of [UiCommand], delegates commands to specific sub [ICommandProcessor]
class UiProcessor implements ICommandProcessor<UiCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final ICommandProcessor _updateComponentsProcessor = UpdateComponentsCommandProcessor();
  final ICommandProcessor _updateLayoutPositionProcessor = UpdateLayoutPositionCommandProcessor();
  final ICommandProcessor _routeToMenuProcessor = RouteToMenuCommandProcessor();
  final ICommandProcessor _routeToWorkProcessor = RouteToWorkCommandProcessor();
  final ICommandProcessor _saveMenuProcessor = SaveMenuCommandProcessor();
  final ICommandProcessor _routeToLoginProcessor = RouteToLoginCommandProcessor();
  final ICommandProcessor _openServerErrorDialogProcessor = OpenServerErrorDialogCommandProcessor();
  final ICommandProcessor _openErrorDialogProcessor = OpenErrorDialogCommandProcessor();
  final ICommandProcessor _openSessionExpiredDialogProcessor = OpenSessionExpiredDialogCommandProcessor();
  final ICommandProcessor _openMessageDialogProcessor = OpenMessageDialogCommandProcessor();
  final ICommandProcessor _uploadActionProcessor = UploadActionCommandProcessor();
  final ICommandProcessor _downloadActionProcessor = DownloadActionCommandProcessor();
  final ICommandProcessor _deleteFrameProcessor = DeleteFrameCommandProcessor();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(UiCommand command) async {
    //Switch-Case doesn't work for types
    if (command is UpdateComponentsCommand) {
      return _updateComponentsProcessor.processCommand(command);
    } else if (command is UpdateLayoutPositionCommand) {
      return _updateLayoutPositionProcessor.processCommand(command);
    } else if (command is RouteToMenuCommand) {
      return _routeToMenuProcessor.processCommand(command);
    } else if (command is SaveMenuCommand) {
      return _saveMenuProcessor.processCommand(command);
    } else if (command is RouteToWorkCommand) {
      return _routeToWorkProcessor.processCommand(command);
    } else if (command is RouteToLoginCommand) {
      return _routeToLoginProcessor.processCommand(command);
    } else if (command is OpenServerErrorDialogCommand) {
      return _openServerErrorDialogProcessor.processCommand(command);
    } else if (command is OpenErrorDialogCommand) {
      return _openErrorDialogProcessor.processCommand(command);
    } else if (command is OpenSessionExpiredDialogCommand) {
      return _openSessionExpiredDialogProcessor.processCommand(command);
    } else if (command is OpenMessageDialogCommand) {
      return _openMessageDialogProcessor.processCommand(command);
    } else if (command is UploadActionCommand) {
      return _uploadActionProcessor.processCommand(command);
    } else if (command is DownloadActionCommand) {
      return _downloadActionProcessor.processCommand(command);
    } else if (command is DeleteFrameCommand) {
      return _deleteFrameProcessor.processCommand(command);
    }

    return [];
  }
}
