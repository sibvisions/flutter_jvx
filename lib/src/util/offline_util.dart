import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

import '../../main.dart';
import '../../util/logging/flutter_logger.dart';
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
import 'loading_handler/progress_dialog_widget.dart';

abstract class OfflineUtil {
  static Widget getOfflineBar(BuildContext context, {bool useElevation = false}) {
    return Material(
      color: Colors.grey.shade500,
      elevation: useElevation ? Theme.of(context).appBarTheme.elevation ?? 4.0 : 0.0,
      child: Container(
        height: 20,
        alignment: Alignment.center,
        child: const Text(
          'OFFLINE',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  static initOnline() async {
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
      String offlineWorkscreenLongName = configService.getOfflineScreen()!;
      String offlineAppName = configService.getAppName()!;
      String offlineUsername = configService.getUsername()!;
      String offlinePassword = configService.getPassword()!;

      var futureDialog = uiService.openDialog(
        pIsDismissible: false,
        pBuilder: (context) => ProgressDialogWidget(
          key: dialogKey,
          config: Config(
            message: FlutterJVx.translate("Re-syncing offline data"),
            barrierDismissible: false,
          ),
        ),
      );

      offlineApiRepository = (await apiService.getRepository()) as OfflineApiRepository;
      //Set online api repository to handle commands
      onlineApiRepository = OnlineApiRepository(apiConfig: ApiConfig(serverConfig: configService.getServerConfig()));
      await onlineApiRepository.start();
      await apiService.setRepository(onlineApiRepository);

      await commandService.sendCommand(
        StartupCommand(
          reason: "Going online",
          appName: offlineAppName,
          username: offlineUsername,
          password: offlinePassword,
        ),
      );

      await commandService.sendCommand(
        OpenScreenCommand(screenLongName: offlineWorkscreenLongName, reason: "We are back online"),
      );

      bool successfulSync = true;
      int dataBookCounter = 1;
      int successfulSyncedRows = 0;
      int changedRowsSum = 0;

      var dataBooks = dataService.getDataBooks();
      for (DataBook dataBook in dataBooks.values) {
        log("DataBook: ${dataBook.dataProvider} | ${dataBook.records.length}");
        List<Map<String, Object?>> successfulSyncedPrimaryKeys = [];

        Map<String, List<Map<String, Object?>>> groupedRows =
            await offlineApiRepository.getChangedRows(dataBook.dataProvider);
        int changedRowsPerDataBook = 0;
        if (groupedRows.isNotEmpty) {
          changedRowsPerDataBook = groupedRows.values.map((e) => e.length).reduce((value, element) => value + element);
          changedRowsSum += changedRowsPerDataBook;
        }

        dialogKey.currentState?.update(
            config: Config(
          message: "${FlutterJVx.translate("Syncing data")} ($dataBookCounter / ${dataBooks.length})",
          progress: successfulSyncedPrimaryKeys.length,
          maxProgress: changedRowsPerDataBook,
        ));

        successfulSync = await _handleInsertedRows(
              groupedRows[OfflineDatabase.ROW_STATE_INSERTED],
              dataBook,
              commandService,
              successfulSyncedPrimaryKeys,
              dialogKey: dialogKey,
            ) &&
            successfulSync;

        successfulSync = await _handleUpdatedRows(
              groupedRows[OfflineDatabase.ROW_STATE_UPDATED],
              dataBook,
              commandService,
              successfulSyncedPrimaryKeys,
              dialogKey: dialogKey,
            ) &&
            successfulSync;

        successfulSync = await _handleDeletedRows(
              groupedRows[OfflineDatabase.ROW_STATE_DELETED],
              dataBook,
              commandService,
              successfulSyncedPrimaryKeys,
              dialogKey: dialogKey,
            ) &&
            successfulSync;

        log("Marking ${successfulSyncedPrimaryKeys.length} rows as synced");
        await offlineApiRepository.resetStates(dataBook.dataProvider, pResetRows: successfulSyncedPrimaryKeys);
        successfulSyncedRows += successfulSyncedPrimaryKeys.length;

        dataBookCounter++;
      }

      String syncResult = successfulSync ? "successful" : "failed";
      int failedRowCount = changedRowsSum - successfulSyncedRows;

      log("Sync $syncResult: Synced $successfulSyncedRows rows, $failedRowCount rows failed");

      if (successfulSyncedRows > 0 || failedRowCount > 0) {
        dialogKey.currentState!.update(
            config: Config(
          message:
              "Successfully synced $successfulSyncedRows rows${failedRowCount > 0 ? ".\n$failedRowCount rows failed to sync" : ""}",
          progress: 100,
          maxProgress: 100,
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogKey.currentContext!).pop(),
              child: Text(FlutterJVx.translate("Ok")),
            ),
          ],
        ));
        await futureDialog;
      } else {
        ProgressDialogWidget.close(IUiService.getCurrentContext()!);
      }

      if (successfulSync) {
        await offlineApiRepository.deleteDatabase();
        dataService.clearDataBooks();

        await configService.setOffline(false);
        await offlineApiRepository.stop();

        FlComponentModel? workscreenModel =
            uiService.getComponentByScreenName(pScreenLongName: offlineWorkscreenLongName)!;
        await commandService.sendCommand(
          CloseScreenCommand(screenName: workscreenModel.name, reason: "We have synced"),
        );

        await commandService.sendCommand(
          StartupCommand(
            reason: "Going online",
            appName: offlineAppName,
            username: offlineUsername,
            password: offlinePassword,
          ),
        );
      } else {
        await onlineApiRepository.stop();
        await apiService.setRepository(offlineApiRepository);
      }
    } catch (e, stackTrace) {
      LOGGER.logE(
        pType: LogType.DATA,
        pMessage: "Error while syncing offline data",
        pError: e,
        pStacktrace: stackTrace,
      );

      //Revert all changes in case we have an in-tact offline state
      if (offlineApiRepository != null && !offlineApiRepository.isStopped()) {
        await onlineApiRepository?.stop();
        await apiService.setRepository(offlineApiRepository);
        await configService.setOffline(true);
        //Clear menu
        uiService.setMenuModel(null);
      }

      ProgressDialogWidget.safeClose(dialogKey);
      await uiService.openDialog(
        pIsDismissible: false,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterJVx.translate("Offline Sync Error")),
          content: Text(FlutterJVx.translate("There was an error while trying to sync your data."
              "\n${e.toString()}")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterJVx.translate("Ok")),
            ),
          ],
        ),
      );
    } finally {
      await Wakelock.disable();
      //In case it hasn't been closed yet
      ProgressDialogWidget.safeClose(dialogKey);
    }
  }

  static Future<bool> _handleInsertedRows(
    List<Map<String, Object?>>? insertedRows,
    DataBook dataBook,
    ICommandService commandService,
    List<Map<String, Object?>> successfulSyncedPrimaryKeys, {
    required GlobalKey<ProgressDialogState> dialogKey,
  }) async {
    bool successful = true;
    if (insertedRows != null) {
      log("Syncing ${insertedRows.length} inserted rows");
      for (var row in insertedRows) {
        try {
          Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
          await _insertOfflineRecord(commandService, dataBook, row);
          successfulSyncedPrimaryKeys.add(primaryColumns);

          dialogKey.currentState?.update(
              config: Config(
            progress: successfulSyncedPrimaryKeys.length,
          ));
        } catch (e, stack) {
          LOGGER.logE(
            pType: LogType.DATA,
            pMessage: "Error while syncing inserted row: $row",
            pError: e,
            pStacktrace: stack,
          );
          successful = false;
        }
      }
    }
    return successful;
  }

  static Future<bool> _handleUpdatedRows(
    List<Map<String, Object?>>? updatedRows,
    DataBook dataBook,
    ICommandService commandService,
    List<Map<String, Object?>> successfulSyncedPrimaryKeys, {
    required GlobalKey<ProgressDialogState> dialogKey,
  }) async {
    bool successful = true;
    if (updatedRows != null) {
      log("Syncing ${updatedRows.length} updated rows");
      for (var row in updatedRows) {
        try {
          var oldColumns = {
            for (var entry in row.entries.where((rowColumn) => rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX)))
              entry.key.replaceAll(OfflineDatabase.COLUMN_PREFIX, ""): entry.value
          };
          Map<String, Object?> primaryColumns = _getPrimaryColumns(oldColumns, dataBook);

          await _updateOfflineRecord(row, commandService, dataBook, primaryColumns);
          successfulSyncedPrimaryKeys.add(primaryColumns);

          dialogKey.currentState?.update(
              config: Config(
            progress: successfulSyncedPrimaryKeys.length,
          ));
        } catch (e, stack) {
          LOGGER.logE(
            pType: LogType.DATA,
            pMessage: "Error while syncing updated row: $row",
            pError: e,
            pStacktrace: stack,
          );
          successful = false;
        }
      }
    }
    return successful;
  }

  static Future<bool> _handleDeletedRows(
    List<Map<String, Object?>>? deletedRows,
    DataBook dataBook,
    ICommandService commandService,
    List<Map<String, Object?>> successfulSyncedPrimaryKeys, {
    required GlobalKey<ProgressDialogState> dialogKey,
  }) async {
    bool successful = true;
    if (deletedRows != null) {
      log("Syncing ${deletedRows.length} deleted rows");
      for (var row in deletedRows) {
        try {
          Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
          await _deleteOfflineRecord(commandService, dataBook, primaryColumns);
          successfulSyncedPrimaryKeys.add(primaryColumns);

          dialogKey.currentState?.update(
              config: Config(
            progress: successfulSyncedPrimaryKeys.length,
          ));
        } catch (e, stack) {
          LOGGER.logE(
            pType: LogType.DATA,
            pMessage: "Error while syncing deleted row: $row",
            pError: e.toString(),
            pStacktrace: stack,
          );
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

  static Set<String> getActiveDataProviders(IDataService dataService, String offlineWorkscreen) {
    //String databookPrefix = configService.getAppName() + "/" + pWorkscreen;
    return dataService.getDataBooks().keys.toList().where((element) {
      var prefixes = element.split("/");
      if (prefixes.length >= 2) {
        return prefixes[1] == offlineWorkscreen;
      }
      return false;
    }).toSet();
  }

  static Future<void> fetchDataProvider(
    Set<String> activeDataProviders,
    ICommandService commandService, {
    void Function(int value, int max)? progressUpdate,
  }) async {
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

    log("Finished fetching data");
  }

  static initOffline(String pWorkscreen) async {
    IConfigService configService = services<IConfigService>();
    IUiService uiService = services<IUiService>();
    IApiService apiService = services<IApiService>();
    IDataService dataService = services<IDataService>();
    ICommandService commandService = services<ICommandService>();

    var dialogKey = GlobalKey<ProgressDialogState>();
    OnlineApiRepository? onlineApiRepository = (await apiService.getRepository()) as OnlineApiRepository;
    OfflineApiRepository? offlineApiRepository;
    try {
      await Wakelock.enable();
      //Set already here to receive errors from api responses
      await configService.setOffline(true);

      unawaited(uiService.openDialog(
        pIsDismissible: false,
        pBuilder: (context) {
          return ProgressDialogWidget(
            key: dialogKey,
            config: Config(
              message: FlutterJVx.translate("Fetching offline data"),
              barrierDismissible: false,
            ),
          );
        },
      ));

      var activeDataProviders = getActiveDataProviders(dataService, pWorkscreen);
      await fetchDataProvider(
        activeDataProviders,
        commandService,
        progressUpdate: (value, max) {
          dialogKey.currentState?.update(
              config: Config(
            progress: value,
            maxProgress: max,
          ));
        },
      );

      dialogKey.currentState?.update(
          config: Config(
        message: FlutterJVx.translate("Processing data"),
        progress: 0,
        maxProgress: 100,
      ));

      offlineApiRepository = OfflineApiRepository();
      await offlineApiRepository.start();

      var dataBooks = dataService
          .getDataBooks()
          .values
          .where((element) => activeDataProviders.contains(element.dataProvider))
          .toList(growable: false);
      await offlineApiRepository.initDatabase(dataBooks, (value, max, {progress}) {
        dialogKey.currentState?.update(
            config: Config(
          message: "${FlutterJVx.translate("Processing data")} ($value / $max)",
          progress: progress ?? 0,
        ));
      });

      //Clear databooks for offline usage
      dataService.clearDataBooks();
      await offlineApiRepository.initDataBooks(dataService);

      await apiService.setRepository(offlineApiRepository);
      await configService.setOfflineScreen(uiService.getComponentByName(pComponentName: pWorkscreen)!.screenLongName!);
      await onlineApiRepository.stop();
      //Clear menu
      uiService.setMenuModel(null);

      ProgressDialogWidget.close(IUiService.getCurrentContext()!);
      await commandService.sendCommand(RouteToMenuCommand(replaceRoute: true, reason: "We are going offline"));
    } catch (e, stackTrace) {
      LOGGER.logE(
        pType: LogType.DATA,
        pMessage: "Error while downloading offline data",
        pError: e,
        pStacktrace: stackTrace,
      );

      //Revert all changes
      if (offlineApiRepository != null && !offlineApiRepository.isStopped()) {
        await offlineApiRepository.deleteDatabase();
      }
      await offlineApiRepository?.stop();
      await apiService.setRepository(onlineApiRepository);
      await configService.setOffline(false);

      ProgressDialogWidget.safeClose(dialogKey);
      await uiService.openDialog(
        pIsDismissible: false,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterJVx.translate("Offline Init Error")),
          content: Text(FlutterJVx.translate("There was an error while trying to download data."
              "\n${e.toString()}")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterJVx.translate("Ok")),
            ),
          ],
        ),
      );
    } finally {
      await Wakelock.disable();
      //In case it hasn't been closed yet
      ProgressDialogWidget.safeClose(dialogKey);
    }
  }

  static void discardChanges(BuildContext context) async {
    IApiService apiService = services<IApiService>();
    var offlineApiRepository = (await apiService.getRepository());
    if (offlineApiRepository is OfflineApiRepository && !offlineApiRepository.isStopped()) {
      await offlineApiRepository.deleteDatabase();
    }
  }
}
