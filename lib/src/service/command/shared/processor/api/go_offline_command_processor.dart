import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/command_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../mixin/storage_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/api/go_offline_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class GoOfflineCommandProcessor
    with
        ConfigServiceGetterMixin,
        UiServiceGetterMixin,
        ApiServiceMixin,
        DataServiceMixin,
        StorageServiceMixin,
        CommandServiceMixin
    implements ICommandProcessor<GoOfflineCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(GoOfflineCommand command) async {
    // FlComponentModel workscreenModel = uiService.getComponentByName(pComponentName: command.workscreen)!;
    // List<FlComponentModel> activeComponents = [workscreenModel, ...uiService.getChildrenModels(workscreenModel.id)];

    // List<String> activeDataProvider = [];
    // for (FlComponentModel model in activeComponents) {
    //   if (model is IDataModel) {
    //     activeDataProvider.add((model as IDataModel).dataProvider);
    //   }
    // }

    // log(activeDataProvider.toString());

    return [];
  }
}
