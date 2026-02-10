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
import 'package:wakelock_plus/wakelock_plus.dart';

import '../flutter_ui.dart';
import '../mask/error/error_dialog.dart';
import '../mask/error/server_error_dialog.dart';
import '../mask/jvx_dialog.dart';
import '../mask/jvx_overlay.dart';
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
import '../model/request/api_exit_request.dart';
import '../model/request/filter.dart';
import '../service/api/i_api_service.dart';
import '../service/api/shared/repository/offline/offline_database.dart';
import '../service/api/shared/repository/offline_api_repository.dart';
import '../service/api/shared/repository/online_api_repository.dart';
import '../service/command/i_command_service.dart';
import '../service/config/i_config_service.dart';
import '../service/config/shared/config_handler.dart';
import '../service/data/i_data_service.dart';
import '../service/layout/i_layout_service.dart';
import '../service/service.dart';
import '../service/storage/i_storage_service.dart';
import '../service/ui/i_ui_service.dart';
import 'jvx_logger.dart';
import 'misc/dialog_result.dart';
import 'widgets/progress/progress_dialog_service.dart';
import 'widgets/progress/progress_dialog_widget.dart';

abstract class OfflineUtil {

  /// offline background color
  static Color backgroundColor = Colors.grey.shade500;

  /// whether initOffline is running
  static bool isGoingOffline = false;

  /// whether initOnline is running
  static bool isGoingOnline = false;

