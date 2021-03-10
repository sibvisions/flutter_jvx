import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../../../injection_container.dart';
import '../../../models/api/request.dart';
import '../../../models/api/request/application_style.dart';
import '../../../models/api/request/close_screen.dart';
import '../../../models/api/request/data/fetch_data.dart';
import '../../../models/api/request/data/filter_data.dart';
import '../../../models/api/request/data/insert_record.dart';
import '../../../models/api/request/data/meta_data.dart' as DAL;
import '../../../models/api/request/data/select_record.dart';
import '../../../models/api/request/data/set_values.dart';
import '../../../models/api/request/logout.dart';
import '../../../models/api/request/navigation.dart';
import '../../../models/api/request/open_screen.dart';
import '../../../models/api/request/startup.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/data/data_book.dart';
import '../../../models/api/response/data/filter.dart';
import '../../../models/api/response/data/filter_condition.dart';
import '../../../models/api/response/error_response.dart';
import '../../../models/api/response/meta_data/data_book_meta_data.dart';
import '../../../models/api/response/response_data.dart';
import '../../../models/api/so_action.dart';
import '../../../models/app/app_state.dart';
import '../../../ui/screen/so_component_data.dart';
import '../../../ui/screen/so_screen.dart';
import '../../../utils/network/network_info.dart';
import '../../../utils/translation/app_localizations.dart';
import '../../remote/bloc/api_bloc.dart';
import '../../remote/rest/rest_client.dart';
import '../shared_preferences_manager.dart';
import 'i_offline_database_provider.dart';
import 'local_database.dart';
import 'offline_database_formatter.dart';

typedef ProgressCallback = Function(double);

