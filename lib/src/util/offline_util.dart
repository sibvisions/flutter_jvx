import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

import '../model/command/api/close_screen_command.dart';
import '../model/command/api/delete_record_command.dart';
import '../model/command/api/fetch_command.dart';
import '../model/command/api/insert_record_command.dart';
import '../model/command/api/open_screen_command.dart';
import '../model/command/api/set_values_command.dart';
import '../model/command/api/startup_command.dart';
import '../model/command/ui/route_to_menu_command.dart';
import '../model/component/fl_component_model.dart';
import '../model/config/api/api_config.dart';
import '../model/data/data_book.dart';
import '../model/request/filter.dart';
import '../service/api/i_api_service.dart';
import '../service/api/shared/repository/offline/offline_database.dart';
import '../service/api/shared/repository/offline_api_repository.dart';
import '../service/api/shared/repository/online_api_repository.dart';
import '../service/command/i_command_service.dart';
import '../service/config/i_config_service.dart';
import '../service/data/i_data_service.dart';
import '../service/service.dart';
import '../service/ui/i_ui_service.dart';
import 'loading_handler/loading_progress_handler.dart';
import 'loading_handler/progress_dialog_widget.dart';

abstract class OfflineUtil {
  static initOnline(BuildContext context) async {
    IConfigService configService = services<IConfigService>();
    IUiService uiService = services<IUiService>();
    IApiService apiService = services<IApiService>();
    IDataService dataService = services<IDataService>();
    ICommandService commandService = services<ICommandService>();

    FlComponentModel? workscreenModel;

    var dialogKey = GlobalKey<ProgressDialogState>();
    OnlineApiRepository? onlineApiRepository;
    OfflineApiRepository? offlineApiRepository;
    try {
      await Wakelock.enable();
      String offlineWorkscreenLongName = configService.getOfflineScreen()!;
      String offlineAppName = configService.getAppName()!;
      String offlineUsername = configService.getUsername()!;
      String offlinePassword = configService.getPassword()!;

      unawaited(
        uiService.openDismissibleDialog(
          pIsDismissible: false,
          pContext: context,
          pBuilder: (context) => ProgressDialogWidget(
            key: dialogKey,
            config: Config(
              message: configService.translateText("Re-syncing offline data") + "...",
              progressType: ProgressType.normal,
              barrierDismissible: false,
              progressValueColor: Theme.of(context).primaryColor,
              progressBgColor: Theme.of(context).backgroundColor,
            ),
          ),
        ),
      );

      offlineApiRepository = (await apiService.getRepository()) as OfflineApiRepository;
      //Set online api repository to handle commands
      onlineApiRepository = OnlineApiRepository(apiConfig: ApiConfig(serverConfig: configService.getServerConfig()));
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
          forceNewSession: true,
        ),
      );

      await commandService.sendCommand(
        OpenScreenCommand(componentId: offlineWorkscreenLongName, reason: "We are back online"),
      );

      workscreenModel = uiService.getComponentByScreenName(pScreenLongName: offlineWorkscreenLongName)!;

      dialogKey.currentState?.update(
          config: Config(
        progressType: ProgressType.valuable,
        message: configService.translateText("Fetching online data") + "...",
      ));

      await fetchDataProvider(
        dataService,
        workscreenModel.name,
        commandService,
        progressUpdate: (value, max) {
          dialogKey.currentState?.update(
              config: Config(
            progress: value,
            maxProgress: max,
          ));
        },
      );

      bool successfulSync = true;
      List<Map<String, Object?>> successfulSyncedPrimaryKeys = [];

      var dataBooks = dataService.getDataBooks();
      int dataBookCounter = 1;
      int changedRowsSum = 0;
      for (DataBook dataBook in dataBooks.values) {
        log("DataBook: " + dataBook.dataProvider + " | " + dataBook.records.length.toString());

        Map<String, List<Map<String, Object?>>> groupedRows =
            await offlineApiRepository.getChangedRows(dataBook.dataProvider);
        int changedRowCount = 0;
        if (groupedRows.isNotEmpty) {
          changedRowCount = groupedRows.values.map((e) => e.length).reduce((value, element) => value + element);
          changedRowsSum += changedRowCount;
        }

        dialogKey.currentState?.update(
            config: Config(
          message: configService.translateText("Syncing data") + "... ($dataBookCounter / ${dataBooks.length})",
          progress: changedRowCount - successfulSyncedPrimaryKeys.length,
          maxProgress: changedRowCount,
        ));

        successfulSync = await _handleInsertedRows(groupedRows[OfflineDatabase.ROW_STATE_INSERTED], dataBook,
                commandService, successfulSyncedPrimaryKeys) &&
            successfulSync;

        successfulSync = await _handleUpdatedRows(groupedRows[OfflineDatabase.ROW_STATE_UPDATED], dataBook,
                commandService, successfulSyncedPrimaryKeys) &&
            successfulSync;

        successfulSync = await _handleDeletedRows(groupedRows[OfflineDatabase.ROW_STATE_DELETED], dataBook,
                commandService, successfulSyncedPrimaryKeys) &&
            successfulSync;

        dataBookCounter++;
        await offlineApiRepository.resetStates(dataBook.dataProvider, pResetRows: successfulSyncedPrimaryKeys);
      }

