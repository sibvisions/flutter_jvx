import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/api/requests/filter.dart';
import 'package:flutter_client/src/model/command/api/delete_record_command.dart';
import 'package:flutter_client/src/model/command/api/insert_record_command.dart';
import 'package:flutter_client/src/model/command/api/open_screen_command.dart';
import 'package:flutter_client/src/model/command/api/set_values_command.dart';
import 'package:flutter_client/src/model/command/api/startup_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_menu_command.dart';
import 'package:flutter_client/src/model/data/data_book.dart';
import 'package:flutter_client/src/service/api/shared/repository/offline/offline_database.dart';
import 'package:flutter_client/src/service/api/shared/repository/offline_api_repository.dart';
import 'package:flutter_client/src/service/api/shared/repository/online_api_repository.dart';

import '../../../main.dart';
import '../../../util/loading_handler/default_loading_progress_handler.dart';
import '../../../util/loading_handler/progress_dialog.dart';
import '../../model/api/requests/i_api_request.dart';
import '../../model/command/api/close_screen_command.dart';
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

  Future<IRepository?> getRepository();

  Future<void> setRepository(IRepository pRepository);

  Future<void> setController(IController pController);

  void setApiConfig({required ApiConfig apiConfig});

  static initOnline(BuildContext context) async {
    IConfigService configService = services<IConfigService>();
    IUiService uiService = services<IUiService>();
    IApiService apiService = services<IApiService>();
    IDataService dataService = services<IDataService>();
    IStorageService storageService = services<IStorageService>();
    ICommandService commandService = services<ICommandService>();

    ProgressDialog? pd;
    OnlineApiRepository? onlineApiRepository;
    OfflineApiRepository? offlineApiRepository;
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
        progressValueColor: themeData.primaryColor,
        progressBgColor: themeData.backgroundColor,
      );

      offlineApiRepository = (await apiService.getRepository()) as OfflineApiRepository;
      //Set online api repository to handle commands
      onlineApiRepository = OnlineApiRepository(apiConfig: configService.getApiConfig()!);
      await onlineApiRepository.start();
      await apiService.setRepository(onlineApiRepository);

      configService.pauseStyleCallbacks();
      configService.pauseLanguageCallbacks();

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

      bool successfulSync = true;
      for (DataBook dataBook in dataService.getDataBooks().values) {
        log("DataBook: " + dataBook.dataProvider + " | " + dataBook.records.length.toString());

        Map<String, List<Map<String, Object?>>> groupedRows =
            await offlineApiRepository.getChangedRows(dataBook.dataProvider);

        List<Map<String, Object?>> successfulSyncedPrimaryKeys = [];
        try {
          List<Map<String, Object?>>? insertedRows = groupedRows[OfflineDatabase.ROW_STATE_INSERTED];
          log("Syncing inserted rows: " + insertedRows.toString());
          if (insertedRows != null) {
            for (var row in insertedRows) {
              Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
              await commandService.sendCommand(InsertRecordCommand(
                reason: "Re-sync: Insert",
                dataProvider: dataBook.dataProvider,
              ));

              // Remove all $OLD$ columns
              var newColumns = {
                for (var entry in row.entries.where((rowColumn) =>
                    !(rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX) ||
                        rowColumn.key == OfflineDatabase.STATE_COLUMN)))
                  entry.key: entry.value
              };
              await commandService.sendCommand(SetValuesCommand(
                reason: "Re-sync: Insert",
                componentId: "",
                dataProvider: dataBook.dataProvider,
                columnNames: newColumns.keys.toList(growable: false),
                values: newColumns.values.toList(growable: false),
                //TODO evaluate filter
              ));
              successfulSyncedPrimaryKeys.add(primaryColumns);
            }
          }
        } catch (e, stackTrace) {
          log("Error while syncing inserted rows: ", error: e, stackTrace: stackTrace);
          successfulSync = false;
        }

        try {
          List<Map<String, Object?>>? updatedRows = groupedRows[OfflineDatabase.ROW_STATE_UPDATED];
          log("Syncing changed rows: " + updatedRows.toString());
          if (updatedRows != null) {
            for (var row in updatedRows) {
              var newColumns = {
                for (var entry in row.entries.where((rowColumn) =>
                    !(rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX) ||
                        rowColumn.key == OfflineDatabase.STATE_COLUMN)))
                  entry.key: entry.value
              };
              var oldColumns = {
                for (var entry
                    in row.entries.where((rowColumn) => rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX)))
                  entry.key: entry.value
              };
              Map<String, Object?> primaryColumns = _getPrimaryColumns(oldColumns, dataBook);

              await commandService.sendCommand(SetValuesCommand(
                reason: "Re-sync: Update",
                componentId: "",
                dataProvider: dataBook.dataProvider,
                columnNames: newColumns.keys.toList(growable: false),
                values: newColumns.values.toList(growable: false),
                filter: Filter(
                  columnNames: primaryColumns.keys.toList(growable: false),
                  values: primaryColumns.values.toList(growable: false),
                ),
              ));
              successfulSyncedPrimaryKeys.add(primaryColumns);
            }
          }
        } catch (e, stackTrace) {
          log("Error while syncing changed rows: ", error: e, stackTrace: stackTrace);
          successfulSync = false;
        }

        try {
          List<Map<String, Object?>>? deletedRows = groupedRows[OfflineDatabase.ROW_STATE_DELETED];
          log("Syncing deleted rows: " + deletedRows.toString());
          if (deletedRows != null) {
            for (var row in deletedRows) {
              Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
              await commandService.sendCommand(DeleteRecordCommand(
                reason: "Re-sync: Delete",
                dataProvider: dataBook.dataProvider,
                selectedRow: -1,
                filter: Filter(
                  columnNames: primaryColumns.keys.toList(growable: false),
                  values: primaryColumns.values.toList(growable: false),
                ),
              ));
              successfulSyncedPrimaryKeys.add(primaryColumns);
            }
          }
        } catch (e, stackTrace) {
          log("Error while syncing deleted rows: ", error: e, stackTrace: stackTrace);
          successfulSync = false;
        }

        await offlineApiRepository.resetStates(dataBook.dataProvider, pResetRows: successfulSyncedPrimaryKeys);
      }

      if (successfulSync) {
        log("Sync successful");
        await offlineApiRepository.deleteDatabase();

        await configService.setOffline(false);
        DefaultLoadingProgressHandler.setEnabled(true);
        await offlineApiRepository.stop();

        pd.close();

        await commandService.sendCommand(
          CloseScreenCommand(screenName: offlineWorkscreen, reason: "We have synced"),
        );

        configService.resumeStyleCallbacks();
        configService.resumeLanguageCallbacks();

        await commandService.sendCommand(
          StartupCommand(
            reason: "Going online",
            appName: offlineAppName,
            username: offlineUsername,
            password: offlinePassword,
          ),
        );

        uiService.routeToMenu();
      } else {
        log("Sync failed");
        await onlineApiRepository.stop();
        await apiService.setRepository(offlineApiRepository);
        pd.close();
      }
    } catch (e) {
      //Revert all changes in case we have an in-tact offline state
      if (offlineApiRepository != null && !offlineApiRepository.isStopped()) {
        await onlineApiRepository?.stop();
        await apiService.setRepository(offlineApiRepository);
        await configService.setOffline(true);
        DefaultLoadingProgressHandler.setEnabled(false);
      }
      rethrow;
    } finally {
      //In case it hasn't been closed
      pd?.close();
    }
  }

  static Map<String, Object?> _getPrimaryColumns(Map<String, Object?> row, DataBook dataBook) {
    var primaryColumns = {
      for (var entry in row.entries.where(
          (rowColumn) => dataBook.metaData!.primaryKeyColumns.any((primaryColumn) => primaryColumn == rowColumn.key)))
        entry.key: entry.value
    };
    return primaryColumns;
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
    OfflineApiRepository? offlineApiRepository;
    try {
      DefaultLoadingProgressHandler.setEnabled(false);

      pd = ProgressDialog(context: context);
      pd.show(
        msg: "Fetching offline data...",
        max: 100,
        progressType: ProgressType.normal,
        barrierDismissible: false,
        progressValueColor: themeData.primaryColor,
        progressBgColor: themeData.backgroundColor,
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
        progressValueColor: themeData.primaryColor,
        progressBgColor: themeData.backgroundColor,
      );

      offlineApiRepository = OfflineApiRepository();
      await offlineApiRepository.start();
      await offlineApiRepository.initDatabase((value, max, {progress}) {
        pd?.update(
          value: progress ?? 0,
          msg: "Loading data ($value / $max)...",
        );
      });

      onlineApiRepository = (await apiService.getRepository()) as OnlineApiRepository;
      await apiService.setRepository(offlineApiRepository);
      await configService.setOffline(true);
      await configService.setOfflineScreen(uiService.getComponentByName(pComponentName: pWorkscreen)!.screenName!);
      await onlineApiRepository.stop();

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
