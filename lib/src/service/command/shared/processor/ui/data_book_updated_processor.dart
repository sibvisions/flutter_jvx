import '../../../../../mixin/ui_service_getter_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/data_book_updated_command.dart';
import '../../i_command_processor.dart';

class DataBookUpdatedProcessor with UiServiceGetterMixin implements ICommandProcessor<DataBookUpdatedCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DataBookUpdatedCommand command) async {
    getUiService().notifyDataChange(pDataProvider: command.dataProvider);

    return [];
  }
}