  static Widget getOfflineBar(BuildContext context, {bool useElevation = false}) {
    return Material(
      color: backgroundColor,
      elevation: useElevation ? Theme.of(context).appBarTheme.elevation ?? 4.0 : 0.0,
      child: Container(
        height: 20,
        alignment: Alignment.center,
        child: Text(
          "OFFLINE",
          style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white)
        ),
      ),
    );
  }

  static Future<void> initOnline([bool pDiscardChanges = false]) async {
    isGoingOnline = true;

    bool? oldLoadingEnabled;

    try {
      OnlineApiRepository onlineApiRepository = OnlineApiRepository();
      OfflineApiRepository offlineApiRepository = IApiService().getRepository() as OfflineApiRepository;

      IConfigService servCfg = IConfigService();

      String failedStep = "Initializing";
      String offlineWorkScreenClassName = servCfg.offlineScreen.value!;

      IUiService servUi = IUiService();
      IApiService servApi = IApiService();

      try {
        await WakelockPlus.enable();

        ConfigHandler cfgHandler = servCfg.getConfigHandler();

        String? appId = await cfgHandler.currentApp();

        if (appId == null) {
          throw "Application missing";
        }

        // Save credentials for re-sync (appId is important otherwise values would be global)
        String? offlineUsername = await cfgHandler.getValueSecure("$appId.offlineUserName");
        String? offlinePassword = await cfgHandler.getValueSecure("$appId.offlinePassword");

        ProgressDialogService.show(Config(
          message: FlutterUI.translate(pDiscardChanges ? "Discarding changes" : "Synchronizing data"),
          barrierDismissible: false,
        ));

        JVxOverlayState? ols = JVxOverlay.maybeOf(FlutterUI.getCurrentContext());

        oldLoadingEnabled = ols?.isLoadingEnabled();
        ols?.setLoadingEnabled(false);

        // Set online api repository to handle commands
        await onlineApiRepository.start();
        servApi.setRepository(onlineApiRepository);

        String? sLastMessage;

        bool startUpForUserInteraction = false;

        if (!pDiscardChanges) {
          if ((offlineUsername == null || offlinePassword == null) && servCfg.authKey.value == null) {
            throw "Switching to online mode not possible because of missing credentials!";
          }

          int successfulSyncedRows = 0;
          int failedSyncedRows = 0;

          ICommandService servCmd = ICommandService();

          failedStep = "Connecting to server";
          await servCmd.sendCommand(
            StartupCommand(
              reason: "Going online, for sync",
              username: offlineUsername,
              password: offlinePassword,
            ),
          );

          if (servUi.clientId.value == null) {
            throw "ClientID is missing";
          }

          failedStep = "Preparing synchronization";
          await servCmd.sendCommand(
            OpenScreenCommand(
              className: offlineWorkScreenClassName,
              reason: "We are back online, for sync",
              parameter: {"mobile.onlineSync": true},
            ),
          );

          if (!servUi.loggedIn()) {
            throw "Not authenticated!";
          }

          // To keep foreign key relations intact. First execute inserts, then updates.
          // Deletes should be executed when traversing the list in reverse
          var dataBooks = IDataService().getDataBooks();

          // Sort data books by level of how many master references they have in the list of data books
          Map<int, List<DataBook>> dataBooksByLevel = {};
          for (DataBook dataBook in dataBooks.values) {
            int iLevel = 0;

            for (String? masterDataBook = dataBook.metaData?.masterReference?.referencedDataBook;
            masterDataBook != null;
            masterDataBook = dataBooks[masterDataBook]?.metaData?.masterReference?.referencedDataBook) {
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
          // The first key is the data book
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

            ProgressDialogService.update(Config(
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
              ProgressDialogService.update(Config(
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

            ProgressDialogService.update(Config(
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
              ProgressDialogService.update(Config(
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

            ProgressDialogService.update(Config(
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
              ProgressDialogService.update(Config(
                progress: localCounter,
              ));
              localCounter++;
            }

            dataBookCounter++;
          }

          bool successfulSync = failedSyncedRows == 0;

          FlutterUI.logAPI.i("Sync ${successfulSync ? "successful" : "failed"}: Synced $successfulSyncedRows rows, $failedSyncedRows rows failed");

          if (successfulSync) {
            failedStep = "Closing sync connection";
            FlPanelModel? workScreenModel = IStorageService().getComponentByScreenClassName(pScreenClassName: offlineWorkScreenClassName);

            if (workScreenModel != null) {
              await servCmd.sendCommand(CloseScreenCommand(
                componentName: workScreenModel.name,
                reason: "We have finished synchronizing the data",
              ));
            }

            unawaited(_exitApp(onlineApiRepository));

            startUpForUserInteraction = true;
          } else {
            //Not successful means that the user should get the chance to change records again in offline mode before going online

            failedStep = "Returning to offline state";

            unawaited(_exitApp(onlineApiRepository));

            await onlineApiRepository.stop();
            servApi.setRepository(offlineApiRepository);
          }

          if (successfulSyncedRows > 0 || failedSyncedRows > 0) {
            sLastMessage = "${FlutterUI.translate("Successfully synced")} $successfulSyncedRows ${FlutterUI.translate("rows")}"
                "${failedSyncedRows > 0 ? ".\n$failedSyncedRows ${FlutterUI.translate("rows failed to sync")}." : ""}";
          } else {
            sLastMessage = FlutterUI.translate("No changes detected");
          }
        }
        else {
          startUpForUserInteraction = true;
          sLastMessage = FlutterUI.translate("Successfully discarded");
        }

        // Clear caches (if online sync fails and we try to discard changes in next step
        // -> sync screen is still in memory on client-sied
        IStorageService().clear(ClearReason.DEFAULT);
        IDataService().clearDataBooks();
        ILayoutService().clear(ClearReason.DEFAULT);

        if (startUpForUserInteraction) {
          failedStep = "Resetting offline state";
          await offlineApiRepository.deleteDatabase();
          await offlineApiRepository.stop();

          await servCfg.updatePassword(null);
          await servCfg.updateOffline(false);

          isGoingOnline = false;

          failedStep = "Connecting to server for user interaction";

          await ICommandService().sendCommand(
            StartupCommand(
              reason: "Going online",
              username: offlineUsername,
              password: offlinePassword,
            ),
          );

          //successful started application
          if (servUi.clientId.value != null) {
            await cfgHandler.setValueSecure("$appId.offlineUserName", null);
            await cfgHandler.setValueSecure("$appId.offlinePassword", null);
          }
          else {
            throw "Client ID missing";
          }
        }

        failedStep = "Update dialog";

        ProgressDialogService.update(Config(
          message: sLastMessage,
          progress: 100,
          maxProgress: 100,
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          actions: [
            TextButton(
              onPressed: () async => await ProgressDialogService.hide(),
              child: Text(FlutterUI.translate("OK")),
            ),
          ],
        ));

        //before setting menu -> updates menu page
        isGoingOnline = false;

        servUi.setMenuModel(servUi.getMenuModel());
      } catch (e, stack) {
        FlutterUI.logAPI.e("Error while switching to online", error: e, stackTrace: stack);

        String sIntro;

        if (isGoingOnline) {
          unawaited(_exitApp(onlineApiRepository));

          // Revert all changes in case we have an in-tact offline state
          await onlineApiRepository.stop();
          servApi.setRepository(offlineApiRepository);

          sIntro = "There was a problem while switching from offline to online mode.";
        }
        else {
          sIntro = "There was a problem while switching from offline to online mode. Data remains untouched."
                   "\nPlease check your connection and try again!";
        }

        isGoingOnline = false;

        servUi.setMenuModel(null);
        IStorageService().deleteScreen(screenName: offlineWorkScreenClassName);

        await ProgressDialogService.hide();

        DialogResult? result = await servUi.openDialog(
          pIsDismissible: false,
          pBuilder: (context) =>
              AlertDialog(
                title: Text(FlutterUI.translate("Offline Sync Error")),
                content: Text(
                    "${FlutterUI.translate(sIntro)}"
                        "\n\n${FlutterUI.translate("Failed step")}: ${FlutterUI.translate(failedStep)}."
                        "\n\n${FlutterUI.translate("Error")}: ${e.toString()}"),
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
        await WakelockPlus.disable();
      }
    } finally {
      isGoingOnline = false;

      if (oldLoadingEnabled != null) {
        JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.setLoadingEnabled(oldLoadingEnabled);
      }
    }
  }

  static Future<bool> _handleInsertedRow(
      OfflineApiRepository offlineApiRepository, Map<String, Object?> insertedRow, DataBook dataBook) async {
    try {
      await _insertOfflineRecord(dataBook, insertedRow);

      _checkErrorDialog();

      await offlineApiRepository.resetState(dataBook.dataProvider, insertedRow);
    } catch (e, stack) {
      if (FlutterUI.logAPI.cl(Lvl.e)) {
        FlutterUI.logAPI.e("Error while syncing inserted row: $insertedRow", error: e, stackTrace: stack);
      }
      return false;
    }
    return true;
  }

  static Future<bool> _handleUpdatedRow(
      OfflineApiRepository offlineApiRepository, Map<String, Object?> updatedRow, DataBook dataBook) async {
    try {
      await _updateOfflineRecord(updatedRow, dataBook);

      _checkErrorDialog();

      await offlineApiRepository.resetState(dataBook.dataProvider, updatedRow);
    } catch (e, stack) {
      if (FlutterUI.logAPI.cl(Lvl.e)) {
        FlutterUI.logAPI.e("Error while syncing updated row: $updatedRow", error: e, stackTrace: stack);
      }
      return false;
    }
    return true;
  }

  static Future<bool> _handleDeletedRow(
      OfflineApiRepository offlineApiRepository, Map<String, Object?> deletedRow, DataBook dataBook) async {
    try {
      await _deleteOfflineRecord(dataBook, deletedRow);

      _checkErrorDialog();

      await offlineApiRepository.resetState(dataBook.dataProvider, deletedRow);
    } catch (e, stack) {
      if (FlutterUI.logAPI.cl(Lvl.e)) {
        if (FlutterUI.logAPI.cl(Lvl.e)) {
          FlutterUI.logAPI.e("Error while syncing updated row: $deletedRow", error: e, stackTrace: stack);
        }
      }

      return false;
    }
    return true;
  }

  /// Checks if there's an error view
  static void _checkErrorDialog() {
    IUiService serv = IUiService();
    List<JVxDialog> dialogs = serv.getJVxDialogs();

    String? errorMessage;

    for (JVxDialog dialog in dialogs) {
      if (dialog is ErrorDialog) {
        errorMessage = dialog.message;

        serv.closeJVxDialog(dialog);
      }
      else if (dialog is ServerErrorDialog) {
        errorMessage = dialog.command.message;

        serv.closeJVxDialog(dialog);
      }
    }

    if (errorMessage != null) {
      throw errorMessage;
    }
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

    await ICommandService().sendCommand(SetValuesCommand(
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
          (rowColumn) => dataBook.metaData!.primaryKeyColumns.any((primaryColumn) => primaryColumn == rowColumn.key)))
        entry.key: entry.value
    };
    return primaryColumns;
  }

  static Set<String> getActiveDataProviders(String offlineWorkScreen) {
    // String dataBookPrefix = ConfigController.appName + "/" + pWorkScreen;
    return IDataService().getDataBooks().keys.toList().where((element) {
      var prefixes = element.split("/");
      if (prefixes.length >= 2) {
        return prefixes[1] == offlineWorkScreen;
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
          offline: true
        ),
      );
    }

    FlutterUI.logAPI.i("Finished fetching data");
  }

  static Future<void> initOffline(String pScreenName) async {
    isGoingOffline = true;

    IApiService servApi = IApiService();
    IConfigService servCfg = IConfigService();

    bool? oldLoadingEnabled;

    try {
      OnlineApiRepository onlineApiRepository = servApi.getRepository() as OnlineApiRepository;
      OfflineApiRepository offlineApiRepository = OfflineApiRepository();

      try {
        await WakelockPlus.enable();
        // Set already here to receive errors from api responses
        await servCfg.updateOffline(true);

        ConfigHandler cfgHandler = servCfg.getConfigHandler();

        String? appId = await cfgHandler.currentApp();

        if (appId == null) {
          throw "Application missing";
        }

        // Save credentials for re-sync (appId is important otherwise values would be global)
        await cfgHandler.setValueSecure("$appId.offlineUserName", servCfg.username.value);
        await cfgHandler.setValueSecure("$appId.offlinePassword", FlutterUI.of(FlutterUI.getCurrentContext()!).lastPassword);

        IStorageService servStorage = IStorageService();

        var panelModel = servStorage.getComponentByName(pComponentName: pScreenName) as FlPanelModel;

        await servCfg.updateOfflineScreen(panelModel.screenClassName!);

        IUiService servUi = IUiService();

        ProgressDialogService.show(Config(
            message: FlutterUI.translate("Fetching offline data"),
            barrierDismissible: false,
          ),
        );

        JVxOverlayState? ols = JVxOverlay.maybeOf(FlutterUI.getCurrentContext());

        oldLoadingEnabled = ols?.isLoadingEnabled();
        ols?.setLoadingEnabled(false);

        Set<String> activeDataProviders = getActiveDataProviders(pScreenName);
        await fetchDataProvider(
          activeDataProviders,
          progressUpdate: (value, max) {
            ProgressDialogService.update(Config(
              progress: value,
              maxProgress: max,
            ));
          },
        );

        ProgressDialogService.update(Config(
          message: FlutterUI.translate("Processing data"),
          progress: 0,
          maxProgress: 100,
        ));

        await offlineApiRepository.start();

        IDataService servData = IDataService();

        var dataBooks = servData
            .getDataBooks()
            .values
            .where((element) => activeDataProviders.contains(element.dataProvider))
            .toList(growable: false);
        await offlineApiRepository.initDatabase(
          dataBooks,
              (value, max, {progress}) {
                ProgressDialogService.update(Config(
              message: "${FlutterUI.translate("Processing Tables")} ($value / $max)",
              progress: progress ?? 0,
            ));
          },
        );

        await ProgressDialogService.hide();

        ICommandService servCmd = ICommandService();

        // Close and delete screen
        await servCmd.sendCommand(CloseScreenCommand(
          componentName: panelModel.name,
          reason: "We have fetched",
        ));
        await servCmd.sendCommand(ExitCommand(reason: "Going offline"));

        // Clear caches
        servStorage.clear(ClearReason.DEFAULT);
        servData.clearDataBooks();

        await onlineApiRepository.stop();

        await offlineApiRepository.initDataBooks();
        servApi.setRepository(offlineApiRepository);

        //before setting menu -> updates menu page
        isGoingOffline = false;

        // Triggers building menu
        servUi.setMenuModel(null);
        servUi.routeToMenu(pReplaceRoute: true);
      }
      catch (e, stack) {
        FlutterUI.logAPI.e("Error while going offline", error: e, stackTrace: stack);

        // Revert all changes
        if (!offlineApiRepository.isStopped()) {
          await offlineApiRepository.deleteDatabase();
        }

        await offlineApiRepository.stop();
        await servCfg.updateOffline(false);

        if (onlineApiRepository.isStopped()) {
          await onlineApiRepository.start();
        }

        servApi.setRepository(onlineApiRepository);

        await ProgressDialogService.hide();

        await IUiService().openDialog(
          pIsDismissible: false,
          pBuilder: (context) =>
              AlertDialog(
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
        await WakelockPlus.disable();
      }
    } finally {
      isGoingOffline = false;

      if (oldLoadingEnabled != null) {
        JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.setLoadingEnabled(oldLoadingEnabled);
      }
    }
  }

  static Future<void> _exitApp(OnlineApiRepository repository) async
  {
    String? id = IUiService().clientId.value;

    if (id != null) {
      //We have to set the clientId here because we clear it before sending the request
      ApiExitRequest exit = ApiExitRequest();
      exit.clientId = id;

      IUiService().updateClientId(null);

      unawaited(repository.sendRequestAndForget(exit)
        .catchError((e, stack) => FlutterUI.log.e("Exit request failed", error: e, stackTrace: stack)));
    }
  }

}
