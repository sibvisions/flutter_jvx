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

import 'package:collection/collection.dart';
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
import '../model/component/fl_component_model.dart';
import '../model/data/data_book.dart';
import '../model/request/filter.dart';
import '../service/api/i_api_service.dart';
import '../service/api/shared/repository/offline/offline_database.dart';
import '../service/api/shared/repository/offline_api_repository.dart';
import '../service/api/shared/repository/online_api_repository.dart';
import '../service/command/i_command_service.dart';
import '../service/config/i_config_service.dart';
import '../service/data/i_data_service.dart';
import '../service/storage/i_storage_service.dart';
import '../service/ui/i_ui_service.dart';
import 'misc/dialog_result.dart';
import 'widgets/progress/progress_dialog_widget.dart';

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

  static Future<void> initOnline([bool pDiscardChanges = false]) async {
    var dialogKey = GlobalKey<ProgressDialogState>();
    OnlineApiRepository onlineApiRepository = OnlineApiRepository();
    OfflineApiRepository offlineApiRepository = IApiService().getRepository() as OfflineApiRepository;
    String failedStep = "Initializing";
    String offlineWorkscreenClassName = IConfigService().offlineScreen.value!;

    try {
      await Wakelock.enable();
      String? offlineUsername = IConfigService().username.value;
      String? offlinePassword = IConfigService().password.value;

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

      // Set online api repository to handle commands
      await onlineApiRepository.start();
      IApiService().setRepository(onlineApiRepository);

      failedStep = "Connecting to server";
      await ICommandService().sendCommand(
        StartupCommand(
          reason: "Going online",
          username: offlineUsername,
          password: offlinePassword,
        ),
      );

      failedStep = "Preparing synchronization";
      await ICommandService().sendCommand(
        OpenScreenCommand(
          screenClassName: offlineWorkscreenClassName,
          reason: "We are back online",
          parameter: {"mobile.onlineSync": true},
        ),
      );

      int successfulSyncedRows = 0;
      int failedSyncedRows = 0;

      if (!pDiscardChanges) {
        // To keep foreign key relations intact. First execute inserts, then updates.
        // Deletes should be executed when traversing the list in reverse
        var dataBooks = IDataService().getDataBooks();

        // Sort data books by level of how many master references they have in the list of data books
        Map<int, List<DataBook>> dataBooksByLevel = {};
        for (DataBook dataBook in dataBooks.values) {
          int iLevel = 0;

          for (String? masterDataBook = dataBook.metaData.masterReference?.referencedDataBook;
              masterDataBook != null;
              masterDataBook = dataBooks[masterDataBook]?.metaData.masterReference?.referencedDataBook) {
            iLevel++;
          }

          dataBooksByLevel.putIfAbsent(iLevel, () => []);
          dataBooksByLevel[iLevel]!.add(dataBook);
        }

        // Adds all data books to a list, sorted by their level
        List<DataBook> sortedList = [];
        dataBooksByLevel.keys
            .sorted((a, b) => a.compareTo(b))
            .forEach((key) => sortedList.addAll(dataBooksByLevel[key]!));

        // These are all data books that have changes present.
        List<DataBook> sortedListInserts = [];
        List<DataBook> sortedListUpdates = [];
        List<DataBook> sortedListDeletes = [];
        Map<String, List<Map<String, Object?>>> insertsByDataBook = {};
        Map<String, List<Map<String, Object?>>> updatesByDataBook = {};
        Map<String, List<Map<String, Object?>>> deletesByDataBook = {};
        // The first key is the databook
        // The second key is what kind of changed row this is. (insert, update, delete)
        // OfflineDatabase.ROW_STATE_INSERTED, OfflineDatabase.ROW_STATE_UPDATED, OfflineDatabase.ROW_STATE_DELETED
        for (DataBook dataBook in sortedList) {
          Map<String, List<Map<String, Object?>>> changedRows =
              await offlineApiRepository.getChangedRows(dataBook.dataProvider);
          if (changedRows.isNotEmpty) {
            if (changedRows.containsKey(OfflineDatabase.ROW_STATE_INSERTED)) {
              sortedListInserts.add(dataBook);
              insertsByDataBook[dataBook.dataProvider] = changedRows[OfflineDatabase.ROW_STATE_INSERTED]!;
            }
            if (changedRows.containsKey(OfflineDatabase.ROW_STATE_UPDATED)) {
              sortedListUpdates.add(dataBook);
              updatesByDataBook[dataBook.dataProvider] = changedRows[OfflineDatabase.ROW_STATE_UPDATED]!;
            }
            if (changedRows.containsKey(OfflineDatabase.ROW_STATE_DELETED)) {
              sortedListDeletes.add(dataBook);
              deletesByDataBook[dataBook.dataProvider] = changedRows[OfflineDatabase.ROW_STATE_DELETED]!;
            }
          }
        }

        // Reverse the list of deletes, so that we delete the child records first
        sortedListDeletes = sortedListDeletes.reversed.toList();

        int dataBookCounter = 1;
        for (DataBook dataBook in sortedListInserts) {
          failedStep = "${FlutterUI.translate("Insertion of")} ${dataBook.dataProvider}";
          FlutterUI.logAPI.i("Inserting: ${dataBook.dataProvider} | ${dataBook.records.length}");

          List<Map<String, Object?>> rowsToInsert = insertsByDataBook[dataBook.dataProvider]!;

          dialogKey.currentState?.update(Config(
            message:
                "${FlutterUI.translate("Inserting rows")} ($dataBookCounter / ${sortedListInserts.length} ${FlutterUI.translate("Tables")})",
            progress: 0,
            maxProgress: rowsToInsert.length,
          ));

          int localCounter = 1;
          for (var insertedRow in rowsToInsert) {
            if (await _handleInsertedRow(offlineApiRepository, insertedRow, dataBook)) {
              successfulSyncedRows++;
            } else {
              failedSyncedRows++;
            }
            dialogKey.currentState?.update(Config(
              progress: localCounter,
            ));
            localCounter++;
          }

          dataBookCounter++;
        }

        dataBookCounter = 1;
        for (DataBook dataBook in sortedListUpdates) {
          failedStep = "${FlutterUI.translate("Updating of")} ${dataBook.dataProvider}";
          FlutterUI.logAPI.i("Updating: ${dataBook.dataProvider} | ${dataBook.records.length}");

          List<Map<String, Object?>> rowsToUpdate = updatesByDataBook[dataBook.dataProvider]!;

          dialogKey.currentState?.update(Config(
            message:
                "${FlutterUI.translate("Updating rows")} ($dataBookCounter / ${sortedListUpdates.length} ${FlutterUI.translate("Tables")})",
            progress: 0,
            maxProgress: rowsToUpdate.length,
          ));

          int localCounter = 1;
          for (var insertedRow in rowsToUpdate) {
            if (await _handleUpdatedRow(offlineApiRepository, insertedRow, dataBook)) {
              successfulSyncedRows++;
            } else {
              failedSyncedRows++;
            }
            dialogKey.currentState?.update(Config(
              progress: localCounter,
            ));
            localCounter++;
          }

          dataBookCounter++;
        }

        dataBookCounter = 1;
        for (DataBook dataBook in sortedListDeletes) {
          failedStep = "${FlutterUI.translate("Deletion of")} ${dataBook.dataProvider}";
          FlutterUI.logAPI.i("Deleting: ${dataBook.dataProvider} | ${dataBook.records.length}");

          List<Map<String, Object?>> rowsToDelete = deletesByDataBook[dataBook.dataProvider]!;

          dialogKey.currentState?.update(Config(
            message:
                "${FlutterUI.translate("Deleting rows")} ($dataBookCounter / ${sortedListDeletes.length} ${FlutterUI.translate("Tables")}",
            progress: 0,
            maxProgress: rowsToDelete.length,
          ));

          int localCounter = 1;
          for (var deletedRow in rowsToDelete) {
            if (await _handleDeletedRow(offlineApiRepository, deletedRow, dataBook)) {
              successfulSyncedRows++;
            } else {
              failedSyncedRows++;
            }
            dialogKey.currentState?.update(Config(
              progress: localCounter,
            ));
            localCounter++;
          }

          dataBookCounter++;
        }
      }

      bool successfulSync = failedSyncedRows == 0;

      FlutterUI.logAPI.i(
          "Sync ${successfulSync ? "successful" : "failed"}: Synced $successfulSyncedRows rows, $failedSyncedRows rows failed");

      failedStep =
          "${FlutterUI.translate(successfulSync ? "Success" : "Failure")} - ${FlutterUI.translate("Synced")} $successfulSyncedRows/$failedSyncedRows";

      if (successfulSync) {
        failedStep = "Closing sync connection to server";
        FlPanelModel? workscreenModel =
            IStorageService().getComponentByScreenClassName(pScreenClassName: offlineWorkscreenClassName)!;
        await ICommandService().sendCommand(CloseScreenCommand(
          screenName: workscreenModel.name,
          reason: "We have synced",
        ));

        failedStep = "Connecting to server for user interaction";
        await ICommandService().sendCommand(
          StartupCommand(
            reason: "Going online",
            username: offlineUsername,
            password: offlinePassword,
          ),
        );

        failedStep = "Resetting offline state";
        IDataService().clearDataBooks();
        await offlineApiRepository.deleteDatabase();
        await offlineApiRepository.stop();

        await IConfigService().updatePassword(null);
        await IConfigService().updateOffline(false);
      } else {
        failedStep = "Returning to offline state";
        await onlineApiRepository.stop();
        IApiService().setRepository(offlineApiRepository);
      }

      String sMessage;
      if (successfulSyncedRows > 0 || failedSyncedRows > 0) {
        sMessage = "${FlutterUI.translate("Successfully synced")} $successfulSyncedRows ${FlutterUI.translate("rows")}"
            "${failedSyncedRows > 0 ? ".\n$failedSyncedRows ${FlutterUI.translate("rows failed to sync")}." : ""}";
      } else {
        sMessage = FlutterUI.translate(!pDiscardChanges ? "No changes detected" : "No rows synced");
      }

      dialogKey.currentState!.update(Config(
        message: sMessage,
        progress: 100,
        maxProgress: 100,
        contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogKey.currentContext!).pop(),
            child: Text(FlutterUI.translate("OK")),
          ),
        ],
      ));
      await futureDialog;
    } catch (e, stack) {
      FlutterUI.logAPI.e("Error while switching to online", e, stack);

      // Revert all changes in case we have an in-tact offline state
      await onlineApiRepository.stop();
      IApiService().setRepository(offlineApiRepository);
      IUiService().setMenuModel(null);
      IStorageService().deleteScreen(screenName: offlineWorkscreenClassName);

      ProgressDialogWidget.safeClose(dialogKey);
      DialogResult? result = await IUiService().openDialog(
        pIsDismissible: false,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterUI.translate("Offline Sync Error")),
          content: Text(
              "${FlutterUI.translate("There was a problem while switching from offline to online mode. Data remains untouched."
                  "\nPlease check your connection and try again!")}"
              "\n\n${FlutterUI.translate("Failed step")}: ${FlutterUI.translate(failedStep)}."
              "\n${FlutterUI.translate("Error")}: ${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(DialogResult.RETRY);
              },
              child: Text(FlutterUI.translate("Retry")),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterUI.translate("OK")),
            ),
          ],
        ),
      );
      if (result == DialogResult.RETRY) {
        await initOnline();
      }
    } finally {
      await Wakelock.disable();
      // In case it hasn't been closed yet
      ProgressDialogWidget.safeClose(dialogKey);
    }
  }

  static Future<bool> _handleInsertedRow(
      OfflineApiRepository offlineApiRepository, Map<String, Object?> insertedRow, DataBook dataBook) async {
    try {
      await _insertOfflineRecord(dataBook, insertedRow);
      await offlineApiRepository.resetState(dataBook.dataProvider, insertedRow);
    } catch (e, stack) {
      FlutterUI.logAPI.e("Error while syncing inserted row: $insertedRow", e, stack);
      return false;
    }
    return true;
  }

  static Future<bool> _handleUpdatedRow(
      OfflineApiRepository offlineApiRepository, Map<String, Object?> updatedRow, DataBook dataBook) async {
    try {
      await _updateOfflineRecord(updatedRow, dataBook);
      await offlineApiRepository.resetState(dataBook.dataProvider, updatedRow);
    } catch (e, stack) {
      FlutterUI.logAPI.e("Error while syncing updated row: $updatedRow", e, stack);
      return false;
    }
    return true;
  }

  static Future<bool> _handleDeletedRow(
      OfflineApiRepository offlineApiRepository, Map<String, Object?> deletedRow, DataBook dataBook) async {
    try {
      await _deleteOfflineRecord(dataBook, deletedRow);
      await offlineApiRepository.resetState(dataBook.dataProvider, deletedRow);
    } catch (e, stack) {
      FlutterUI.logAPI.e("Error while syncing updated row: $deletedRow", e, stack);
      return false;
    }
    return true;
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
      dataProvider: dataBook.dataProvider,
      columnNames: newColumns.keys.toList(growable: false),
      values: newColumns.values.toList(growable: false),
    ));
  }

  static Future<void> _updateOfflineRecord(Map<String, Object?> row, DataBook dataBook) {
    var newColumns = {
      for (var entry in row.entries.where((rowColumn) =>
          !(rowColumn.key.startsWith(OfflineDatabase.COLUMN_PREFIX) || rowColumn.key == OfflineDatabase.STATE_COLUMN)))
        entry.key: entry.value
    };

    var primaryColumns = _getPrimaryColumns(row, dataBook);

    return ICommandService().sendCommand(SetValuesCommand(
      reason: "Re-sync: Update",
      dataProvider: dataBook.dataProvider,
      columnNames: newColumns.keys.toList(growable: false),
      values: newColumns.values.toList(growable: false),
      filter: Filter(
        columnNames: primaryColumns.keys.toList(growable: false),
        values: primaryColumns.values.toList(growable: false),
      ),
    ));
  }

  static Future<void> _deleteOfflineRecord(DataBook dataBook, Map<String, Object?> deletedRow) {
    var primaryColumns = _getPrimaryColumns(deletedRow, dataBook);
    return ICommandService().sendCommand(DeleteRecordCommand(
      reason: "Re-sync: Delete",
      dataProvider: dataBook.dataProvider,
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

  static Future<void> initOffline(String pScreenName) async {
    var dialogKey = GlobalKey<ProgressDialogState>();
    OnlineApiRepository onlineApiRepository = IApiService().getRepository() as OnlineApiRepository;
    OfflineApiRepository offlineApiRepository = OfflineApiRepository();

    try {
      await Wakelock.enable();
      // Set already here to receive errors from api responses
      await IConfigService().updateOffline(true);
      // Save password for re-sync
      await IConfigService().updatePassword(FlutterUI.of(FlutterUI.getCurrentContext()!).lastPassword);

      var panelModel = IStorageService().getComponentByName(pComponentName: pScreenName) as FlPanelModel;

      await IConfigService().updateOfflineScreen(panelModel.screenClassName!);

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
          dialogKey.currentState?.update(Config(
            progress: value,
            maxProgress: max,
          ));
        },
      );

      dialogKey.currentState?.update(Config(
        message: FlutterUI.translate("Processing data"),
        progress: 0,
        maxProgress: 100,
      ));

      await offlineApiRepository.start();

      var dataBooks = IDataService()
          .getDataBooks()
          .values
          .where((element) => activeDataProviders.contains(element.dataProvider))
          .toList(growable: false);
      await offlineApiRepository.initDatabase(
        dataBooks,
        (value, max, {progress}) {
          dialogKey.currentState?.update(Config(
            message: "${FlutterUI.translate("Processing Tables")} ($value / $max)",
            progress: progress ?? 0,
          ));
        },
      );

      // Close and delete screen
      await ICommandService().sendCommand(CloseScreenCommand(
        screenName: panelModel.name,
        reason: "We have fetched",
      ));
      await ICommandService().sendCommand(ExitCommand(reason: "Going offline"));

      // Clear screen storage
      IStorageService().clear(true);

      // Clear databooks for offline usage
      IDataService().clearDataBooks();
      await offlineApiRepository.initDataBooks();
      IApiService().setRepository(offlineApiRepository);

      // Clear menu
      IUiService().setMenuModel(null);
      IUiService().routeToMenu(pReplaceRoute: true);

      await onlineApiRepository.stop();
    } catch (e, stack) {
      FlutterUI.logAPI.e("Error while downloading offline data", e, stack);

      // Revert all changes
      if (!offlineApiRepository.isStopped()) {
        await offlineApiRepository.deleteDatabase();
      }

      await offlineApiRepository.stop();
      await IConfigService().updateOffline(false);
      IApiService().setRepository(onlineApiRepository);

      ProgressDialogWidget.safeClose(dialogKey);
      await IUiService().openDialog(
        pIsDismissible: false,
        pBuilder: (context) => AlertDialog(
          title: Text(FlutterUI.translate("Offline Init Error")),
          content:
              Text("${FlutterUI.translate("There was a problem while trying to download data.")}\n${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(FlutterUI.translate("OK")),
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
}