class OfflineDatabase extends LocalDatabase
    implements IOfflineDatabaseProvider {
  double progress = 0.0;
  int rowsToImport = 0;
  int rowsImported = 0;
  int fetchOfflineRecordsPerRequest = 100;
  Response responseError;
  Filter _lastFetchFilter;
  FilterCondition _lastFetchFilterCondition;
  List<ProgressCallback> _progressCallbacks = <ProgressCallback>[];

  Future<void> openCreateDatabase(String path) async {
    await super.openCreateDatabase(path);
    if (db?.isOpen ?? false) {
      String columnStr =
          "$OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER TEXT$CREATE_TABLE_COLUMNS_SEPERATOR" +
              "$OFFLINE_META_DATA_TABLE_COLUMN_TABLE_NAME TEXT$CREATE_TABLE_COLUMNS_SEPERATOR" +
              "$OFFLINE_META_DATA_TABLE_COLUMN_SCREEN_COMPONENT_ID TEXT$CREATE_TABLE_COLUMNS_SEPERATOR" +
              "$OFFLINE_META_DATA_TABLE_COLUMN_DATA TEXT";
      await this.createTable(OFFLINE_META_DATA_TABLE, columnStr);
    }
  }

  Future<bool> syncOnline(BuildContext context) async {
    bool result = false;
    int rowsToSync = 0;
    int rowsSynced = 0;
    responseError = null;
    ApiBloc bloc = new ApiBloc(null, sl<NetworkInfo>(), sl<RestClient>(),
        sl<AppState>(), sl<SharedPreferencesManager>(), null);

    String authUsername = bloc.manager.authKey == null
        ? bloc?.manager?.syncLoginData['username']
        : bloc.appState.username;
    String authPassword = bloc.manager.authKey == null
        ? bloc?.manager?.syncLoginData['password']
        : bloc.appState.password;
    String authKey = bloc.manager.authKey;

    if (authKey != null || (authUsername != null && authPassword != null)) {
      Startup startup = Startup(
          url: bloc.appState.baseUrl,
          applicationName: bloc.appState.appName,
          screenHeight: MediaQuery.of(context).size.height.toInt(),
          screenWidth: MediaQuery.of(context).size.width.toInt(),
          appMode:
              bloc.appState.appMode != null && bloc.appState.appMode.isNotEmpty
                  ? bloc.appState.appMode
                  : 'preview',
          readAheadLimit: bloc.appState.readAheadLimit,
          requestType: RequestType.STARTUP,
          deviceId: bloc.manager.deviceId,
          userName: authUsername,
          password: authPassword,
          authKey: authKey,
          layoutMode: 'generic',
          language: bloc.appState.language,
          forceNewSession: true);

      // startup request
      await for (Response response in bloc.startup(startup)) {
        if (response != null && !hasError(response)) {
          this.setProperties(bloc, response);

          ApplicationStyle applicationStyle = ApplicationStyle(
              clientId: bloc.appState.clientId,
              requestType: RequestType.APP_STYLE,
              name: 'applicationStyle',
              contentMode: 'json');

          // application style request
          await for (Response response
              in bloc.applicationStyle(applicationStyle)) {
            if (response != null && !hasError(response)) {
              this.setProperties(bloc, response);
              String currentScreenComponentId = "";

              List<String> syncDataProvider =
                  await this.getOfflineDataProvider();
              Map<String, List<Map<String, dynamic>>> syncData =
                  Map<String, List<Map<String, dynamic>>>();

              // get sync data
              await Future.forEach(syncDataProvider, (dataProvider) async {
                if (dataProvider != null) {
                  syncData[dataProvider] = await this.getSyncData(dataProvider);

                  if (syncData[dataProvider] != null)
                    rowsToSync += syncData[dataProvider].length;
                }
              });

              // sync data to server
              await Future.forEach(syncData.entries, (entry) async {
                if (entry.value.length > 0) {
                  DataBookMetaData metaData = await getMetaDataBook(entry.key);

                  // open close screen
                  if (metaData.offlineScreenComponentId !=
                      currentScreenComponentId) {
                    if (currentScreenComponentId.length > 0) {
                      CloseScreen closeScreen = CloseScreen(
                          componentId: currentScreenComponentId,
                          clientId: bloc.appState.clientId,
                          requestType: RequestType.CLOSE_SCREEN);

                      await for (Response response
                          in bloc.closeScreen(closeScreen)) {
                        if (response != null && !hasError(response)) {
                          currentScreenComponentId = "";
                        }
                      }
                    }

                    SoAction action = SoAction(
                        componentId: metaData.offlineScreenComponentId,
                        label: "SyncOffline");
                    OpenScreen openScreen = OpenScreen(
                        action: action,
                        clientId: bloc.appState.clientId,
                        manualClose: false,
                        requestType: RequestType.OPEN_SCREEN);
                    await for (Response response
                        in bloc.openScreen(openScreen)) {
                      if (response != null && !hasError(response)) {
                        currentScreenComponentId =
                            metaData.offlineScreenComponentId;
                      }
                    }
                  }

                  // sync insert, update, delete to server
                  await Future.forEach(entry.value, (element) async {
                    String state =
                        OfflineDatabaseFormatter.getRowState(element);
                    Map<String, dynamic> primaryKeyValues =
                        OfflineDatabaseFormatter.getDataColumns(
                            element, metaData.primaryKeyColumns);
                    Filter primaryKeyFilter = Filter(
                        columnNames: primaryKeyValues.keys.toList(),
                        values: primaryKeyValues.values.toList());
                    if (state == OFFLINE_ROW_STATE_DELETED) {
                      if (await this.syncDelete(
                          context,
                          entry.key,
                          primaryKeyFilter,
                          metaData.columnNames,
                          element)) rowsSynced++;
                    } else if (state == OFFLINE_ROW_STATE_INSERTED) {
                      if (await this.syncInsert(context, entry.key,
                          primaryKeyFilter, metaData.columnNames, element)) {
                        rowsSynced++;
                      }
                    } else if (state == OFFLINE_ROW_STATE_UPDATED) {
                      if (await this.syncUpdate(context, entry.key,
                          primaryKeyFilter, metaData.columnNames, element)) {
                        rowsSynced++;
                      }
                    }
                    setRowProgress(rowsToSync, rowsSynced);
                  });
                }
              });

              // close screen if an screen is open
              if (currentScreenComponentId.length > 0) {
                CloseScreen closeScreen = CloseScreen(
                    componentId: currentScreenComponentId,
                    clientId: bloc.appState.clientId,
                    requestType: RequestType.CLOSE_SCREEN);

                await for (Response response in bloc.closeScreen(closeScreen)) {
                  if (response != null && !hasError(response)) {
                    currentScreenComponentId = "";
                  }
                }
              }

              if (rowsSynced == rowsToSync) result = true;
            }
          }
        }
      }

      bloc.close();
    } else {
      responseError = Response();
      responseError.error = ErrorResponse(
          AppLocalizations.of(context).text('Online Sync Fehler'),
          '',
          AppLocalizations.of(context)
              .text('Authentifizierung fehlgeschlagen.'),
          'offline.error');
    }

    if (result)
      log("Online sync finished successfully! Synced records: $rowsSynced/$rowsToSync");
    else
      log("Online sync finished with error! Synced records: $rowsSynced/$rowsToSync ErrorDetail: ${responseError?.error?.details}");

    // set general error
    if (!result && responseError == null) {
      responseError = Response();
      responseError.error = ErrorResponse(
          AppLocalizations.of(context).text('Online Sync Fehler'),
          '',
          AppLocalizations.of(context).text(
              'Leider ist ein Fehler beim synchronisieren der Daten aufgetreten.'),
          'offline.error');
    }

    return result;
  }

  Future<bool> importComponents(
      BuildContext context, List<SoComponentData> componentData) async {
    rowsToImport = 0;
    rowsImported = 0;
    responseError = null;
    bool result = true;
    ApiBloc bloc = new ApiBloc(null, sl<NetworkInfo>(), sl<RestClient>(),
        sl<AppState>(), sl<SharedPreferencesManager>(), null);

    // test only
    //FilterCondition condition = OfflineDatabaseFormatter.getTestFilter();
    //String where =
    //    OfflineDatabaseFormatter.getWhereFilterWithCondition(condition);

    componentData = this.filterImportComponents(componentData);

    if (componentData == null || componentData.length == 0) {
      responseError = Response();
      responseError.error = ErrorResponse(
          AppLocalizations.of(context).text('Offline Fehler'),
          '',
          AppLocalizations.of(context).text(
              'Es wurden keine DataBooks für den Offline Modus gefunden!'),
          'offline.error');
      result = false;
    }

    if (result) {
      double currentProgress = 0;
      double fetchProgress =
          componentData.length > 0 ? 0.5 / componentData.length : 0;

      // fetch all data to prepare offline sync
      await Future.forEach(componentData, (element) async {
        if (result) {
          this.responseError =
              await element.fetchAll(bloc, fetchOfflineRecordsPerRequest);

          if (this.responseError?.hasError ?? false)
            result = false;
          else {
            if (rowsImported != null && element?.data?.records != null)
              rowsToImport += element?.data?.records?.length;
            currentProgress += fetchProgress;
            setProgress(currentProgress);
          }
        }
      });

      // create all offline tables
      if (result) {
        await Future.forEach(componentData, (element) async {
          if (element != null &&
              element.data != null &&
              element.metaData != null) {
            String tableName =
                OfflineDatabaseFormatter.formatTableName(element.dataProvider);

            if (await tableExists(tableName)) {
              await this.dropTable(tableName);
            }
            String screenComponentId = "";
            if (element.soDataScreen != null &&
                (element.soDataScreen as SoScreenState<SoScreen>)
                        .widget
                        .configuration !=
                    null)
              screenComponentId =
                  (element.soDataScreen as SoScreenState<SoScreen>)
                      .widget
                      .configuration
                      ?.screenComponentId;

            result = result &
                await _createTableWithMetaData(
                    context, element.metaData, screenComponentId);
          }
        });

        // import all rows
        if (result) {
          await Future.forEach(componentData, (element) async {
            if (element != null &&
                element.data != null &&
                element.metaData != null &&
                result) {
              result = result & await _importRows(element.data);
              if (!result) {
                responseError = Response();
                responseError.error = ErrorResponse(
                    AppLocalizations.of(context).text('Importfehler'),
                    '',
                    AppLocalizations.of(context).text(
                        'Die Daten konnten nicht für den Offlinebetrieb importiert werden.'),
                    'offline.error');
              }
            }
          });
        }
      }
    }

    if (result)
      log("Offline import finished successfully! Imported records: $rowsImported/$rowsToImport");
    else
      log("Offline import finished with error! Importes records: $rowsImported/$rowsToImport ErrorDetail: ${responseError?.error?.details}");

    if (!result && responseError == null) {
      responseError = Response();
      responseError.error = ErrorResponse(
          AppLocalizations.of(context).text('Offline Fehler'),
          '',
          AppLocalizations.of(context).text(
              'Es ist ein Fehler beim wechseln in den Offline Modus aufgetreten.'),
          'offline.error');
    }

    return result;
  }

  List<SoComponentData> filterImportComponents(
      List<SoComponentData> componentData) {
    return componentData;
  }

  Future<bool> syncDelete(
      BuildContext context,
      String dataProvider,
      Filter filter,
      List<dynamic> columnNames,
      Map<String, dynamic> row) async {
    ApiBloc bloc = new ApiBloc(null, sl<NetworkInfo>(), sl<RestClient>(),
        sl<AppState>(), sl<SharedPreferencesManager>(), null);

    FetchData fetch = FetchData(dataProvider, bloc.appState.clientId,
        columnNames, null, null, false, filter);

    await for (Response response in bloc.data(fetch)) {
      if (response != null && !hasError(response)) {
        setProperties(bloc, response);
        if (response?.responseData?.dataBooks != null) {
          DataBook databook;
          databook = response.responseData.dataBooks
              .firstWhere((element) => element.dataProvider == dataProvider);
          if (databook?.records?.length == 1) {
            SelectRecord select = SelectRecord(dataProvider, filter, null,
                RequestType.DAL_DELETE, bloc.appState.clientId);

            await for (Response response in bloc.data(select)) {
              if (response != null && !hasError(response)) {
                setProperties(bloc, response);
                bloc.close();
                String tableName =
                    OfflineDatabaseFormatter.formatTableName(dataProvider);
                if (await tableExists(tableName)) {
                  Map<String, dynamic> record =
                      await getRowWithFilter(tableName, filter, false);
                  dynamic offlinePrimaryKey =
                      OfflineDatabaseFormatter.getOfflinePrimaryKey(record);
                  String where =
                      "$OFFLINE_COLUMNS_PRIMARY_KEY='${offlinePrimaryKey.toString()}'";

                  bloc.close();
                  return await this.delete(tableName, where);
                } else {
                  bloc.close();
                  return false;
                }
              }

              return false;
            }
          } else {
            responseError = Response();
            responseError.error = ErrorResponse(
                AppLocalizations.of(context).text('Online Sync Fehler'),
                '',
                AppLocalizations.of(context)
                    .text('Der zu löschende Datensatz wurde nicht gefunden.'),
                'offline.error');
          }
        }
      }
    }

    return false;
  }

  Future<bool> syncInsert(
      BuildContext context,
      String dataProvider,
      Filter filter,
      List<dynamic> columnNames,
      Map<String, dynamic> row) async {
    ApiBloc bloc = new ApiBloc(null, sl<NetworkInfo>(), sl<RestClient>(),
        sl<AppState>(), sl<SharedPreferencesManager>(), null);

    InsertRecord insert = InsertRecord(dataProvider, bloc.appState.clientId);
    await for (Response response in bloc.data(insert)) {
      if (response != null && !hasError(response)) {
        setProperties(bloc, response);

        if (response.responseData != null &&
            response.responseData.dataBooks != null) {
          DataBook dataBook = response.responseData.dataBooks
              .firstWhere((element) => element.dataProvider == dataProvider);
          if (dataBook != null &&
              dataBook.records != null &&
              dataBook.records.length > 0) {
            Map<String, dynamic> changedInsertValues =
                OfflineDatabaseFormatter.getChangedValues(
                    dataBook.records[0], columnNames, row, filter.columnNames);

            SetValues setValues = SetValues(
                dataProvider,
                changedInsertValues.keys.toList(),
                changedInsertValues.values.toList(),
                bloc.appState.clientId,
                null);
            await for (Response response in bloc.data(setValues)) {
              if (response != null && !hasError(response)) {
                dynamic offlinePrimaryKey =
                    OfflineDatabaseFormatter.getOfflinePrimaryKey(row);
                bloc.close();
                if (await setOfflineState(dataProvider, offlinePrimaryKey,
                    OFFLINE_ROW_STATE_UNCHANGED)) return true;
              }
            }
          }
        }

        bloc.close();
        return false;
      } else {
        bloc.close();
        return false;
      }
    }

    return false;
  }

  Future<bool> syncUpdate(
      BuildContext context,
      String dataProvider,
      Filter filter,
      List<dynamic> columnNames,
      Map<String, dynamic> row) async {
    ApiBloc bloc = new ApiBloc(null, sl<NetworkInfo>(), sl<RestClient>(),
        sl<AppState>(), sl<SharedPreferencesManager>(), null);

    Map<String, dynamic> changedValues =
        OfflineDatabaseFormatter.getChangedValuesForUpdate(
            columnNames, row, filter.columnNames);
    SetValues setValues = SetValues(dataProvider, changedValues.keys.toList(),
        changedValues.values.toList(), bloc.appState.clientId, null, filter);

    await for (Response response in bloc.data(setValues)) {
      if (response != null && !hasError(response)) {
        setProperties(bloc, response);
        bloc.close();
        dynamic offlinePrimaryKey =
            OfflineDatabaseFormatter.getOfflinePrimaryKey(row);
        if (await setOfflineState(
            dataProvider, offlinePrimaryKey, OFFLINE_ROW_STATE_UNCHANGED))
          return true;
      } else {
        bloc.close();
        return false;
      }
    }

    return false;
  }

  Future<bool> _createTableWithMetaData(BuildContext context,
      DataBookMetaData metaData, String screenComponentId) async {
    bool result = true;
    if (metaData != null &&
        metaData.columns != null &&
        metaData.columns.length > 0) {
      String tablename =
          OfflineDatabaseFormatter.formatTableName(metaData.dataProvider);
      if (!await tableExists(tablename)) {
        String columns = "";
        metaData.columns.forEach((column) {
          columns += OfflineDatabaseFormatter.formatColumnForCreateTable(
              column.name,
              OfflineDatabaseFormatter.getDataType(column.cellEditor));
        });

        if (columns.length > 0) {
          columns += OfflineDatabaseFormatter.getCreateTableOfflineColumns();
          if (columns.endsWith(CREATE_TABLE_COLUMNS_SEPERATOR))
            columns = columns.substring(
                0, columns.length - CREATE_TABLE_COLUMNS_SEPERATOR.length);

          if (await createTable(tablename, columns)) {
            String metaDataString = json.encode(metaData.toJson());
            result = result &
                await insertUpdateMetaData(metaData.dataProvider, tablename,
                    screenComponentId, metaDataString);
          } else {
            result = false;
            responseError = Response();
            responseError.error = ErrorResponse(
                AppLocalizations.of(context).text('Importfehler'),
                '',
                AppLocalizations.of(context).text(
                    'Die Tabellen für den Offlinebetrieb konnten nicht erstellt werden.'),
                'ImportOfflineData');
          }
        }
      }
    }
    return result;
  }

  Future<Response> getMetaData(DAL.MetaData request) async {
    Response response = Response();
    if (request != null && request.dataProvider != null) {
      DataBookMetaData metaData =
          await this.getMetaDataBook(request.dataProvider);
      if (metaData != null) {
        ResponseData responseData = ResponseData();
        responseData.dataBookMetaData = [metaData];
        response.responseData = responseData;
      }
    }
    return response;
  }

  Future<DataBookMetaData> getMetaDataBook(String dataProvider) async {
    String where =
        "[$OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER]='$dataProvider'";
    List<Map<String, dynamic>> result =
        await this.selectRows(OFFLINE_META_DATA_TABLE, where);
    if (result != null &&
        result.length > 0 &&
        result[0].containsKey(OFFLINE_META_DATA_TABLE_COLUMN_DATA)) {
      String metaData = result[0][OFFLINE_META_DATA_TABLE_COLUMN_DATA];

      DataBookMetaData metaDataObject =
          DataBookMetaData.fromJson(json.decode(metaData));

      if (result[0].containsKey(
              OFFLINE_META_DATA_TABLE_COLUMN_SCREEN_COMPONENT_ID) &&
          metaDataObject != null)
        metaDataObject.offlineScreenComponentId =
            result[0][OFFLINE_META_DATA_TABLE_COLUMN_SCREEN_COMPONENT_ID];
      return metaDataObject;
    }

    return null;
  }

  Future<List<String>> getOfflineDataProvider() async {
    List<String> offlineDataProvider = List<String>();

    List<Map<String, dynamic>> result =
        await this.selectRows(OFFLINE_META_DATA_TABLE);
    if (result != null && result.length > 0) {
      result.forEach((row) {
        if (row.containsKey(OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER)) {
          offlineDataProvider
              .add(row[OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER]);
        }
      });
    }

    return offlineDataProvider;
  }

  Future<bool> _importRows(DataBook data) async {
    if (data != null &&
        data.dataProvider != null &&
        data.records != null &&
        data.columnNames != null) {
      String tableName =
          OfflineDatabaseFormatter.formatTableName(data.dataProvider);

      if (await tableExists(tableName)) {
        List<String> sqlStatements = List<String>();

        data.records.forEach((element) {
          String columnString =
              OfflineDatabaseFormatter.getInsertColumnList(data.columnNames);
          String valueString =
              OfflineDatabaseFormatter.getInsertValueList(element);
          sqlStatements.add(
              "INSERT INTO [$tableName] ($columnString) VALUES ($valueString)");
        });

        await this.bulk(sqlStatements, () {
          rowsImported++;
          setProgress(rowsToImport == 0
              ? 0.5
              : 0.5 + (rowsImported / 2 / rowsToImport));
        });
        //await this.batch(sqlStatements);

        return true;
      }
    }

    return false;
  }

  Future<List<Map<String, dynamic>>> getSyncData(String dataProvider) async {
    if (dataProvider != null) {
      String tableName = OfflineDatabaseFormatter.formatTableName(dataProvider);
      String where =
          "[$OFFLINE_COLUMNS_STATE]<>'' AND [$OFFLINE_COLUMNS_STATE] is not null";
      String orderBy = "[$OFFLINE_COLUMNS_CHANGED]";

      return await this.selectRows(tableName, where, orderBy);
    }

    return null;
  }

  Future<bool> setOfflineState(
      String dataProvider, int offlinePrimaryKey, String state) async {
    String tableName = OfflineDatabaseFormatter.formatTableName(dataProvider);
    String setString = OfflineDatabaseFormatter.getStateSetString(state);
    String where =
        "[$OFFLINE_COLUMNS_PRIMARY_KEY]=${offlinePrimaryKey.toString()}";
    return await update(tableName, setString, where);
  }

  Future<bool> cleanupDatabase() async {
    await this.closeDatabase();
    try {
      File file = File(this.path);
      await file.delete();
      return true;
    } catch (error) {
      print(error);
    }
    return false;
  }

  Future<Response> fetchData(FetchData request) async {
    return await _getData(
        request,
        request.dataProvider,
        request.columnNames,
        request.fromRow,
        request.rowCount,
        request.includeMetaData,
        request.filter,
        null);
  }

  Future<Response> filterData(FilterData request) async {
    return await _getData(
        request,
        request.dataProvider,
        request.columnNames,
        request.fromRow,
        request.rowCount,
        request.includeMetaData,
        request.filter,
        request.condition);
  }

  Future<Response> _getData(
      Request request,
      String dataProvider,
      List<dynamic> columnNames,
      int fromRow,
      int rowCount,
      bool includeMetaData,
      Filter filter,
      FilterCondition filterCondition) async {
    if (request != null && dataProvider != null) {
      String tableName = OfflineDatabaseFormatter.formatTableName(dataProvider);
      String orderBy = "[$OFFLINE_COLUMNS_PRIMARY_KEY]";
      String limit = "";
      if (fromRow != null && fromRow >= 0) {
        limit = fromRow.toString();
        if (rowCount >= 0) limit = ", " + rowCount.toString();
      } else if (rowCount != null && rowCount >= 0) {
        limit = rowCount.toString();
      }

      String where = "[$OFFLINE_COLUMNS_STATE]<>'$OFFLINE_ROW_STATE_DELETED'";

      _lastFetchFilter = filter;
      _lastFetchFilterCondition = filterCondition;
      String whereFilter =
          OfflineDatabaseFormatter.getWhereFilterNew(filter, filterCondition);
      if (whereFilter.length > 0) where = where + WHERE_AND + whereFilter;

      List<Map<String, dynamic>> result =
          await this.selectRows(tableName, where, orderBy, limit);

      List<List<dynamic>> records = new List<List<dynamic>>();

      result.forEach((element) {
        records.add(OfflineDatabaseFormatter.removeOfflineColumns(element)
            .values
            .toList());
      });

      Response response = new Response();
      ResponseData data = new ResponseData();
      DataBook dataBook = new DataBook(
        dataProvider: dataProvider,
        records: records,
      );

      DataBookMetaData metaData = await getMetaDataBook(dataProvider);
      data.dataBookMetaData = [metaData];

      if (fromRow != null) {
        dataBook.from = fromRow;
        dataBook.isAllFetched = false;
      } else {
        dataBook.from = 0;
        dataBook.isAllFetched = true;
      }
      dataBook.to = records.length - 1 + dataBook.from;
      dataBook.columnNames = metaData?.columnNames;

      data.dataBooks = [dataBook];
      response.responseData = data;
      response.request = request;

      return response;
    }

    return Response();
  }

  Future<Response> setValues(SetValues request) async {
    if (request != null &&
        request.columnNames != null &&
        request.values != null &&
        request.columnNames.length > 0 &&
        request.columnNames.length == request.values.length) {
      String tableName =
          OfflineDatabaseFormatter.formatTableName(request.dataProvider);

      if (await tableExists(tableName)) {
        String sqlSet = OfflineDatabaseFormatter.getUpdateSetString(
            request.columnNames, request.values);

        if (sqlSet.length > 0) {
          Map<String, dynamic> record;
          if (request.offlineSelectedRow >= 0)
            record = await getRowWithIndex(
                tableName, request.offlineSelectedRow, null, false);
          else if (request.filter != null)
            record = await getRowWithFilter(tableName, request.filter);

          dynamic offlinePrimaryKey =
              OfflineDatabaseFormatter.getOfflinePrimaryKey(record);
          String rowState = OfflineDatabaseFormatter.getRowState(record);
          if (rowState != OFFLINE_ROW_STATE_INSERTED &&
              rowState != OFFLINE_ROW_STATE_DELETED) {
            sqlSet = sqlSet +
                UPDATE_DATA_SEPERATOR +
                OfflineDatabaseFormatter.getStateSetString(
                    OFFLINE_ROW_STATE_UPDATED);
          }
          String where =
              "$OFFLINE_COLUMNS_PRIMARY_KEY='${offlinePrimaryKey.toString()}'";
          if (await this.update(tableName, sqlSet, where)) {
            Map<String, dynamic> row =
                await getRowWithOfflinePrimaryKey(tableName, offlinePrimaryKey);
            List<dynamic> records = row.values.toList();
            Response response = new Response();
            ResponseData data = new ResponseData();
            DataBook dataBook = new DataBook(
              dataProvider: request.dataProvider,
              selectedRow: request.offlineSelectedRow,
              records: [records],
            );

            dataBook.from = request.offlineSelectedRow;
            dataBook.to = request.offlineSelectedRow;
            dataBook.isAllFetched = false;

            data.dataBooks = [dataBook];
            response.responseData = data;
            response.request = request;

            return response;
          }
        }
      }
    } else {
      throw new Exception(
          'Offline database exception: SetValues columnNames and values does not match or null!');
    }
    return Response();
  }

  Future<Response> selectRecord(SelectRecord request) async {
    if (request != null) {
      Response response = new Response();
      ResponseData data = new ResponseData();
      DataBook dataBook = new DataBook(
        dataProvider: request.dataProvider,
        selectedRow: request.selectedRow,
      );

      if (request.selectedRow >= 0) {
        String tableName =
            OfflineDatabaseFormatter.formatTableName(request.dataProvider);

        Map<String, dynamic> record =
            await getRowWithIndex(tableName, request.selectedRow);
        dataBook.records = [
          OfflineDatabaseFormatter.removeOfflineColumns(record).values.toList()
        ];
        dataBook.from = request.selectedRow;
        dataBook.to = request.selectedRow;
      }

      dataBook.isAllFetched = false;
      data.dataBooks = [dataBook];
      response.responseData = data;
      response.request = request;
      return response;
    }
    return Response();
  }

  Future<Response> deleteRecord(SelectRecord request,
      [bool forceDelete = false]) async {
    if (request != null) {
      String tableName =
          OfflineDatabaseFormatter.formatTableName(request.dataProvider);
      if (await tableExists(tableName)) {
        Map<String, dynamic> record;
        if (request.selectedRow >= 0)
          record = await getRowWithIndex(
              tableName, request.selectedRow, _lastFetchFilter);
        else
          record = await getRowWithFilter(tableName, request.filter);

        dynamic offlinePrimaryKey =
            OfflineDatabaseFormatter.getOfflinePrimaryKey(record);
        String rowState = OfflineDatabaseFormatter.getRowState(record);
        String where =
            "$OFFLINE_COLUMNS_PRIMARY_KEY='${offlinePrimaryKey.toString()}'";

        // Delete locally if inserted before
        if (rowState == OFFLINE_ROW_STATE_INSERTED || forceDelete) {
          if (await this.delete(tableName, where)) {
            FetchData fetch = FetchData(request.dataProvider, request.clientId);
            return await this.fetchData(fetch);
          }
        } else {
          if (await this.update(
              tableName,
              OfflineDatabaseFormatter.getStateSetString(
                  OFFLINE_ROW_STATE_DELETED),
              where)) {
            FetchData fetch = FetchData(request.dataProvider, request.clientId,
                null, null, null, null, _lastFetchFilter);
            return await this.fetchData(fetch);
          }
        }
      }
    }
    return Response();
  }

  Future<Response> insertRecord(InsertRecord request) async {
    if (request != null && request.dataProvider != null) {
      String tableName =
          OfflineDatabaseFormatter.formatTableName(request.dataProvider);
      String columnString =
          "[$OFFLINE_COLUMNS_STATE]$INSERT_INTO_DATA_SEPERATOR[$OFFLINE_COLUMNS_CHANGED]";
      String valueString =
          "'$OFFLINE_ROW_STATE_INSERTED'${INSERT_INTO_DATA_SEPERATOR}datetime('now')";
      if (await insert(tableName, columnString, valueString)) {
        int count = await this.rowCount(tableName);

        Response response = new Response();
        ResponseData data = new ResponseData();
        DataBook dataBook = new DataBook(
          dataProvider: request.dataProvider,
          selectedRow: count,
        );
        Map<String, dynamic> record =
            await getRowWithIndex(tableName, count - 1, null, false);
        dataBook.records = [
          OfflineDatabaseFormatter.removeOfflineColumns(record).values.toList()
        ];

        dataBook.from = count - 1;
        dataBook.to = count - 1;
        dataBook.selectedRow = count - 1;
        dataBook.isAllFetched = false;

        data.dataBooks = [dataBook];
        response.responseData = data;
        response.request = request;

        return response;
      }
    }

    return Response();
  }

  Stream<Response> request(Request request) async* {
    if (request != null) {
      if (request is FetchData) {
        Response resp = await fetchData(request);

        resp.request = request;

        if (resp.responseData.dataBooks.length > 0) {
          print(
              '${resp.responseData.dataBooks[0].dataProvider}: ${resp.responseData.dataBooks[0].records.length}');
        }

        yield resp;
      } else if (request is FilterData) {
        Response resp = await filterData(request);

        resp.request = request;

        if (resp.responseData.dataBooks.length > 0) {
          print(
              '${resp.responseData.dataBooks[0].dataProvider}: ${resp.responseData.dataBooks[0].records.length}');
        }

        yield resp;
      } else if (request is SetValues) {
        yield await this.setValues(request)
          ..request = request;
      } else if (request is InsertRecord) {
        Response resp = await this.insertRecord(request)
          ..request = request;

        if (request.setValues != null) {
          if (resp?.responseData?.dataBooks != null) {
            DataBook databook;
            databook = resp.responseData.dataBooks.firstWhere(
                (element) => element.dataProvider == request.dataProvider);
            request.setValues.offlineSelectedRow = databook.selectedRow;
          }
          yield await this.setValues(request.setValues)
            ..request = request.setValues;
        } else {
          yield resp;
        }
      } else if (request is MetaData) {
        yield await this.getMetaData(request)
          ..request = request;
      } else if (request is SelectRecord) {
        if (request.requestType == RequestType.DAL_SELECT_RECORD) {
          yield await this.selectRecord(request)
            ..request = request;
        } else if (request.requestType == RequestType.DAL_DELETE) {
          yield await this.deleteRecord(request)
            ..request = request;
        }
      } else if (request is Navigation) {
        yield Response()..request = request;
      } else if (request is Logout) {
        yield Response()..request = request;
      }
    }
  }

  Future<bool> insertUpdateMetaData(String dataProvider, String tableName,
      String screenComponentId, String metaData) async {
    String where =
        "[$OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER]='$dataProvider'";
    if (await rowExists(OFFLINE_META_DATA_TABLE, where)) {
      String setString =
          "[$OFFLINE_META_DATA_TABLE_COLUMN_TABLE_NAME] = '$tableName'$UPDATE_DATA_SEPERATOR" +
              "[$OFFLINE_META_DATA_TABLE_COLUMN_SCREEN_COMPONENT_ID] = '$screenComponentId'$UPDATE_DATA_SEPERATOR" +
              "[$OFFLINE_META_DATA_TABLE_COLUMN_DATA] = '$metaData'";
      return await update(OFFLINE_META_DATA_TABLE, setString, where);
    } else {
      String columnString =
          "[$OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER]$INSERT_INTO_DATA_SEPERATOR" +
              "[$OFFLINE_META_DATA_TABLE_COLUMN_TABLE_NAME]$INSERT_INTO_DATA_SEPERATOR" +
              "[$OFFLINE_META_DATA_TABLE_COLUMN_SCREEN_COMPONENT_ID]$INSERT_INTO_DATA_SEPERATOR" +
              "[$OFFLINE_META_DATA_TABLE_COLUMN_DATA]";
      String valueString =
          "'$dataProvider'$INSERT_INTO_DATA_SEPERATOR'$tableName'$INSERT_INTO_DATA_SEPERATOR'$screenComponentId'$INSERT_INTO_DATA_SEPERATOR'$metaData'";
      return await insert(OFFLINE_META_DATA_TABLE, columnString, valueString);
    }
  }

  Future<Map<String, dynamic>> getRowWithOfflinePrimaryKey(
      String tableName, dynamic offlinePrimaryKey) async {
    String where =
        "[$OFFLINE_COLUMNS_PRIMARY_KEY]='${offlinePrimaryKey.toString()}'";
    List<Map<String, dynamic>> result = await this.selectRows(tableName, where);

    if (result.length > 0) {
      return OfflineDatabaseFormatter.removeOfflineColumns(result[0]);
    }
    return null;
  }

  Future<Map<String, dynamic>> getRowWithIndex(String tableName, int index,
      [Filter filter, bool ignoreDeleted = true]) async {
    String orderBy = "[$OFFLINE_COLUMNS_PRIMARY_KEY]";
    String where = ignoreDeleted
        ? "[$OFFLINE_COLUMNS_STATE]<>'$OFFLINE_ROW_STATE_DELETED'"
        : "";

    if (filter != null && filter.columnNames != null && filter.values != null) {
      _lastFetchFilter = filter;
      String whereFilter = OfflineDatabaseFormatter.getWhereFilter(
          filter.columnNames, filter.values, filter.compareOperator);
      if (whereFilter.length > 0) where = where + WHERE_AND + whereFilter;
    }

    List<Map<String, dynamic>> result =
        await this.selectRows(tableName, where, orderBy, "$index, 1");

    if (result != null && result.length > 0) {
      return result[0];
    }

    return null;
  }

  Future<Map<String, dynamic>> getRowWithFilter(String tableName, Filter filter,
      [bool ignoreDeleted = true]) async {
    String orderBy = "[$OFFLINE_COLUMNS_PRIMARY_KEY]";
    String where = "";

    if (filter != null)
      where = OfflineDatabaseFormatter.getWhereFilter(
          filter.columnNames, filter.values, filter.compareOperator);
    if (ignoreDeleted) {
      if (where.length > 0)
        where = where +
            "$WHERE_AND[$OFFLINE_COLUMNS_STATE]<>'$OFFLINE_ROW_STATE_DELETED'";
      else
        where = "[$OFFLINE_COLUMNS_STATE]<>'$OFFLINE_ROW_STATE_DELETED'";
    }

    List<Map<String, dynamic>> result =
        await this.selectRows(tableName, where, orderBy);

    if (result != null && result.length > 0) {
      return result[0];
    }

    return null;
  }

  void setProperties(ApiBloc bloc, Response response) {
    if (response.applicationMetaData != null) {
      if (response.applicationMetaData != null &&
          response.applicationMetaData.version != bloc.manager.appVersion) {
        bloc.manager.setPreviousAppVersion(bloc.manager.appVersion);
        bloc.manager.setAppVersion(response.applicationMetaData.version);
      }

      if (bloc.appState.language != response.applicationMetaData.langCode &&
          response.applicationMetaData.langCode != null &&
          response.applicationMetaData.langCode.isNotEmpty) {
        AppLocalizations.load(Locale(response.applicationMetaData.langCode));
      }

      bloc.appState.language = response.applicationMetaData.langCode;
      bloc.appState.clientId = response.applicationMetaData.clientId;
      bloc.appState.appVersion = response.applicationMetaData.version;
    }
    if (response.menu != null) {
      bloc.appState.items = response.menu.entries;
    }
    if (response.userData != null) {
      bloc.appState.displayName = response.userData.displayName;
      bloc.appState.profileImage = response.userData.profileImage;
      bloc.appState.username = response.userData.userName;
      bloc.appState.roles = response.userData.roles;
    }
    if (response.applicationStyle != null) {
      bloc.appState.applicationStyle = response.applicationStyle;

      bloc.manager.setApplicationStyle(response.applicationStyle.toJson());
    }
  }

  void setRowProgress(int rowsCount, int rowsDone) {
    if (rowsCount == 0)
      setProgress(0);
    else
      setProgress(rowsDone / rowsCount);
  }

  void setProgress(double progress) {
    this.progress = progress;
    this._progressCallbacks.forEach((callback) => callback(progress));
  }

  void addProgressCallback(ProgressCallback callback) {
    this._progressCallbacks = <ProgressCallback>[];
    this._progressCallbacks.add(callback);
  }

  void removeAllProgressCallbacks() {
    this._progressCallbacks = <ProgressCallback>[];
  }

  bool hasError(Response response) {
    if (response.hasError) {
      responseError = response;
      return true;
    }

    return false;
  }
}
