import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/cupertino.dart';

import '../../../../flutterclient.dart';
import '../../../../injection_container.dart';
import '../../../models/api/data_source.dart';
import '../../../models/api/errors/failure.dart';
import '../../../models/api/request.dart';
import '../../../models/api/requests/application_style_request.dart';
import '../../../models/api/requests/close_screen_request.dart';
import '../../../models/api/requests/data/delete_record_request.dart';
import '../../../models/api/requests/data/fetch_data_request.dart';
import '../../../models/api/requests/data/filter_data_request.dart';
import '../../../models/api/requests/data/insert_record_request.dart';
import '../../../models/api/requests/data/meta_data_request.dart';
import '../../../models/api/requests/data/save_data_request.dart';
import '../../../models/api/requests/data/select_record_request.dart';
import '../../../models/api/requests/data/set_values_request.dart';
import '../../../models/api/requests/logout_request.dart';
import '../../../models/api/requests/navigation_request.dart';
import '../../../models/api/requests/open_screen_request.dart';
import '../../../models/api/requests/startup_request.dart';
import '../../../models/api/response_objects/application_meta_data_response_object.dart';
import '../../../models/api/response_objects/application_style/application_style_response_object.dart';
import '../../../models/api/response_objects/language_response_object.dart';
import '../../../models/api/response_objects/menu/menu_response_object.dart';
import '../../../models/api/response_objects/response_data/data/data_book.dart';
import '../../../models/api/response_objects/response_data/data/filter.dart';
import '../../../models/api/response_objects/response_data/data/filter_condition.dart';
import '../../../models/api/response_objects/response_data/meta_data/data_book_meta_data.dart';
import '../../../models/api/response_objects/user_data_response_object.dart';
import '../../../models/state/app_state.dart';
import '../../../ui/screen/core/so_component_data.dart';
import '../../../ui/screen/core/so_screen.dart';
import '../../../util/translation/app_localizations.dart';
import '../../remote/cubit/api_cubit.dart';
import '../../remote/network_info/network_info.dart';
import '../../repository/api_repository.dart';
import '../../repository/api_repository_impl.dart';
import '../shared_preferences/shared_preferences_manager.dart';
import 'i_offline_database_provider.dart';
import 'local_database.dart';
import 'offline_database_formatter.dart';

typedef ProgressCallback = Function(double);

