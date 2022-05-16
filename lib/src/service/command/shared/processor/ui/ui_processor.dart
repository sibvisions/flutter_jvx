import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/model/command/ui/open_session_expired_dialog_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_login_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_menu_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_work_command.dart';
import 'package:flutter_client/src/model/command/ui/save_menu_command.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/open_error_dialog_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/open_session_expired_dialog_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/route_to_login_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/route_to_menu_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/route_to_work_command_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/save_menu_command_processor.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/ui_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../../../../model/command/ui/update_layout_position_command.dart';
import '../../i_command_processor.dart';
import 'update_components_processor.dart';
import 'update_layout_position_processor.dart';

/// Process all sub-types of [UiCommand], delegates commands to specific sub [ICommandProcessor]
class UiProcessor implements ICommandProcessor<UiCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final ICommandProcessor _updateComponentsProcessor = UpdateComponentsProcessor();
  final ICommandProcessor _updateLayoutPositionProcessor = UpdateLayoutPositionProcessor();
  final ICommandProcessor _routeToMenuProcessor = RouteToMenuCommandProcessor();
  final ICommandProcessor _routeToWorkProcessor = RouteToWorkCommandProcessor();
  final ICommandProcessor _saveMenuProcessor = SaveMenuCommandProcessor();
  final ICommandProcessor _routeToLoginProcessor = RouteToLoginCommandProcessor();
  final ICommandProcessor _openErrorDialogProcessor = OpenErrorDialogCommandProcessor();
  final ICommandProcessor _openSessionExpiredDialogProcessor = OpenSessionExpiredDialogCommandProcessor();

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
    } else if (command is OpenErrorDialogCommand) {
      return _openErrorDialogProcessor.processCommand(command);
    } else if (command is OpenSessionExpiredDialogCommand) {
      return _openSessionExpiredDialogProcessor.processCommand(command);
    }

    return [];
  }
}
