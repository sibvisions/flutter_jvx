import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/api/open_screen_command.dart';
import 'package:flutter_client/src/model/command/api/startup_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_menu_command.dart';
import 'package:flutter_client/src/model/data/data_book.dart';
import 'package:flutter_client/src/service/api/shared/repository/offline/offline_database.dart';
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

    OfflineApiRepository? offlineRepository;
    ProgressDialog? pd;
    try {
      String offlineWorkscreen = configService.getOfflineScreen()!;
      String offlineAppName = configService.getAppName();
      String offlineUsername = configService.getUsername()!;
      String offlinePassword = configService.getPassword()!;

      pd = ProgressDialog(context: context);
      pd.show(
        msg: "Re-syncing offline data...",
        max: 100,
        progressType: ProgressType.normal,
        barrierDismissible: false,
      );

      offlineRepository = (await apiService.getRepository()) as OfflineApiRepository;
      await apiService.setRepository(OnlineApiRepository(apiConfig: configService.getApiConfig()!));

      await commandService.sendCommand(
        StartupCommand(
          reason: "Going online",
          appName: offlineAppName,
          username: offlineUsername,
          password: offlinePassword,
        ),
      );

      await commandService.sendCommand(
        OpenScreenCommand(componentId: offlineWorkscreen, reason: "We are back online"),
      );

      await fetchDataProvider(
        dataService,
        offlineWorkscreen,
        commandService,
        progressUpdate: (value, max) {
          pd?.update(msg: "Fetching online data... ($value / $max)", value: 0);
        },
      );

      for (DataBook dataBook in dataService.getDataBooks().values) {
        log("DataBook: " + dataBook.dataProvider + " | " + dataBook.records.length.toString());

        Map<String, List<Map<String, Object?>>> groupedRows =
            await offlineRepository.getChangedRows(dataBook.dataProvider);

        log("Inserted rows: " + groupedRows[OfflineDatabase.ROW_STATE_INSERTED].toString());
        log("Changed rows: " + groupedRows[OfflineDatabase.ROW_STATE_UPDATED].toString());
        log("Deleted rows: " + groupedRows[OfflineDatabase.ROW_STATE_DELETED].toString());
        // ApiInsertRecordRequest();
        // ApiSetValuesRequest();
        // ApiDeleteRecordRequest();
      }

      await offlineRepository.stopDatabase();

      await configService.setOffline(false);
      DefaultLoadingProgressHandler.setEnabled(true);

      pd.close();
      //TODO route
    } catch (e) {
      //Revert all changes in case we have an in-tact offline state
      if (offlineRepository != null && !offlineRepository.isStopped()) {
        await apiService.setRepository(offlineRepository);
        await configService.setOffline(true);
        DefaultLoadingProgressHandler.setEnabled(false);
      }
      rethrow;
    } finally {
      //In case it hasn't been closed
      pd?.close();
    }
  }

  static Future<void> fetchDataProvider(
      IDataService dataService, String offlineWorkscreen, ICommandService commandService,
      {void Function(int value, int max)? progressUpdate}) async {
    //String databookPrefix = configService.getAppName() + "/" + pWorkscreen;
    Set<String> activeDataProviders = dataService.getDataBooks().keys.toList().where((element) {
      var prefixes = element.split("/");
      if (prefixes.length >= 2) {
        return prefixes[1] == offlineWorkscreen;
      }
      return false;
    }).toSet();

    int fetchCounter = 1;
    for (String dataProvider in activeDataProviders) {
      log("Start fetching $dataProvider");

      progressUpdate?.call(fetchCounter, activeDataProviders.length);

      await commandService.sendCommand(
        FetchCommand(
          reason: "Fetching data for offline/online switch",
          dataProvider: dataProvider,
          fromRow: 0,
          rowCount: -1,
          includeMetaData: true,
        ),
      );
    }

    log("finished fetching data");
  }

  static initOffline(BuildContext context, String pWorkscreen) async {
    IConfigService configService = services<IConfigService>();
    IUiService uiService = services<IUiService>();
    IApiService apiService = services<IApiService>();
    IDataService dataService = services<IDataService>();
    IStorageService storageService = services<IStorageService>();
    ICommandService commandService = services<ICommandService>();

    ProgressDialog? pd;
    OnlineApiRepository? onlineApiRepository;
    try {
      DefaultLoadingProgressHandler.setEnabled(false);

      pd = ProgressDialog(context: context);
      pd.show(
        msg: "Fetching offline data...",
        max: 100,
        progressType: ProgressType.normal,
        barrierDismissible: false,
      );

      await fetchDataProvider(
        dataService,
        pWorkscreen,
        commandService,
        progressUpdate: (value, max) {
          pd?.update(msg: "Fetching offline data... ($value / $max)", value: 0);
        },
      );

      pd.close();
      pd = ProgressDialog(context: context);
      pd.show(
        msg: "Loading data...",
        max: 100,
        progressType: ProgressType.valuable,
        barrierDismissible: false,
      );

      var apiRep = await OfflineApiRepository.create();
      await apiRep.startDatabase((value, max, {progress}) {
        pd?.update(
          value: progress ?? 0,
          msg: "Loading data ($value / $max)...",
        );
      });

      onlineApiRepository = (await apiService.getRepository()) as OnlineApiRepository;
      await apiService.setRepository(apiRep);
      await configService.setOffline(true);
      await configService.setOfflineScreen(uiService.getComponentByName(pComponentName: pWorkscreen)!.screenName!);

      pd.close();
      await commandService.sendCommand(RouteToMenuCommand(replaceRoute: true, reason: "We are going offline"));
    } catch (e) {
      //Revert all changes in case we have an in-tact online state
      if (onlineApiRepository != null) {
        await apiService.setRepository(onlineApiRepository);
        await configService.setOffline(false);
        DefaultLoadingProgressHandler.setEnabled(true);
      }
      rethrow;
    } finally {
      pd?.close();
    }
  }
}
