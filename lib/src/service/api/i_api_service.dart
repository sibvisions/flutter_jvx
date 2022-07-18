import 'package:flutter_client/src/service/api/shared/repository/offline_api_repository.dart';

import '../../model/api/requests/i_api_request.dart';
import '../../model/command/api/fetch_command.dart';
import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/interface/i_data_model.dart';
import '../../model/config/api/api_config.dart';
import '../command/i_command_service.dart';
import '../config/i_config_service.dart';
import '../data/i_data_service.dart';
import '../service.dart';
import '../storage/i_storage_service.dart';
import '../ui/i_ui_service.dart';
import 'shared/i_controller.dart';
import 'shared/i_repository.dart';

abstract class IApiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Any API Request will be sent to an [IRepository] to execute the request
  /// after which it will be processed to [BaseCommand]s in an [IController]
  Future<List<BaseCommand>> sendRequest({required IApiRequest request});

  void setApiConfig({required ApiConfig apiConfig});

  void setRepository(IRepository pRepository);

  static initOnline() async {
    //TODO re-sync
  }

  static initOffline(String pWorkscreen) async {
    IConfigService configService = services<IConfigService>();
    IUiService uiService = services<IUiService>();
    IApiService apiService = services<IApiService>();
    IDataService dataService = services<IDataService>();
    IStorageService storageService = services<IStorageService>();
    ICommandService commandService = services<ICommandService>();

    FlComponentModel workscreenModel = uiService.getComponentByName(pComponentName: pWorkscreen)!;
    List<FlComponentModel> activeComponents = [workscreenModel, ...uiService.getAllComponentsBelow(workscreenModel.id)];

    Set<String> activeDataProviders = {};

    for (FlComponentModel model in activeComponents) {
      if (model is IDataModel) {
        String dataProvider = (model as IDataModel).dataProvider;

        if (dataProvider.isNotEmpty) {
          activeDataProviders.add(dataProvider);
        }
      }
    }

    for (String dataProvider in activeDataProviders) {
      await commandService.sendCommand(
        FetchCommand(
          reason: "Going offline",
          dataProvider: dataProvider,
          fromRow: 0,
          rowCount: -1,
          includeMetaData: true,
        ),
      );
    }

    var apiRep = OfflineApiRepository();
    await apiRep.startDatabase();

    apiService.setRepository(apiRep);
  }
}
