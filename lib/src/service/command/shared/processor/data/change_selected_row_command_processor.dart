import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/change_selected_row_command.dart';
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class ChangeSelectedRowCommandProcessor with UiServiceGetterMixin, DataServiceMixin implements ICommandProcessor<ChangeSelectedRowCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ChangeSelectedRowCommand command) async {
    // set selected row of databook
    bool success = await dataService.setSelectedRow(
      pDataProvider: command.dataProvider,
      pNewSelectedRow: command.newSelectedRow,
    );

    // Notify components that their selected row changed, if setting the row failed show error dialog.
    if (success) {
      getUiService().notifyDataChange(
        pDataProvider: command.dataProvider,
        pFrom: -1,
        pTo: -1,
      );
    } else {
      OpenErrorDialogCommand openErrorDialogCommand = OpenErrorDialogCommand(
        reason: "Setting new selected row failed",
        message: "Setting new selected row failed",
      );
      return [openErrorDialogCommand];
    }
    return [];
  }
}
