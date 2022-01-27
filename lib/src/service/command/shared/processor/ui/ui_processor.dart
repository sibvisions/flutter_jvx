import 'package:flutter_client/src/model/command/ui/data_book_updated_command.dart';
import 'package:flutter_client/src/model/command/ui/update_selected_data_command.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/data_book_updated_processor.dart';
import 'package:flutter_client/src/service/command/shared/processor/ui/update_selected_data_processor.dart';

import '../../../../../model/command/ui/update_layout_position_command.dart';
import 'update_layout_position_processor.dart';

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/route_command.dart';
import '../../../../../model/command/ui/ui_command.dart';
import '../../../../../model/command/ui/update_components_command.dart';
import '../../i_command_processor.dart';
import 'route_command_processor.dart';
import 'update_components_processor.dart';

///
/// Process all sub-types of [UiCommand], delegates commands to specific sub [ICommandProcessor]
///
class UiProcessor implements ICommandProcessor<UiCommand> {
  final ICommandProcessor _routeCommandProcessor = RouteCommandProcessor();
  final ICommandProcessor _updateComponentsProcessor = UpdateComponentsProcessor();
  final ICommandProcessor _updateLayoutPositionProcessor = UpdateLayoutPositionProcessor();
  final ICommandProcessor _updateSelectedDataProcessor = UpdateSelectedDataProcessor();
  final ICommandProcessor _dataBookUpdatedProcessor = DataBookUpdatedProcessor();

  @override
  Future<List<BaseCommand>> processCommand(UiCommand command) async {
    //Switch-Case doesn't work for types
    if (command is RouteCommand) {
      return _routeCommandProcessor.processCommand(command);
    } else if (command is UpdateComponentsCommand) {
      return _updateComponentsProcessor.processCommand(command);
    } else if (command is UpdateLayoutPositionCommand) {
      return _updateLayoutPositionProcessor.processCommand(command);
    } else if (command is UpdateSelectedDataCommand) {
      return _updateSelectedDataProcessor.processCommand(command);
    } else if (command is DataBookUpdatedCommand) {
      return _dataBookUpdatedProcessor.processCommand(command);
    }

    return [];
  }
}
