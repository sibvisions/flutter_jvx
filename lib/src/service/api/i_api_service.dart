import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/ui/route_to_menu_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_work_command.dart';
import 'package:flutter_client/src/service/api/shared/repository/offline_api_repository.dart';
import 'package:flutter_client/src/service/api/shared/repository/online_api_repository.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import '../../../util/loading_handler/default_loading_progress_handler.dart';
import '../../model/api/requests/i_api_request.dart';
import '../../model/command/api/fetch_command.dart';
import '../../model/command/base_command.dart';
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

  Future<IRepository> getRepository();

  Future<void> setRepository(IRepository pRepository);

  void setApiConfig({required ApiConfig apiConfig});

  static initOnline(BuildContext context) async {
    IConfigService configService = services<IConfigService>();
    IUiService uiService = services<IUiService>();
    IApiService apiService = services<IApiService>();
    IDataService dataService = services<IDataService>();
    IStorageService storageService = services<IStorageService>();
    ICommandService commandService = services<ICommandService>();

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      msg: "Re-syncing offline data...",
      max: 100,
      progressType: ProgressType.normal,
      barrierDismissible: false,
    );

    var repository = (await apiService.getRepository()) as OfflineApiRepository;
    await apiService.setRepository(OnlineApiRepository(apiConfig: configService.getApiConfig()!));
    //TODO re-sync

    await repository.stopDatabase(context);
    pd.close();

    await configService.setOffline(false);
    DefaultLoadingProgressHandler.setEnabled(true);

    String lastWorkscreen = configService.getOfflineScreen()!;
    await commandService.sendCommand(RouteToWorkCommand(screenName: lastWorkscreen, reason: "We are back online"));
  }

  static initOffline(BuildContext context, String pWorkscreen) async {
    DefaultLoadingProgressHandler.setEnabled(false);

    IConfigService configService = services<IConfigService>();
    IUiService uiService = services<IUiService>();
    IApiService apiService = services<IApiService>();
    IDataService dataService = services<IDataService>();
    IStorageService storageService = services<IStorageService>();
    ICommandService commandService = services<ICommandService>();

    //String databookPrefix = configService.getAppName() + "/" + pWorkscreen;
    Set<String> activeDataProviders = dataService.getDataBooks().keys.toList().where((element) {
      var prefixes = element.split("/");
      if (prefixes.length >= 2) {
        return prefixes[1] == pWorkscreen;
      }
      return false;
    }).toSet();

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      msg: "Fetching offline data...",
      max: activeDataProviders.length,
      progressType: ProgressType.valuable,
      barrierDismissible: false,
    );

    int fetchCounter = 1;
    for (String dataProvider in activeDataProviders) {
      pd.update(msg: "Fetching offline data...", value: fetchCounter);
      log("Start fetching $dataProvider");
      await commandService.sendCommand(
        FetchCommand(
          reason: "Going offline",
          dataProvider: dataProvider,
          fromRow: 0,
          rowCount: -1,
          includeMetaData: true,
        ),
      );
      fetchCounter++;
    }

    pd.close();

    log("finished fetching data");

    var apiRep = OfflineApiRepository();
    await apiRep.startDatabase(context);

    await apiService.setRepository(apiRep);
    await configService.setOffline(true);
    await configService.setOfflineScreen(pWorkscreen);

    await commandService.sendCommand(RouteToMenuCommand(reason: "We are going offline"));
  }
}
