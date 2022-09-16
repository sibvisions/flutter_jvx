import '../../../../../../mixin/services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/change_selected_row_command.dart';
import '../../../../../model/command/ui/view/message/open_error_dialog_command.dart';
import '../../i_command_processor.dart';

class ChangeSelectedRowCommandProcessor
    with UiServiceMixin, DataServiceMixin
    implements ICommandProcessor<ChangeSelectedRowCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ChangeSelectedRowCommand command) async {
    // set selected row of databook
    bool success = getDataService().setSelectedRow(
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