      log("Synced ${successfulSyncedPrimaryKeys.length} rows");
      ProgressDialogWidget.close(context);

      String syncResult = successfulSync ? "successful" : "failed";
      int failedRowCount = successfulSyncedPrimaryKeys.length - changedRowsSum;
      if (successfulSyncedPrimaryKeys.isNotEmpty || failedRowCount > 0) {
        await uiService.openDismissibleDialog(
          pIsDismissible: false,
          pContext: context,
          pBuilder: (context) => AlertDialog(
            title: Text("Sync $syncResult"),
            content: Text("Successfully synced ${successfulSyncedPrimaryKeys.length} rows" +
                (failedRowCount > 0 ? "\n$failedRowCount rows failed to sync" : "")),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(configService.translateText("Ok")),
              ),
            ],
          ),
        );
      }

      if (successfulSync) {
        log("Sync successful");
        await offlineApiRepository.deleteDatabase();

        await configService.setOffline(false);
        LoadingProgressHandler.setEnabled(true);
        await offlineApiRepository.stop();

        await commandService.sendCommand(
          CloseScreenCommand(screenName: workscreenModel.name, reason: "We have synced"),
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
      } else {
        log("Sync failed");
        await onlineApiRepository.stop();
        await apiService.setRepository(offlineApiRepository);
      }
    } catch (e, stackTrace) {
      log("Error while syncing offline data", error: e, stackTrace: stackTrace);

      //Revert all changes in case we have an in-tact offline state
      if (offlineApiRepository != null && !offlineApiRepository.isStopped()) {
        await onlineApiRepository?.stop();
        await apiService.setRepository(offlineApiRepository);
        await configService.setOffline(true);
        LoadingProgressHandler.setEnabled(false);
      }

      ProgressDialogWidget.safeClose(dialogKey);
      unawaited(uiService.openDismissibleDialog(
        pIsDismissible: false,
        pContext: context,
        pBuilder: (context) => AlertDialog(
          title: Text(configService.translateText("Offline Sync Error")),
          content: Text(configService.translateText("There was an error while trying to sync your data."
              "\n${e.toString()}")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(configService.translateText("Ok")),
            ),
          ],
        ),
      ));

      rethrow;
    } finally {
      await Wakelock.disable();
      //In case it hasn't been closed yet
      ProgressDialogWidget.safeClose(dialogKey);
    }
  }

  static Future<bool> _handleInsertedRows(List<Map<String, Object?>>? insertedRows, DataBook dataBook,
      ICommandService commandService, List<Map<String, Object?>> successfulSyncedPrimaryKeys) async {
    bool successful = true;
    if (insertedRows != null) {
      log("Syncing inserted rows: " + insertedRows.toString());
      for (var row in insertedRows) {
        try {
          Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
          await _insertOfflineRecord(commandService, dataBook, row);
          successfulSyncedPrimaryKeys.add(primaryColumns);
        } catch (e, stackTrace) {
          log("Error while syncing inserted row:", error: e, stackTrace: stackTrace);
          successful = false;
        }
      }
    }
    return successful;
  }

  static Future<bool> _handleUpdatedRows(List<Map<String, Object?>>? updatedRows, DataBook dataBook,
      ICommandService commandService, List<Map<String, Object?>> successfulSyncedPrimaryKeys) async {
    bool successful = true;
    if (updatedRows != null) {
      log("Syncing updated rows: " + updatedRows.toString());
      for (var row in updatedRows) {
        try {
          var oldColumns = {
            for (var entry in row.entries.where((rowColumn) => rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX)))
              entry.key: entry.value
          };
          Map<String, Object?> primaryColumns = _getPrimaryColumns(oldColumns, dataBook);

          await _updateOfflineRecord(row, commandService, dataBook, primaryColumns);
          successfulSyncedPrimaryKeys.add(primaryColumns);
        } catch (e, stackTrace) {
          log("Error while syncing updated row:", error: e, stackTrace: stackTrace);
          successful = false;
        }
      }
    }
    return successful;
  }

  static Future<bool> _handleDeletedRows(List<Map<String, Object?>>? deletedRows, DataBook dataBook,
      ICommandService commandService, List<Map<String, Object?>> successfulSyncedPrimaryKeys) async {
    bool successful = true;
    if (deletedRows != null) {
      log("Syncing deleted rows: " + deletedRows.toString());
      for (var row in deletedRows) {
        try {
          Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
          await _deleteOfflineRecord(commandService, dataBook, primaryColumns);
          successfulSyncedPrimaryKeys.add(primaryColumns);
        } catch (e, stackTrace) {
          log("Error while syncing deleted row:", error: e, stackTrace: stackTrace);
          successful = false;
        }
      }
    }
    return successful;
  }

  static Future<void> _insertOfflineRecord(
      ICommandService commandService, DataBook dataBook, Map<String, Object?> row) async {
    await commandService.sendCommand(InsertRecordCommand(
      reason: "Re-sync: Insert",
      dataProvider: dataBook.dataProvider,
    ));

    // Remove all $OLD$ columns
    var newColumns = {
      for (var entry in row.entries.where((rowColumn) =>
          !(rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX) || rowColumn.key == OfflineDatabase.STATE_COLUMN)))
        entry.key: entry.value
    };

    return commandService.sendCommand(SetValuesCommand(
      reason: "Re-sync: Insert",
      componentId: "",
      dataProvider: dataBook.dataProvider,
      columnNames: newColumns.keys.toList(growable: false),
      values: newColumns.values.toList(growable: false),
      //TODO evaluate filter
    ));
  }

  static Future<void> _updateOfflineRecord(Map<String, Object?> row, ICommandService commandService, DataBook dataBook,
      Map<String, Object?> primaryColumns) {
    var newColumns = {
      for (var entry in row.entries.where((rowColumn) =>
          !(rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX) || rowColumn.key == OfflineDatabase.STATE_COLUMN)))
        entry.key: entry.value
    };
    return commandService.sendCommand(SetValuesCommand(
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
  }

  static Future<void> _deleteOfflineRecord(
      ICommandService commandService, DataBook dataBook, Map<String, Object?> primaryColumns) {
    return commandService.sendCommand(DeleteRecordCommand(
      reason: "Re-sync: Delete",
      dataProvider: dataBook.dataProvider,
      selectedRow: -1,
      filter: Filter(
        columnNames: primaryColumns.keys.toList(growable: false),
        values: primaryColumns.values.toList(growable: false),
      ),
    ));
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

      progressUpdate?.call(fetchCounter++, activeDataProviders.length);

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
    ICommandService commandService = services<ICommandService>();

    var dialogKey = GlobalKey<ProgressDialogState>();
    OnlineApiRepository? onlineApiRepository;
    OfflineApiRepository? offlineApiRepository;
    try {
      await Wakelock.enable();
      LoadingProgressHandler.setEnabled(false);
      //Set already here to receive errors from api responses
      await configService.setOffline(true);

      unawaited(uiService.openDismissibleDialog(
        pContext: context,
        pIsDismissible: false,
        pBuilder: (context) {
          return ProgressDialogWidget(
            key: dialogKey,
            config: Config(
              message: configService.translateText("Fetching offline data") + "...",
              progressType: ProgressType.normal,
              barrierDismissible: false,
              progressValueColor: Theme.of(context).primaryColor,
              progressBgColor: Theme.of(context).backgroundColor,
            ),
          );
        },
      ));

      await fetchDataProvider(
        dataService,
        pWorkscreen,
        commandService,
        progressUpdate: (value, max) {
          dialogKey.currentState?.update(
              config: Config(
            progressType: ProgressType.valuable,
            progress: value,
            maxProgress: max,
          ));
        },
      );

      dialogKey.currentState?.update(
          config: Config(
        message: configService.translateText("Loading data") + "...",
        progressType: ProgressType.valuable,
        progress: 0,
        maxProgress: 100,
      ));

      offlineApiRepository = OfflineApiRepository();
      await offlineApiRepository.start();
      await offlineApiRepository.initDatabase((value, max, {progress}) {
        dialogKey.currentState?.update(
            config: Config(
          message: configService.translateText("Loading data") + " ($value / $max)...",
          progress: progress ?? 0,
        ));
      });

      onlineApiRepository = (await apiService.getRepository()) as OnlineApiRepository;
      await apiService.setRepository(offlineApiRepository);
      await configService.setOfflineScreen(uiService.getComponentByName(pComponentName: pWorkscreen)!.screenLongName!);
      await onlineApiRepository.stop();
      //Clear menu
      uiService.setMenuModel(null);

      ProgressDialogWidget.close(context);
      await commandService.sendCommand(RouteToMenuCommand(replaceRoute: true, reason: "We are going offline"));
    } catch (e, stackTrace) {
      log("Error while downloading offline data", error: e, stackTrace: stackTrace);

      //Revert all changes in case we have an in-tact online state
      if (onlineApiRepository != null) {
        await apiService.setRepository(onlineApiRepository);
        await configService.setOffline(false);
        LoadingProgressHandler.setEnabled(true);
      }

      ProgressDialogWidget.safeClose(dialogKey);
      unawaited(uiService.openDismissibleDialog(
        pIsDismissible: false,
        pContext: context,
        pBuilder: (context) => AlertDialog(
          title: Text(configService.translateText("Offline Init Error")),
          content: Text(configService.translateText("There was an error while trying to download data."
              "\n${e.toString()}")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(configService.translateText("Ok")),
            ),
          ],
        ),
      ));

      rethrow;
    } finally {
      await Wakelock.disable();
      //In case it hasn't been closed yet
      ProgressDialogWidget.safeClose(dialogKey);
    }
  }
}
