import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

import '../src/model/command/api/close_screen_command.dart';
import '../src/model/command/api/delete_record_command.dart';
import '../src/model/command/api/fetch_command.dart';
import '../src/model/command/api/insert_record_command.dart';
import '../src/model/command/api/open_screen_command.dart';
import '../src/model/command/api/set_values_command.dart';
import '../src/model/command/api/startup_command.dart';
import '../src/model/command/ui/route_to_menu_command.dart';
import '../src/model/component/fl_component_model.dart';
import '../src/model/config/api/api_config.dart';
import '../src/model/data/data_book.dart';
import '../src/model/request/filter.dart';
import '../src/service/api/i_api_service.dart';
import '../src/service/api/shared/repository/offline/offline_database.dart';
import '../src/service/api/shared/repository/offline_api_repository.dart';
import '../src/service/api/shared/repository/online_api_repository.dart';
import '../src/service/command/i_command_service.dart';
import '../src/service/config/i_config_service.dart';
import '../src/service/data/i_data_service.dart';
import '../src/service/service.dart';
import '../src/service/ui/i_ui_service.dart';
import '../src/util/loading_handler/default_loading_progress_handler.dart';
import '../src/util/loading_handler/progress_dialog_widget.dart';

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
      String offlineAppName = configService.getAppName();
      String offlineUsername = configService.getUsername()!;
      String offlinePassword = configService.getPassword()!;

      unawaited(showDialog(
        context: context,
        builder: (context) {
          return ProgressDialogWidget(
            key: dialogKey,
            config: Config(
              message: "Re-syncing offline data...",
              progressType: ProgressType.normal,
              barrierDismissible: false,
              progressValueColor: Theme.of(context).primaryColor,
              progressBgColor: Theme.of(context).backgroundColor,
            ),
          );
        },
      ));

      offlineApiRepository = (await apiService.getRepository()) as OfflineApiRepository;
      //Set online api repository to handle commands
      onlineApiRepository = OnlineApiRepository(apiConfig: ApiConfig(serverConfig: configService.getServerConfig()!));
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
        OpenScreenCommand(componentId: offlineWorkscreenLongName, reason: "We are back online"),
      );

      workscreenModel = uiService.getComponentByScreenName(pScreenName: offlineWorkscreenLongName)!;

      dialogKey.currentState?.update(
          config: Config(
        progressType: ProgressType.valuable,
        message: "Fetching online data...",
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
      for (DataBook dataBook in dataBooks.values) {
        log("DataBook: " + dataBook.dataProvider + " | " + dataBook.records.length.toString());

        Map<String, List<Map<String, Object?>>> groupedRows =
            await offlineApiRepository.getChangedRows(dataBook.dataProvider);

        dialogKey.currentState?.update(
            config: Config(
          message: "Syncing data... ($dataBookCounter / ${dataBooks.length})",
          progress: groupedRows.length - successfulSyncedPrimaryKeys.length,
          maxProgress: groupedRows.length,
        ));

        successfulSync =
            await _handleInsertedRows(groupedRows, dataBook, commandService, successfulSyncedPrimaryKeys) &&
                successfulSync;

        successfulSync = await _handleUpdatedRows(groupedRows, dataBook, commandService, successfulSyncedPrimaryKeys) &&
            successfulSync;

        successfulSync = await _handleDeletedRow(groupedRows, dataBook, commandService, successfulSyncedPrimaryKeys) &&
            successfulSync;

        dataBookCounter++;
        await offlineApiRepository.resetStates(dataBook.dataProvider, pResetRows: successfulSyncedPrimaryKeys);
      }

      dialogKey.currentState?.update(
          config: Config(
        message: "Synced ${successfulSyncedPrimaryKeys.length} rows",
      ));

      log("Synced ${successfulSyncedPrimaryKeys.length} rows");
      if (successfulSync) {
        log("Sync successful");
        await offlineApiRepository.deleteDatabase();

        await configService.setOffline(false);
        DefaultLoadingProgressHandler.setEnabled(true);
        await offlineApiRepository.stop();

        ProgressDialogWidget.close(context);

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
        ProgressDialogWidget.close(context);
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
      await Wakelock.disable();
      //In case it hasn't been closed yet
      ProgressDialogWidget.safeClose(dialogKey);
    }
  }

  static Future<bool> _handleInsertedRows(Map<String, List<Map<String, Object?>>> groupedRows, DataBook dataBook,
      ICommandService commandService, List<Map<String, Object?>> successfulSyncedPrimaryKeys) async {
    try {
      List<Map<String, Object?>>? insertedRows = groupedRows[OfflineDatabase.ROW_STATE_INSERTED];
      log("Syncing inserted rows: " + insertedRows.toString());
      if (insertedRows != null) {
        for (var row in insertedRows) {
          Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
          await _insertOfflineRecord(commandService, dataBook, row);
          successfulSyncedPrimaryKeys.add(primaryColumns);
        }
      }
    } catch (e, stackTrace) {
      log("Error while syncing inserted rows: ", error: e, stackTrace: stackTrace);
      return false;
    }
    return true;
  }

  static Future<bool> _handleUpdatedRows(Map<String, List<Map<String, Object?>>> groupedRows, DataBook dataBook,
      ICommandService commandService, List<Map<String, Object?>> successfulSyncedPrimaryKeys) async {
    try {
      List<Map<String, Object?>>? updatedRows = groupedRows[OfflineDatabase.ROW_STATE_UPDATED];
      log("Syncing updated rows: " + updatedRows.toString());
      if (updatedRows != null) {
        for (var row in updatedRows) {
          var oldColumns = {
            for (var entry in row.entries.where((rowColumn) => rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX)))
              entry.key: entry.value
          };
          Map<String, Object?> primaryColumns = _getPrimaryColumns(oldColumns, dataBook);

          await _updateOfflineRecord(row, commandService, dataBook, primaryColumns);
          successfulSyncedPrimaryKeys.add(primaryColumns);
        }
      }
    } catch (e, stackTrace) {
      log("Error while syncing updated rows: ", error: e, stackTrace: stackTrace);
      return false;
    }
    return true;
  }

  static Future<bool> _handleDeletedRow(Map<String, List<Map<String, Object?>>> groupedRows, DataBook dataBook,
      ICommandService commandService, List<Map<String, Object?>> successfulSyncedPrimaryKeys) async {
    try {
      List<Map<String, Object?>>? deletedRows = groupedRows[OfflineDatabase.ROW_STATE_DELETED];
      log("Syncing deleted rows: " + deletedRows.toString());
      if (deletedRows != null) {
        for (var row in deletedRows) {
          Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
          await _deleteOfflineRecord(commandService, dataBook, primaryColumns);
          successfulSyncedPrimaryKeys.add(primaryColumns);
        }
      }
    } catch (e, stackTrace) {
      log("Error while syncing deleted rows: ", error: e, stackTrace: stackTrace);
      return false;
    }
    return true;
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
    ICommandService commandService = services<ICommandService>();

    var dialogKey = GlobalKey<ProgressDialogState>();
    OnlineApiRepository? onlineApiRepository;
    OfflineApiRepository? offlineApiRepository;
    try {
      await Wakelock.enable();
      DefaultLoadingProgressHandler.setEnabled(false);
      //Set already here to receive errors from api responses
      await configService.setOffline(true);

      unawaited(showDialog(
        context: context,
        builder: (context) {
          return ProgressDialogWidget(
            key: dialogKey,
            config: Config(
              message: "Fetching offline data...",
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
        message: "Loading data...",
        progressType: ProgressType.valuable,
        progress: 0,
        maxProgress: 100,
      ));

      offlineApiRepository = OfflineApiRepository();
      await offlineApiRepository.start();
      await offlineApiRepository.initDatabase((value, max, {progress}) {
        dialogKey.currentState?.update(
            config: Config(
          message: "Loading data ($value / $max)...",
          progress: progress ?? 0,
        ));
      });

      onlineApiRepository = (await apiService.getRepository()) as OnlineApiRepository;
      await apiService.setRepository(offlineApiRepository);
      await configService.setOfflineScreen(uiService.getComponentByName(pComponentName: pWorkscreen)!.screenLongName!);
      await onlineApiRepository.stop();

      ProgressDialogWidget.close(context);
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
      await Wakelock.disable();
      //In case it hasn't been closed yet
      ProgressDialogWidget.safeClose(dialogKey);
    }
  }
}