class OfflineDatabase extends LocalDatabase
    implements IOfflineDatabaseProvider {
  ValueNotifier<double?> progress = ValueNotifier<double>(0.0);
  int rowsToImport = 0;
  int rowsImported = 0;
  int fetchOfflineRecordsPerRequest = 100;
  int insertOfflineRecordsPerBatchOperation = 100;
  Failure? responseError;
  Filter? _lastFetchFilter;
  FilterCondition? _lastFetchFilterCondition;

  Future<bool> openCreateDatabase(String path) async {
    if (await super.openCreateDatabase(path)) {
      String columnStr =
          "$OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER TEXT$CREATE_TABLE_COLUMNS_SEPERATOR" +
              "$OFFLINE_META_DATA_TABLE_COLUMN_TABLE_NAME TEXT$CREATE_TABLE_COLUMNS_SEPERATOR" +
              "$OFFLINE_META_DATA_TABLE_COLUMN_SCREEN_COMPONENT_ID TEXT$CREATE_TABLE_COLUMNS_SEPERATOR" +
              "$OFFLINE_META_DATA_TABLE_COLUMN_DATA TEXT";
      if (await this.createTable(OFFLINE_META_DATA_TABLE, columnStr))
        return true;
    }
    return false;
  }

  Future<bool> syncOnline(BuildContext context) async {
    bool result = false;
    int rowsToSync = 0;
    int rowsSynced = 0;
    responseError = null;

    ApiRepository repository = ApiRepositoryImpl(
        offlineDataSource: this,
        dataSource: sl<DataSource>(),
        networkInfo: sl<NetworkInfo>(),
        appState: sl<AppState>(),
        manager: sl<SharedPreferencesManager>(),
        decoder: sl<ZipDecoder>());

    log('Online sync started.');

    String? authUsername = repository.manager.syncLoginData?['username'];
    String? authPassword = repository.manager.syncLoginData?['password'];
    String? authKey = repository.manager.authKey;

    if (authKey != null || (authUsername != null && authPassword != null)) {
      StartupRequest startup = StartupRequest(
          clientId: '',
          url: repository.appState.serverConfig!.baseUrl,
          appName: repository.appState.serverConfig!.appName,
          screenHeight: MediaQuery.of(context).size.height.toInt(),
          screenWidth: MediaQuery.of(context).size.width.toInt(),
          appMode: repository.appState.serverConfig!.appMode,
          readAheadLimit: repository.appState.readAheadLimit,
          deviceId: repository.manager.deviceId!,
          username: authUsername,
          password: authPassword,
          authKey: authKey,
          layoutMode: 'generic',
          language: repository.appState.language!.language,
          forceNewSession: true);

      ApiState state = await repository.startup(startup);

      if (state is ApiResponse) {
        setProperties(repository, state);

        ApplicationStyleRequest appStyle = ApplicationStyleRequest(
          clientId: repository.appState.applicationMetaData!.clientId,
        );

        ApiState appStyleState = await repository.applicationStyle(appStyle);

        if (appStyleState is ApiResponse) {
          setProperties(repository, appStyleState);

          String currentScreenComponentId = "";

          List<String> syncDataProvider =
              await this.getOnlineSyncDataProvider();
          Map<String, List<Map<String, dynamic>>?> syncData =
              <String, List<Map<String, dynamic>>>{};

          await Future.forEach(syncDataProvider, (String? dataProvider) async {
            if (dataProvider != null) {
              syncData[dataProvider] = await getSyncData(context, dataProvider);

              if (syncData[dataProvider] != null) {
                rowsToSync += syncData[dataProvider]!.length;
              }
            }
          });

          await Future.forEach(syncData.entries, (MapEntry entry) async {
            if (entry.value.length > 0) {
              DataBookMetaData? metaData = await getMetaDataBook(entry.key);

              if (metaData!.offlineScreenComponentId !=
                  currentScreenComponentId) {
                if (currentScreenComponentId.isNotEmpty) {
                  CloseScreenRequest closeScreenRequest = CloseScreenRequest(
                    componentId: currentScreenComponentId,
                    clientId: repository.appState.applicationMetaData!.clientId,
                  );

                  ApiState state =
                      await repository.closeScreen(closeScreenRequest);

                  if (state is ApiResponse) {
                    currentScreenComponentId = '';
                  }
                }

                OpenScreenRequest openScreenRequest = OpenScreenRequest(
                    clientId: repository.appState.applicationMetaData!.clientId,
                    componentId: metaData.offlineScreenComponentId!);

                ApiState openScreenState =
                    await repository.openScreen(openScreenRequest);

                if (openScreenState is ApiResponse) {
                  currentScreenComponentId = metaData.offlineScreenComponentId!;
                }
              }

              await Future.forEach(entry.value,
                  (Map<String, dynamic> element) async {
                String? state = OfflineDatabaseFormatter.getRowState(element);
                Map<String, dynamic> primaryKeyValues =
                    OfflineDatabaseFormatter.getDataColumns(
                        element, metaData.primaryKeyColumns);
                Filter primaryKeyFilter = Filter(
                    columnNames: primaryKeyValues.keys.toList(),
                    values: primaryKeyValues.values.toList());
                if (state == OFFLINE_ROW_STATE_DELETED) {
                  if (await syncDelete(context, entry.key, primaryKeyFilter,
                      metaData.columnNames, element)) rowsSynced++;
                } else if (state == OFFLINE_ROW_STATE_INSERTED) {
                  if (await syncInsert(context, entry.key, primaryKeyFilter,
                      metaData.columnNames, element)) {
                    rowsSynced++;
                  }
                } else if (state == OFFLINE_ROW_STATE_UPDATED) {
                  if (await syncUpdate(context, entry.key, primaryKeyFilter,
                      metaData.columnNames, element)) {
                    rowsSynced++;
                  }
                }
                setRowProgress(rowsToSync, rowsSynced);
              });
            }
          });

          if (currentScreenComponentId.isNotEmpty) {
            CloseScreenRequest closeScreen = CloseScreenRequest(
                componentId: currentScreenComponentId,
                clientId: repository.appState.applicationMetaData!.clientId);

            ApiState closeState = await repository.closeScreen(closeScreen);

            if (closeState is ApiResponse) {
              currentScreenComponentId = '';
            }
          }
        }

        if (rowsSynced == rowsToSync) result = true;
      }
    } else {
      responseError = Failure(
          name: 'offline.error',
          title: AppLocalizations.of(context)!.text('Online Sync Fehler'),
          message: AppLocalizations.of(context)!
              .text('Authentifizierung fehlgeschlagen.'),
          details: '');
    }

    if (result)
      log("Online sync finished successfully! Synced records: $rowsSynced/$rowsToSync");
    else
      log("Online sync finished with error! Synced records: $rowsSynced/$rowsToSync ErrorDetail: ${responseError?.message}");

    // set general error
    if (!result && responseError == null) {
      responseError = Failure(
          title: AppLocalizations.of(context)!.text('Online Sync Fehler'),
          details: '',
          message: AppLocalizations.of(context)!.text(
              'Leider ist ein Fehler beim synchronisieren der Daten aufgetreten.'),
          name: 'offline.error');
    }

    return result;
  }

  Future<bool> importComponents(
      BuildContext context, List<SoComponentData> componentData) async {
    rowsToImport = 0;
    rowsImported = 0;
    responseError = null;
    bool result = true;

    ApiRepository repository = ApiRepositoryImpl(
        offlineDataSource: this,
        manager: sl<SharedPreferencesManager>(),
        appState: sl<AppState>(),
        networkInfo: sl<NetworkInfo>(),
        dataSource: sl<DataSource>(),
        decoder: sl<ZipDecoder>());

    //double freeDiscSpace = await DiskSpace.getFreeDiskSpace;
    log('Offline import started!');

    // test only
    //FilterCondition condition = OfflineDatabaseFormatter.getTestFilter();
    //String where =
    //    OfflineDatabaseFormatter.getWhereFilterWithCondition(condition);

    componentData = this.getOfflineImportComponentData(componentData);

    if (componentData.isEmpty) {
      responseError = Failure(
          title: AppLocalizations.of(context)!.text('Offline Fehler'),
          details: '',
          message: AppLocalizations.of(context)!.text(
              'Es wurden keine DataProvider für den Offline Modus angegeben!'),
          name: 'offline.error');
      result = false;
    }

    if (result) {
      double currentProgress = 0;
      double fetchProgress =
          componentData.length > 0 ? 0.5 / componentData.length : 0;

      // fetch all data to prepare offline sync
      await Future.forEach(componentData, (SoComponentData element) async {
        if (result) {
          ApiState? state =
              await element.fetchAll(repository, fetchOfflineRecordsPerRequest);

          if (state != null && state is ApiError)
            result = false;
          else {
            if (element.data?.records != null)
              rowsToImport += element.data!.records.length;
            currentProgress += fetchProgress;
            setProgress(currentProgress);
          }
        }
      });

      // create all offline tables
      if (result) {
        await Future.forEach(componentData, (SoComponentData element) async {
          if (element.data != null && element.metaData != null) {
            String? tableName =
                OfflineDatabaseFormatter.formatTableName(element.dataProvider);

            if (await tableExists(tableName)) {
              await this.dropTable(tableName);
            }
            String screenComponentId = "";
            screenComponentId =
                (element.soDataScreen as SoScreenState<SoScreen>)
                    .widget
                    .configuration
                    .screenComponentId;

            result = result &
                await _createTableWithMetaData(
                    context, element.metaData, screenComponentId);
          }
        });

        // import all rows
        if (result) {
          await Future.forEach(componentData, (SoComponentData element) async {
            if (element.data != null && element.metaData != null && result) {
              try {
                result = result & await _importRows(element.data);
              } catch (e) {
                result = false;
                log("Offline import finished with error! Importes records: $rowsImported/$rowsToImport, ErrorDetail: ${e.toString()}");
              }
              if (!result) {
                responseError = Failure(
                    title: AppLocalizations.of(context)!.text('Importfehler'),
                    details: '',
                    message: AppLocalizations.of(context)!.text(
                        'Die Daten konnten nicht für den Offlinebetrieb importiert werden.'),
                    name: 'offline.error');
              }
            }
          });
        }
      }
    }

    //freeDiscSpace = await DiskSpace.getFreeDiskSpace;

    if (result)
      log("Offline import finished successfully! Imported records: $rowsImported/$rowsToImport");
    else
      log("Offline import finished with error! Importes records: $rowsImported/$rowsToImport, ErrorDetail: ${responseError?.details}");

    if (!result && responseError == null) {
      responseError = Failure(
          title: AppLocalizations.of(context)!.text('Offline Fehler'),
          details: '',
          message: AppLocalizations.of(context)!.text(
              'Es ist ein Fehler beim wechseln in den Offline Modus aufgetreten.'),
          name: 'offline.error');
    }

    return result;
  }

  List<SoComponentData> getOfflineImportComponentData(
      List<SoComponentData> componentData) {
    return componentData;
  }

  Future<bool> syncDelete(
      BuildContext context,
      String dataProvider,
      Filter filter,
      List<dynamic> columnNames,
      Map<String, dynamic> row) async {
    ApiRepository repository = ApiRepositoryImpl(
        offlineDataSource: this,
        manager: sl<SharedPreferencesManager>(),
        appState: sl<AppState>(),
        networkInfo: sl<NetworkInfo>(),
        dataSource: sl<DataSource>(),
        decoder: sl<ZipDecoder>());

    FetchDataRequest fetch = FetchDataRequest(
        dataProvider: dataProvider,
        clientId: repository.appState.applicationMetaData!.clientId,
        columnNames: columnNames,
        filter: filter);

    List<ApiState> states = await repository.data(fetch);

    if (states.isNotEmpty && states.first is ApiResponse) {
      ApiResponse response = states.first as ApiResponse;

      setProperties(repository, response);

      if (response.hasDataBook) {
        DataBook? dataBook = response.getDataBookByProvider(dataProvider);

        if (dataBook?.records.length == 1) {
          DeleteRecordRequest delete = DeleteRecordRequest(
            selectedRow: null,
            dataProvider: dataProvider,
            filter: filter,
            clientId: repository.appState.applicationMetaData!.clientId,
          );

          List<ApiState> states = await repository.data(delete);

          if (states.isNotEmpty && states.first is ApiResponse) {
            setProperties(repository, response);

            if (await syncSave(
                context, dataProvider, filter, columnNames, row)) {
              String? tableName =
                  OfflineDatabaseFormatter.formatTableName(dataProvider);

              if (await tableExists(tableName)) {
                Map<String, dynamic>? record =
                    await getRowWithFilter(tableName, filter, false);
                dynamic offlinePrimaryKey =
                    OfflineDatabaseFormatter.getOfflinePrimaryKey(record);
                String where =
                    "$OFFLINE_COLUMNS_PRIMARY_KEY='${offlinePrimaryKey.toString()}'";

                return await this.delete(tableName, where);
              }
            }
          }
        }
      }
    } else {
      responseError = Failure(
          title: AppLocalizations.of(context)!.text('Online Sync Fehler'),
          details: '',
          message: AppLocalizations.of(context)!
              .text('Der zu löschende Datensatz wurde nicht gefunden.'),
          name: 'offline.error');
    }

    return false;
  }

  Future<bool> syncInsert(
      BuildContext context,
      String dataProvider,
      Filter filter,
      List<dynamic> columnNames,
      Map<String, dynamic> row) async {
    ApiRepository repository = ApiRepositoryImpl(
        offlineDataSource: this,
        manager: sl<SharedPreferencesManager>(),
        appState: sl<AppState>(),
        networkInfo: sl<NetworkInfo>(),
        dataSource: sl<DataSource>(),
        decoder: sl<ZipDecoder>());

    InsertRecordRequest insert = InsertRecordRequest(
        dataProvider: dataProvider,
        clientId: repository.appState.applicationMetaData!.clientId);

    List<ApiState> states = await repository.data(insert);

    if (states.isNotEmpty && states.first is ApiResponse) {
      ApiResponse response = states.first as ApiResponse;
      setProperties(repository, response);

      if (response.hasDataBook) {
        DataBook? dataBook = response.getDataBookByProvider(dataProvider);

        if (dataBook != null && dataBook.records.isNotEmpty) {
          Map<String, dynamic> changedInsertValues =
              OfflineDatabaseFormatter.getChangedValues(
                  dataBook.records[0], columnNames, row, filter.columnNames);

          SetValuesRequest setValues = SetValuesRequest(
              dataProvider: dataProvider,
              values: changedInsertValues.values.toList(),
              columnNames: changedInsertValues.keys.toList(),
              clientId: repository.appState.applicationMetaData!.clientId,
              offlineSelectedRow: null);

          List<ApiState> states = await repository.data(setValues);

          if (states.isNotEmpty && states.first is ApiResponse) {
            if (await syncSave(
                context, dataProvider, filter, columnNames, row)) {
              dynamic offlinePrimaryKey =
                  OfflineDatabaseFormatter.getOfflinePrimaryKey(row);
              if (await setOfflineState(
                  dataProvider, offlinePrimaryKey, OFFLINE_ROW_STATE_UNCHANGED))
                return true;
            }
          }
        }
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
    ApiRepository repository = ApiRepositoryImpl(
        offlineDataSource: this,
        manager: sl<SharedPreferencesManager>(),
        appState: sl<AppState>(),
        networkInfo: sl<NetworkInfo>(),
        dataSource: sl<DataSource>(),
        decoder: sl<ZipDecoder>());

    Map<String, dynamic> changedValues =
        OfflineDatabaseFormatter.getChangedValuesForUpdate(
            columnNames, row, filter.columnNames);
    SetValuesRequest setValues = SetValuesRequest(
        dataProvider: dataProvider,
        columnNames: changedValues.keys.toList(),
        values: changedValues.values.toList(),
        clientId: repository.appState.applicationMetaData!.clientId,
        filter: filter,
        offlineSelectedRow: null);

    List<ApiState> states = await repository.data(setValues);

    if (states.isNotEmpty && states.first is ApiResponse) {
      setProperties(repository, states.first as ApiResponse);
      if (await syncSave(context, dataProvider, filter, columnNames, row)) {
        dynamic offlinePrimaryKey =
            OfflineDatabaseFormatter.getOfflinePrimaryKey(row);
        if (await setOfflineState(
            dataProvider, offlinePrimaryKey, OFFLINE_ROW_STATE_UNCHANGED)) {
          return true;
        }
      }
    }

    return false;
  }

  Future<bool> syncSave(
      BuildContext context,
      String dataProvider,
      Filter filter,
      List<dynamic> columnNames,
      Map<String, dynamic> row) async {
    ApiRepository repository = ApiRepositoryImpl(
        offlineDataSource: this,
        manager: sl<SharedPreferencesManager>(),
        appState: sl<AppState>(),
        networkInfo: sl<NetworkInfo>(),
        dataSource: sl<DataSource>(),
        decoder: sl<ZipDecoder>());

    SaveDataRequest saveData = SaveDataRequest(
        dataProvider: dataProvider,
        clientId: repository.appState.applicationMetaData!.clientId);

    List<ApiState> state = await repository.data(saveData);

    if (state.isNotEmpty && state.first is ApiResponse) {
      setProperties(repository, state.first as ApiResponse);
      return true;
    }

    return false;
  }

  Future<bool> _createTableWithMetaData(BuildContext context,
      DataBookMetaData? metaData, String screenComponentId) async {
    bool result = true;
    if (metaData != null &&
        metaData.columns != null &&
        metaData.columns!.length > 0) {
      String? tablename =
          OfflineDatabaseFormatter.formatTableName(metaData.dataProvider);
      if (!await tableExists(tablename)) {
        String columns = "";
        await Future.forEach(metaData.columns!,
            (DataBookMetaDataColumn column) async {
          columns += OfflineDatabaseFormatter.formatColumnForCreateTable(
              column.name!,
              OfflineDatabaseFormatter.getDataType(column.cellEditor!));
        });

        if (columns.length > 0) {
          columns += OfflineDatabaseFormatter.getCreateTableOfflineColumns();
          if (columns.endsWith(CREATE_TABLE_COLUMNS_SEPERATOR))
            columns = columns.substring(
                0, columns.length - CREATE_TABLE_COLUMNS_SEPERATOR.length);

          if (await createTable(tablename, columns)) {
            String metaDataString = json.encode(metaData.toJson());
            result = result &
                await insertUpdateMetaData(metaData.dataProvider!, tablename!,
                    screenComponentId, metaDataString);
          } else {
            result = false;
            throw new Exception(
                'Offline database exception: Could not create offline table for dataProvider $metaData.dataProvider ');
          }
        }
      }
    }
    return result;
  }

  Future<ApiState> getMetaData(MetaDataRequest request) async {
    DataBookMetaData? metaData =
        await this.getMetaDataBook(request.dataProvider);

    if (metaData != null) {
      return ApiResponse(request: request, objects: [metaData]);
    }
    return ApiError(
        failure: Failure(
            details: '',
            message: 'An error occured',
            name: 'offline.error',
            title: 'Error'));
  }

  Future<DataBookMetaData?> getMetaDataBook(String dataProvider) async {
    String where =
        "[$OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER]='$dataProvider'";
    List<Map<String, dynamic>>? result =
        await this.selectRows(OFFLINE_META_DATA_TABLE, where);
    if (result != null &&
        result.length > 0 &&
        result[0].containsKey(OFFLINE_META_DATA_TABLE_COLUMN_DATA)) {
      String metaData = result[0][OFFLINE_META_DATA_TABLE_COLUMN_DATA];

      DataBookMetaData? metaDataObject =
          DataBookMetaData.fromJson(map: json.decode(metaData));

      if (result[0]
          .containsKey(OFFLINE_META_DATA_TABLE_COLUMN_SCREEN_COMPONENT_ID))
        metaDataObject.offlineScreenComponentId =
            result[0][OFFLINE_META_DATA_TABLE_COLUMN_SCREEN_COMPONENT_ID];
      return metaDataObject;
    }

    return null;
  }

  Future<List<String>> getOnlineSyncDataProvider() async {
    List<String> offlineDataProvider = <String>[];

    List<Map<String, dynamic>>? result =
        await this.selectRows(OFFLINE_META_DATA_TABLE);
    if (result != null && result.length > 0) {
      await Future.forEach(result, (Map<String, dynamic> row) async {
        if (row.containsKey(OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER)) {
          offlineDataProvider
              .add(row[OFFLINE_META_DATA_TABLE_COLUMN_DATA_PROVIDER]);
        }
      });
    }

    return offlineDataProvider;
  }

  Future<bool> _importRows(DataBook? data, {bool batchInsert = false}) async {
    if (data != null && data.dataProvider != null) {
      String? tableName =
          OfflineDatabaseFormatter.formatTableName(data.dataProvider);

      if (await tableExists(tableName)) {
        List<String> sqlStatements = <String>[];

        await Future.forEach(data.records, (dynamic element) async {
          String columnString =
              OfflineDatabaseFormatter.getInsertColumnList(data.columnNames);
          String valueString =
              OfflineDatabaseFormatter.getInsertValueList(element);
          sqlStatements.add(
              "INSERT INTO [$tableName] ($columnString) VALUES ($valueString)");
        });

        if (batchInsert) {
          // batch insert with a package of insertOfflineRecordsPerBatchOperation
          int index = 0;
          int importRows = 0;

          while (index < sqlStatements.length) {
            importRows += insertOfflineRecordsPerBatchOperation;
            if (importRows > sqlStatements.length)
              importRows = sqlStatements.length;
            List<String> batchStatements =
                sqlStatements.getRange(index, importRows).toList();
            await this.batch(batchStatements);
            rowsImported += importRows - index;
            index = importRows;
            //index += importRows;

            setProgress(rowsToImport == 0
                ? 0.5
                : 0.5 + (rowsImported / 2 / rowsToImport));
          }
        } else {
          // single bulk insert
          await this.bulk(sqlStatements, () {
            rowsImported++;
            setProgress(rowsToImport == 0
                ? 0.5
                : 0.5 + (rowsImported / 2 / rowsToImport));
          });
        }

        return true;
      }
    }

    return false;
  }

  Future<List<Map<String, dynamic>>?> getSyncData(
      BuildContext context, String? dataProvider) async {
    if (dataProvider != null) {
      String? tableName =
          OfflineDatabaseFormatter.formatTableName(dataProvider);
      String where =
          "[$OFFLINE_COLUMNS_STATE]<>'' AND [$OFFLINE_COLUMNS_STATE] is not null";
      String orderBy = "[$OFFLINE_COLUMNS_CHANGED]";

      if (await tableExists(tableName)) {
        return await this.selectRows(tableName, where, orderBy);
      } else {
        throw new Exception(
            'Offline database exception: Could not find offline table for dataProvider $dataProvider ');
      }
    }

    return null;
  }

  Future<bool> setOfflineState(
      String dataProvider, int offlinePrimaryKey, String state) async {
    String? tableName = OfflineDatabaseFormatter.formatTableName(dataProvider);
    String setString = OfflineDatabaseFormatter.getStateSetString(state);
    String where =
        "[$OFFLINE_COLUMNS_PRIMARY_KEY]=${offlinePrimaryKey.toString()}";
    return await update(tableName, setString, where);
  }

  Future<bool> cleanupDatabase() async {
    await this.closeDatabase();
    try {
      File file = File(path!);
      await file.delete();
      return true;
    } catch (error) {
      print(error);
    }
    return false;
  }

  Future<ApiState> fetchData(FetchDataRequest request) async {
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

  Future<ApiState> filterData(FilterDataRequest request) async {
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

  Future<ApiState> _getData(
      Request? request,
      String? dataProvider,
      List<dynamic>? columnNames,
      int? fromRow,
      int? rowCount,
      bool? includeMetaData,
      Filter? filter,
      FilterCondition? filterCondition) async {
    if (request != null && dataProvider != null) {
      String? tableName =
          OfflineDatabaseFormatter.formatTableName(dataProvider);
      String orderBy = "[$OFFLINE_COLUMNS_PRIMARY_KEY]";
      String limit = "";
      if (fromRow != null &&
          fromRow >= 0 &&
          rowCount != null &&
          rowCount >= 0) {
        limit = "$fromRow, $rowCount";
      } else if (rowCount != null && rowCount >= 0) {
        limit = rowCount.toString();
      }

      String where = "[$OFFLINE_COLUMNS_STATE]<>'$OFFLINE_ROW_STATE_DELETED'";

      _lastFetchFilter = filter;
      _lastFetchFilterCondition = filterCondition;
      String whereFilter =
          OfflineDatabaseFormatter.getWhereFilterNew(filter, filterCondition);
      if (whereFilter.length > 0) where = where + WHERE_AND + whereFilter;

      List<Map<String, dynamic>>? result =
          await this.selectRows(tableName, where, orderBy, limit);

      List<List<dynamic>> records = <List<dynamic>>[];

      if (result != null) {
        await Future.forEach(result, (Map<String, dynamic> element) async {
          records.add(OfflineDatabaseFormatter.removeOfflineColumns(element)
              .values
              .toList());
        });
      }

      ApiResponse response = ApiResponse(request: request, objects: []);
      DataBook dataBook = DataBook(
          dataProvider: dataProvider, records: records, name: 'dal.fetch');

      DataBookMetaData? metaData = await getMetaDataBook(dataProvider);

      if (metaData != null) response.addResponseObject(metaData);

      if (fromRow != null) {
        dataBook.from = fromRow;
        dataBook.isAllFetched = false;
      } else {
        dataBook.from = 0;
        dataBook.isAllFetched = true;
      }
      dataBook.to = records.length - 1 + dataBook.from!;
      dataBook.columnNames = metaData!.columnNames;

      response.addResponseObject(dataBook);

      return response;
    }

    return ApiError(
        failure: Failure(
            details: '',
            message: 'An error happended',
            name: 'offline.error',
            title: 'Error'));
  }

  Future<ApiState> setValues(SetValuesRequest? request) async {
    if (request != null &&
        request.columnNames.length > 0 &&
        request.columnNames.length == request.values.length) {
      String? tableName =
          OfflineDatabaseFormatter.formatTableName(request.dataProvider);

      if (await tableExists(tableName)) {
        String sqlSet = OfflineDatabaseFormatter.getUpdateSetString(
            request.columnNames, request.values);

        if (sqlSet.length > 0) {
          Map<String, dynamic>? record;
          if (request.offlineSelectedRow! >= 0)
            record = await getRowWithIndex(
                tableName!, request.offlineSelectedRow, null, false);
          else if (request.filter != null)
            record = await getRowWithFilter(tableName!, request.filter!);

          dynamic offlinePrimaryKey =
              OfflineDatabaseFormatter.getOfflinePrimaryKey(record);
          String? rowState = OfflineDatabaseFormatter.getRowState(record);
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
            Map<String, dynamic>? row =
                await getRowWithOfflinePrimaryKey(tableName, offlinePrimaryKey);
            List<dynamic> records = row!.values.toList();

            ApiResponse response = ApiResponse(request: request, objects: []);

            DataBook dataBook = new DataBook(
              dataProvider: request.dataProvider,
              selectedRow: request.offlineSelectedRow,
              records: [records],
              name: 'dal.fetch',
            );

            dataBook.from = request.offlineSelectedRow;
            dataBook.to = request.offlineSelectedRow;
            dataBook.isAllFetched = false;

            response.addResponseObject(dataBook);

            return response;
          }
        }
      }
    } else {
      throw new Exception(
          'Offline database exception: SetValues columnNames and values does not match or null!');
    }
    return ApiError(
        failure: Failure(
            details: '',
            message: 'An error occured',
            name: '',
            title: 'Error'));
  }

  Future<ApiState> selectRecord(SelectRecordRequest? request) async {
    if (request != null) {
      ApiResponse response = ApiResponse(request: request, objects: []);

      DataBook dataBook = DataBook(
          dataProvider: request.dataProvider,
          selectedRow: request.selectedRow,
          name: 'dal.fetch');

      if (request.selectedRow >= 0) {
        String? tableName =
            OfflineDatabaseFormatter.formatTableName(request.dataProvider);

        Map<String, dynamic>? record =
            await getRowWithIndex(tableName, request.selectedRow);
        dataBook.records = [
          OfflineDatabaseFormatter.removeOfflineColumns(record!).values.toList()
        ];
        dataBook.from = request.selectedRow;
        dataBook.to = request.selectedRow;
      }

      dataBook.isAllFetched = false;
      response.addResponseObject(dataBook);
      return response;
    }
    return ApiError(
        failure: Failure(
            details: '',
            message: 'An error occured',
            name: '',
            title: 'Error'));
  }

  Future<ApiState> deleteRecord(DeleteRecordRequest? request,
      [bool forceDelete = false]) async {
    if (request != null) {
      String? tableName =
          OfflineDatabaseFormatter.formatTableName(request.dataProvider);
      if (await tableExists(tableName)) {
        Map<String, dynamic>? record;
        if (request.selectedRow! >= 0)
          record = await getRowWithIndex(
              tableName, request.selectedRow, _lastFetchFilter);
        else
          record = await getRowWithFilter(tableName, request.filter);

        dynamic offlinePrimaryKey =
            OfflineDatabaseFormatter.getOfflinePrimaryKey(record);
        String? rowState = OfflineDatabaseFormatter.getRowState(record);
        String where =
            "$OFFLINE_COLUMNS_PRIMARY_KEY='${offlinePrimaryKey.toString()}'";

        // Delete locally if inserted before
        if (rowState == OFFLINE_ROW_STATE_INSERTED || forceDelete) {
          if (await this.delete(tableName, where)) {
            FetchDataRequest fetch = FetchDataRequest(
                dataProvider: request.dataProvider, clientId: request.clientId);
            return await this.fetchData(fetch);
          }
        } else {
          if (await this.update(
              tableName,
              OfflineDatabaseFormatter.getStateSetString(
                  OFFLINE_ROW_STATE_DELETED),
              where)) {
            FetchDataRequest fetch = FetchDataRequest(
                dataProvider: request.dataProvider,
                clientId: request.clientId,
                filter: _lastFetchFilter);
            return await this.fetchData(fetch);
          }
        }
      }
    }
    return ApiError(
        failure: Failure(
            details: '',
            message: 'An error occured',
            name: '',
            title: 'Error'));
  }

  Future<ApiState> insertRecord(InsertRecordRequest? request) async {
    if (request != null) {
      String? tableName =
          OfflineDatabaseFormatter.formatTableName(request.dataProvider);
      String columnString =
          "[$OFFLINE_COLUMNS_STATE]$INSERT_INTO_DATA_SEPERATOR[$OFFLINE_COLUMNS_CHANGED]";
      String valueString =
          "'$OFFLINE_ROW_STATE_INSERTED'${INSERT_INTO_DATA_SEPERATOR}datetime('now')";
      int count = await insert(tableName, columnString, valueString);
      if (count >= 0) {
        ApiResponse response = ApiResponse(request: request, objects: []);
        DataBook dataBook = new DataBook(
          dataProvider: request.dataProvider,
          selectedRow: count,
          name: 'dal.fetch',
        );

        Map<String, dynamic>? record =
            await getRowWithIndex(tableName, count - 1, null, false);
        dataBook.records = [
          OfflineDatabaseFormatter.removeOfflineColumns(record!).values.toList()
        ];

        dataBook.from = count - 1;
        dataBook.to = count - 1;
        dataBook.selectedRow = count - 1;
        dataBook.isAllFetched = false;

        response.addResponseObject(dataBook);

        return response;
      }
    }

    return ApiError(
        failure: Failure(
            details: '',
            message: 'An error occured',
            name: '',
            title: 'Error'));
  }

  Future<ApiState> request(Request? request) async {
    if (request != null) {
      if (request is FetchDataRequest) {
        ApiState resp = await fetchData(request);

        if (resp is ApiResponse && resp.hasDataObject) {
          DataBook dataBook = resp.getObjectByType<DataBook>()!;
          print('${dataBook.dataProvider}: ${dataBook.records.length}');
        }

        return resp;
      } else if (request is FilterDataRequest) {
        ApiState resp = await filterData(request);

        if (resp is ApiResponse && resp.hasDataObject) {
          DataBook dataBook = resp.getObjectByType<DataBook>()!;
          print('${dataBook.dataProvider}: ${dataBook.records.length}');
        }

        return resp;
      } else if (request is SetValuesRequest) {
        return await this.setValues(request);
      } else if (request is InsertRecordRequest) {
        ApiState resp = await this.insertRecord(request);

        if (request.setValues != null) {
          if (resp is ApiResponse && resp.hasDataBook) {
            DataBook? databook =
                resp.getDataBookByProvider(request.dataProvider);
            if (databook != null &&
                databook.selectedRow != null &&
                request.setValues != null) {
              request.setValues!.offlineSelectedRow = databook.selectedRow!;
            }
          }
          return await this.setValues(request.setValues);
        } else {
          return resp;
        }
      } else if (request is MetaDataRequest) {
        return await this.getMetaData(request);
      } else if (request is SelectRecordRequest) {
        return await this.selectRecord(request);
      } else if (request is DeleteRecordRequest) {
        return await this.deleteRecord(request);
      } else if (request is NavigationRequest) {
        return ApiResponse(request: request, objects: []);
      } else if (request is LogoutRequest) {
        return ApiResponse(request: request, objects: []);
      } else if (request is DeviceStatusRequest) {
        return ApiResponse(request: request, objects: []);
      } else {
        return ApiError(
            failure: Failure(
                details: '',
                message: 'Request could not be parsed',
                name: '',
                title: 'Error'));
      }
    } else {
      return ApiError(
          failure: Failure(
              details: '',
              message: 'An error occured',
              name: '',
              title: 'Error'));
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
      return await insert(OFFLINE_META_DATA_TABLE, columnString, valueString) >=
          0;
    }
  }

  Future<Map<String, dynamic>?> getRowWithOfflinePrimaryKey(
      String? tableName, dynamic? offlinePrimaryKey) async {
    String where =
        "[$OFFLINE_COLUMNS_PRIMARY_KEY]='${offlinePrimaryKey.toString()}'";
    List<Map<String, dynamic>>? result =
        await this.selectRows(tableName, where);

    if (result != null && result.length > 0) {
      return OfflineDatabaseFormatter.removeOfflineColumns(result[0]);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getRowWithIndex(String? tableName, int? index,
      [Filter? filter, bool ignoreDeleted = true]) async {
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

    List<Map<String, dynamic>>? result =
        await this.selectRows(tableName, where, orderBy, "$index, 1");

    if (result != null && result.length > 0) {
      return result[0];
    }

    return null;
  }

  Future<Map<String, dynamic>?> getRowWithFilter(
      String? tableName, Filter? filter,
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

    List<Map<String, dynamic>>? result =
        await this.selectRows(tableName, where, orderBy);

    if (result != null && result.length > 0) {
      return result[0];
    }

    return null;
  }

  void setProperties(ApiRepository repository, ApiResponse response) {
    if (response.hasObject<ApplicationMetaDataResponseObject>()) {
      ApplicationMetaDataResponseObject applicationMetaData =
          response.getObjectByType<ApplicationMetaDataResponseObject>()!;

      repository.appState.applicationMetaData = applicationMetaData;

      if (response.hasObject<LanguageResponseObject>()) {
        repository.appState.language =
            response.getObjectByType<LanguageResponseObject>();
      }

      if (applicationMetaData.version != repository.manager.appVersion) {
        repository.manager.previousAppVersion = repository.manager.appVersion;
        repository.manager.appVersion = applicationMetaData.version;
      }

      if (repository.appState.language?.language !=
              applicationMetaData.langCode &&
          applicationMetaData.langCode.isNotEmpty) {
        AppLocalizations.load(Locale(applicationMetaData.langCode));
      }
    }
    if (response.hasObject<MenuResponseObject>()) {
      repository.appState.menuResponseObject =
          response.getObjectByType<MenuResponseObject>()!;
    }
    if (response.hasObject<UserDataResponseObject>()) {
      repository.appState.userData =
          response.getObjectByType<UserDataResponseObject>();
    }
    if (response.hasObject<ApplicationStyleResponseObject>()) {
      repository.appState.applicationStyle =
          response.getObjectByType<ApplicationStyleResponseObject>();

      repository.manager.applicationStyle =
          repository.appState.applicationStyle;
    }
  }

  void setRowProgress(int rowsCount, int rowsDone) {
    if (rowsCount == 0)
      setProgress(0);
    else
      setProgress(rowsDone / rowsCount);
  }

  void setProgress(double progress) {
    this.progress.value = progress;
  }

  bool hasError(ApiResponse response) {
    if (response.hasError) {
      responseError = response.getObjectByType<Failure>();
      return true;
    }

    return false;
  }
}
