import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/change_selected_row_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class ChangeSelectedRowCommandProcessor with UiServiceGetterMixin, DataServiceMixin implements ICommandProcessor<ChangeSelectedRowCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ChangeSelectedRowCommand command) async {
    return [];
  }
}
