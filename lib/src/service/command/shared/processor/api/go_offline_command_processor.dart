import 'dart:developer';

import 'package:flutter_client/src/model/command/api/fetch_command.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/component/interface/i_data_model.dart';
import 'package:flutter_client/src/service/api/shared/repository/offline_api_repository.dart';

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
        ApiServiceGetterMixin,
        DataServiceGetterMixin,
        StorageServiceGetterMixin,
        CommandServiceGetterMixin
    implements ICommandProcessor<GoOfflineCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(GoOfflineCommand command) async {
    FlComponentModel workscreenModel = getUiService().getComponentByName(pComponentName: command.workscreen)!;
    List<FlComponentModel> activeComponents = [
      workscreenModel,
      ...getUiService().getAllComponentsBelow(workscreenModel.id)
    ];

    Set<String> activeDataProviders = {};

    for (FlComponentModel model in activeComponents) {
      if (model is IDataModel) {
        String dataProvider = (model as IDataModel).dataProvider;

        if (dataProvider.isNotEmpty) {
          activeDataProviders.add(dataProvider);
        }
      }
    }

    log(activeDataProviders.toString());

    for (String dataProvider in activeDataProviders) {
      await getCommandService().sendCommand(
        FetchCommand(
          reason: "Going offline",
          dataProvider: dataProvider,
          fromRow: 0,
          rowCount: -1,
          includeMetaData: true,
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 10));

    var apiRep = OfflineApiRepository();
    await apiRep.startDatabase();

    return [];
  }
}
