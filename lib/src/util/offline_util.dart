/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

import '../flutter_ui.dart';
import '../model/command/api/close_screen_command.dart';
import '../model/command/api/delete_record_command.dart';
import '../model/command/api/exit_command.dart';
import '../model/command/api/fetch_command.dart';
import '../model/command/api/insert_record_command.dart';
import '../model/command/api/open_screen_command.dart';
import '../model/command/api/set_values_command.dart';
import '../model/command/api/startup_command.dart';
import '../model/command/storage/delete_screen_command.dart';
import '../model/command/ui/route_to_menu_command.dart';
import '../model/component/fl_component_model.dart';
import '../model/data/data_book.dart';
import '../model/request/filter.dart';
import '../service/api/i_api_service.dart';
import '../service/api/shared/repository/offline/offline_database.dart';
import '../service/api/shared/repository/offline_api_repository.dart';
import '../service/api/shared/repository/online_api_repository.dart';
import '../service/command/i_command_service.dart';
import '../service/config/config_controller.dart';
import '../service/data/i_data_service.dart';
import '../service/storage/i_storage_service.dart';
import '../service/ui/i_ui_service.dart';
import 'progress/progress_dialog_widget.dart';

abstract class OfflineUtil {
  static Widget getOfflineBar(BuildContext context, {bool useElevation = false}) {
    return Material(
      color: Colors.grey.shade500,
      elevation: useElevation ? Theme.of(context).appBarTheme.elevation ?? 4.0 : 0.0,
      child: Container(
        height: 20,
        alignment: Alignment.center,
        child: const Text(
          "OFFLINE",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  static initOnline() async {
    var dialogKey = GlobalKey<ProgressDialogState>();
    OnlineApiRepository? onlineApiRepository;
    OfflineApiRepository? offlineApiRepository;
    try {
      await Wakelock.enable();
      String offlineWorkscreenClassName = ConfigController().offlineScreen.value!;
      String? offlineUsername = ConfigController().username.value;
      String? offlinePassword = ConfigController().password.value;

      var futureDialog = IUiService().openDialog(
        pIsDismissible: false,
        pBuilder: (context) => ProgressDialogWidget(
          key: dialogKey,
          config: Config(
            message: FlutterUI.translate("Re-syncing offline data"),
            barrierDismissible: false,
          ),
        ),
      );

      offlineApiRepository = IApiService().getRepository() as OfflineApiRepository;
      // Set online api repository to handle commands
      onlineApiRepository = OnlineApiRepository();
      await onlineApiRepository.start();
      IApiService().setRepository(onlineApiRepository);

      await ICommandService().sendCommand(
        StartupCommand(
          reason: "Going online",
          username: offlineUsername,
          password: offlinePassword,
        ),
      );

      await ICommandService().sendCommand(
        OpenScreenCommand(
          screenClassName: offlineWorkscreenClassName,
          reason: "We are back online",
          parameter: {"mobile.onlineSync": true},
        ),
      );

      bool successfulSync = true;
      int dataBookCounter = 1;
      int successfulSyncedRows = 0;
      int changedRowsSum = 0;

      var dataBooks = IDataService().getDataBooks();
      for (DataBook dataBook in dataBooks.values) {
        FlutterUI.logAPI.i("DataBook: ${dataBook.dataProvider} | ${dataBook.records.length}");
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
          message: "${FlutterUI.translate("Syncing data")} ($dataBookCounter / ${dataBooks.length})",
          progress: successfulSyncedPrimaryKeys.length,
          maxProgress: changedRowsPerDataBook,
        ));

        successfulSync = await _handleInsertedRows(
              groupedRows[OfflineDatabase.ROW_STATE_INSERTED],
              dataBook,
              successfulSyncedPrimaryKeys,
              dialogKey: dialogKey,
            ) &&
            successfulSync;

        successfulSync = await _handleUpdatedRows(
              groupedRows[OfflineDatabase.ROW_STATE_UPDATED],
              dataBook,
              successfulSyncedPrimaryKeys,
              dialogKey: dialogKey,
            ) &&
            successfulSync;

        successfulSync = await _handleDeletedRows(
              groupedRows[OfflineDatabase.ROW_STATE_DELETED],
              dataBook,
              successfulSyncedPrimaryKeys,
              dialogKey: dialogKey,
            ) &&
            successfulSync;

        FlutterUI.logAPI.i("Marking ${successfulSyncedPrimaryKeys.length} rows as synced");
        await offlineApiRepository.resetStates(dataBook.dataProvider, pResetRows: successfulSyncedPrimaryKeys);
        successfulSyncedRows += successfulSyncedPrimaryKeys.length;

        dataBookCounter++;
      }

      String syncResult = successfulSync ? "successful" : "failed";
      int failedRowCount = changedRowsSum - successfulSyncedRows;

      FlutterUI.logAPI.i("Sync $syncResult: Synced $successfulSyncedRows rows, $failedRowCount rows failed");

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
              child: Text(FlutterUI.translate("Ok")),
            ),
          ],
        ));
        await futureDialog;
      } else {
        ProgressDialogWidget.close(FlutterUI.getCurrentContext()!);
      }

      if (successfulSync) {
        await offlineApiRepository.deleteDatabase();
        IDataService().clearDataBooks();

        await ConfigController().updateOffline(false);
        await ConfigController().updatePassword(null);
        await offlineApiRepository.stop();

        FlPanelModel? workscreenModel =
            IStorageService().getComponentByScreenClassName(pScreenClassName: offlineWorkscreenClassName)!;
        await ICommandService().sendCommands([
          CloseScreenCommand(screenName: workscreenModel.name, reason: "We have synced"),
          DeleteScreenCommand(screenName: workscreenModel.name, reason: "We have synced"),
        ]);

        await ICommandService().sendCommand(
          StartupCommand(
            reason: "Going online",
            username: offlineUsername,
            password: offlinePassword,
          ),
        );
      } else {
        await onlineApiRepository.stop();
        IApiService().setRepository(offlineApiRepository);
      }
    } catch (e, stackTrace) {
      FlutterUI.logAPI.e("Error while syncing offline data", e, stackTrace);

      // Revert all changes in case we have an in-tact offline state
      if (offlineApiRepository != null && !offlineApiRepository.isStopped()) {
        await onlineApiRepository?.stop();
        IApiService().setRepository(offlineApiRepository);
        await ConfigController().updateOffline(true);
        // Clear menu
        IUiService().setMenuModel(null);
      }

      ProgressDialogWidget.safeClose(dialogKey);
      await IUiService().openDialog(
        pIsDismissible: false,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterUI.translate("Offline Sync Error")),
          content: Text(FlutterUI.translate("There was an error while trying to sync your data."
              "\n${e.toString()}")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterUI.translate("Ok")),
            ),
          ],
        ),
      );
    } finally {
      await Wakelock.disable();
      // In case it hasn't been closed yet
      ProgressDialogWidget.safeClose(dialogKey);
    }
  }

  static Future<bool> _handleInsertedRows(
    List<Map<String, Object?>>? insertedRows,
    DataBook dataBook,
    List<Map<String, Object?>> successfulSyncedPrimaryKeys, {
    required GlobalKey<ProgressDialogState> dialogKey,
  }) async {
    bool successful = true;
    if (insertedRows != null) {
      FlutterUI.logAPI.i("Syncing ${insertedRows.length} inserted rows");
      for (var row in insertedRows) {
        try {
          Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
          await _insertOfflineRecord(dataBook, row);
          successfulSyncedPrimaryKeys.add(primaryColumns);

          dialogKey.currentState?.update(
              config: Config(
            progress: successfulSyncedPrimaryKeys.length,
          ));
        } catch (e, stack) {
          FlutterUI.logAPI.e("Error while syncing inserted row: $row", e, stack);
          successful = false;
        }
      }
    }
    return successful;
  }

  static Future<bool> _handleUpdatedRows(
    List<Map<String, Object?>>? updatedRows,
    DataBook dataBook,
    List<Map<String, Object?>> successfulSyncedPrimaryKeys, {
    required GlobalKey<ProgressDialogState> dialogKey,
  }) async {
    bool successful = true;
    if (updatedRows != null) {
      FlutterUI.logAPI.i("Syncing ${updatedRows.length} updated rows");
      for (var row in updatedRows) {
        try {
          var oldColumns = {
            for (var entry in row.entries.where((rowColumn) => rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX)))
              entry.key.replaceAll(OfflineDatabase.COLUMN_PREFIX, ""): entry.value
          };
          Map<String, Object?> primaryColumns = _getPrimaryColumns(oldColumns, dataBook);

          await _updateOfflineRecord(row, dataBook, primaryColumns);
          successfulSyncedPrimaryKeys.add(primaryColumns);

          dialogKey.currentState?.update(
              config: Config(
            progress: successfulSyncedPrimaryKeys.length,
          ));
        } catch (e, stack) {
          FlutterUI.logAPI.e("Error while syncing updated row: $row", e, stack);
          successful = false;
        }
      }
    }
    return successful;
  }

  static Future<bool> _handleDeletedRows(
    List<Map<String, Object?>>? deletedRows,
    DataBook dataBook,
    List<Map<String, Object?>> successfulSyncedPrimaryKeys, {
    required GlobalKey<ProgressDialogState> dialogKey,
  }) async {
    bool successful = true;
    if (deletedRows != null) {
      FlutterUI.logAPI.i("Syncing ${deletedRows.length} deleted rows");
      for (var row in deletedRows) {
        try {
          Map<String, Object?> primaryColumns = _getPrimaryColumns(row, dataBook);
          await _deleteOfflineRecord(dataBook, primaryColumns);
          successfulSyncedPrimaryKeys.add(primaryColumns);

          dialogKey.currentState?.update(
              config: Config(
            progress: successfulSyncedPrimaryKeys.length,
          ));
        } catch (e, stack) {
          FlutterUI.logAPI.e("Error while syncing deleted row: $row", e, stack);
          successful = false;
        }
      }
    }
    return successful;
  }

  static Future<void> _insertOfflineRecord(DataBook dataBook, Map<String, Object?> row) async {
    await ICommandService().sendCommand(InsertRecordCommand(
      reason: "Re-sync: Insert",
      dataProvider: dataBook.dataProvider,
    ));

    // Remove all $OLD$ columns
    var newColumns = {
      for (var entry in row.entries.where((rowColumn) =>
          !(rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX) || rowColumn.key == OfflineDatabase.STATE_COLUMN)))
        entry.key: entry.value
    };

    return ICommandService().sendCommand(SetValuesCommand(
      reason: "Re-sync: Insert",
      componentId: "",
      dataProvider: dataBook.dataProvider,
      columnNames: newColumns.keys.toList(growable: false),
      values: newColumns.values.toList(growable: false),
    ));
  }

  static Future<void> _updateOfflineRecord(
      Map<String, Object?> row, DataBook dataBook, Map<String, Object?> primaryColumns) {
    var newColumns = {
      for (var entry in row.entries.where((rowColumn) =>
          !(rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX) || rowColumn.key == OfflineDatabase.STATE_COLUMN)))
        entry.key: entry.value
    };
    return ICommandService().sendCommand(SetValuesCommand(
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

  static Future<void> _deleteOfflineRecord(DataBook dataBook, Map<String, Object?> primaryColumns) {
    return ICommandService().sendCommand(DeleteRecordCommand(
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
          (rowColumn) => dataBook.metaData.primaryKeyColumns.any((primaryColumn) => primaryColumn == rowColumn.key)))
        entry.key: entry.value
    };
    return primaryColumns;
  }

  static Set<String> getActiveDataProviders(String offlineWorkscreen) {
    // String databookPrefix = ConfigController.appName + "/" + pWorkscreen;
    return IDataService().getDataBooks().keys.toList().where((element) {
      var prefixes = element.split("/");
      if (prefixes.length >= 2) {
        return prefixes[1] == offlineWorkscreen;
      }
      return false;
    }).toSet();
  }

  static Future<void> fetchDataProvider(
    Set<String> activeDataProviders, {
    void Function(int value, int max)? progressUpdate,
  }) async {
    int fetchCounter = 1;
    for (String dataProvider in activeDataProviders) {
      FlutterUI.logAPI.i("Start fetching $dataProvider");

      progressUpdate?.call(fetchCounter++, activeDataProviders.length);

      await ICommandService().sendCommand(
        FetchCommand(
          reason: "Fetching data for offline/online switch",
          dataProvider: dataProvider,
          fromRow: 0,
          rowCount: -1,
          includeMetaData: true,
        ),
      );
    }

    FlutterUI.logAPI.i("Finished fetching data");
  }

  static initOffline(String pScreenName) async {
    var dialogKey = GlobalKey<ProgressDialogState>();
    OnlineApiRepository? onlineApiRepository = IApiService().getRepository() as OnlineApiRepository;
    OfflineApiRepository? offlineApiRepository;
    try {
      await Wakelock.enable();
      // Set already here to receive errors from api responses
      await ConfigController().updateOffline(true);
      // Save password for re-sync
      await ConfigController().updatePassword(FlutterUI.of(FlutterUI.getCurrentContext()!).lastPassword);

      unawaited(IUiService().openDialog(
        pIsDismissible: false,
        pBuilder: (context) {
          return ProgressDialogWidget(
            key: dialogKey,
            config: Config(
              message: FlutterUI.translate("Fetching offline data"),
              barrierDismissible: false,
            ),
          );
        },
      ));

      Set<String> activeDataProviders = getActiveDataProviders(pScreenName);
      await fetchDataProvider(
        activeDataProviders,
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
        message: FlutterUI.translate("Processing data"),
        progress: 0,
        maxProgress: 100,
      ));

      offlineApiRepository = OfflineApiRepository();
      await offlineApiRepository.start();

      var dataBooks = IDataService()
          .getDataBooks()
          .values
          .where((element) => activeDataProviders.contains(element.dataProvider))
          .toList(growable: false);
      await offlineApiRepository.initDatabase(
        dataBooks,
        (value, max, {progress}) {
          dialogKey.currentState?.update(
              config: Config(
            message: "${FlutterUI.translate("Processing data")} ($value / $max)",
            progress: progress ?? 0,
          ));
        },
      );

      var panelModel = IStorageService().getComponentByName(pComponentName: pScreenName) as FlPanelModel;

      // Close and delete screen
      await ICommandService().sendCommands([
        CloseScreenCommand(screenName: panelModel.name, reason: "We have fetched"),
        DeleteScreenCommand(screenName: panelModel.name, reason: "We have fetched"),
        ExitCommand(reason: "Going offline"),
      ]);

      // Clear databooks for offline usage
      IDataService().clearDataBooks();
      await offlineApiRepository.initDataBooks();

      IApiService().setRepository(offlineApiRepository);
      await ConfigController().updateOfflineScreen(panelModel.screenClassName!);
      await onlineApiRepository.stop();
      // Clear menu
      IUiService().setMenuModel(null);

      ProgressDialogWidget.close(FlutterUI.getCurrentContext()!);
      await ICommandService().sendCommand(RouteToMenuCommand(replaceRoute: true, reason: "We are going offline"));
    } catch (e, stack) {
      FlutterUI.logAPI.e("Error while downloading offline data", e, stack);

      // Revert all changes
      if (offlineApiRepository != null && !offlineApiRepository.isStopped()) {
        await offlineApiRepository.deleteDatabase();
      }
      await offlineApiRepository?.stop();
      IApiService().setRepository(onlineApiRepository);
      await ConfigController().updateOffline(false);

      ProgressDialogWidget.safeClose(dialogKey);
      await IUiService().openDialog(
        pIsDismissible: false,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterUI.translate("Offline Init Error")),
          content: Text(FlutterUI.translate("There was an error while trying to download data."
              "\n${e.toString()}")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterUI.translate("Ok")),
            ),
          ],
        ),
      );
    } finally {
      await Wakelock.disable();
      // In case it hasn't been closed yet
      ProgressDialogWidget.safeClose(dialogKey);
    }
  }

  static Future<void> discardChanges(BuildContext context) async {
    var offlineApiRepository = IApiService().getRepository();
    if (offlineApiRepository is OfflineApiRepository && !offlineApiRepository.isStopped()) {
      await offlineApiRepository.deleteDatabase();
    }
  }
}
