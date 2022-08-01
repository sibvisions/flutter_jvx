import 'dart:developer';

import '../../../../mixin/data_service_mixin.dart';
import '../../../../model/api/requests/api_dal_save_request.dart';
import '../../../../model/api/requests/api_delete_record_request.dart';
import '../../../../model/api/requests/api_fetch_request.dart';
import '../../../../model/api/requests/api_filter_request.dart';
import '../../../../model/api/requests/api_insert_record_request.dart';
import '../../../../model/api/requests/api_set_values_request.dart';
import '../../../../model/api/requests/filter.dart';
import '../../../../model/api/requests/i_api_request.dart';
import '../../../../model/api/response/api_response.dart';
import '../../../../model/api/response/dal_fetch_response.dart';
import '../../../../model/config/api/api_config.dart';
import '../../../../model/data/data_book.dart';
import '../../../../model/data/subscriptions/data_record.dart';
import '../i_repository.dart';
import 'offline/offline_database.dart';

class OfflineApiRepository with DataServiceGetterMixin implements IRepository {
  OfflineDatabase? offlineDatabase;

  /// Every databook saves the maximum fetch registered, that way unspezified fetch responses don't
  /// contain all the data we have available.
  final Map<String, int> _databookFetchMap = {};

  /// Every databook saves the last fetch registered, that way unspezified fetch responses don't
  /// contain all the data we have available.
  final Map<String, Filter> _databookLastFilter = {};

  @override
  Future<void> start() async {
    if (isStopped()) {
      offlineDatabase = await OfflineDatabase.open();
    }
  }

  @override
  Future<void> stop() async {
    if (!isStopped()) {
      await offlineDatabase!.close();
    }
  }

  @override
  bool isStopped() {
    return offlineDatabase?.isClosed() ?? true;
  }

  /// Init database with currently available dataBooks
  Future<void> initDatabase(void Function(int value, int max, {int? progress})? progressUpdate) async {
    var dataBooks = getDataService().getDataBooks().values.toList(growable: false);

    var dalMetaData = dataBooks.map((e) => e.metaData!).toList(growable: false);
    //Drop old data + possible old scheme
    await offlineDatabase!.dropTables(dalMetaData);
    offlineDatabase!.createTables(dalMetaData);

    log("Sum of all dataBook entries: " +
        dataBooks.map((e) => e.records.entries.length).reduce((value, element) => value + element).toString());

    await offlineDatabase!.db.transaction((txn) async {
      for (var dataBook in dataBooks) {
        progressUpdate?.call(dataBooks.indexOf(dataBook) + 1, dataBooks.length);

        for (var entry in dataBook.records.entries) {
          Map<String, dynamic> rowData = {};
          entry.value.asMap().forEach((key, value) {
            if (key < dataBook.columnDefinitions.length) {
              var columnName = dataBook.columnDefinitions[key].name;
              rowData[columnName] = value;
            }
          });
          if (rowData.isNotEmpty) {
            await offlineDatabase!.rawInsert(pTableName: dataBook.dataProvider, pInsert: rowData, txn: txn);
          }

          progressUpdate?.call(dataBooks.indexOf(dataBook) + 1, dataBooks.length,
              progress: (entry.key / dataBook.records.length * 100).toInt());
        }
      }
    });

    log("done inserting offline data");
  }

  /// Deletes all currently used dataBooks
  Future<void> deleteDatabase() {
    return offlineDatabase!.getMetaData().then((value) => offlineDatabase!.dropTables(value));
  }

  Future<Map<String, List<Map<String, Object?>>>> getChangedRows(String pDataProvider) {
    return offlineDatabase!.getChangedRows(pDataProvider);
  }

  Future<int> resetStates(String pDataProvider, {required List<Map<String, Object?>> pResetRows}) {
    return offlineDatabase!.resetStates(pDataProvider, pResetRows);
  }

  @override
  Future<List<ApiResponse>> sendRequest({required IApiRequest pRequest}) {
    if (isStopped()) throw Exception("Repository not initialized");

    if (pRequest is ApiDalSaveRequest) {
      // Does nothing but is supported as api
    } else if (pRequest is ApiDeleteRecordRequest) {
      return _delete(pRequest);
    } else if (pRequest is ApiFetchRequest) {
      return _fetch(pRequest);
    } else if (pRequest is ApiFilterRequest) {
      return _filter(pRequest);
    } else if (pRequest is ApiInsertRecordRequest) {
      return _insert(pRequest);
    } else if (pRequest is ApiSetValuesRequest) {
      return _setValues(pRequest);
    }

    throw Exception("${pRequest.runtimeType} is not supported while offline");
  }

  @override
  void setApiConfig({required ApiConfig config}) {
    // Do nothing
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<List<ApiResponse>> _delete(ApiDeleteRecordRequest pRequest) async {
    Map<String, dynamic> filter = {};
    if (pRequest.filter != null) {
      Filter requestFilter = pRequest.filter!;

      for (int i = 0; i < requestFilter.columnNames.length; i++) {
        filter[requestFilter.columnNames[i]] = requestFilter.values[i];
      }
    } else {
      filter["ROWID"] = pRequest.selectedRow;
    }

    await offlineDatabase!.delete(pTableName: pRequest.dataProvider, pFilter: filter);

    // JVx Server does also ignore fetch and always fetches.
    // if (pRequest.fetch) {
    return _refetchMaximum(pRequest.dataProvider);
    // }
  }

  Future<List<ApiResponse>> _fetch(ApiFetchRequest pRequest) async {
    int fromRow = pRequest.fromRow > -1 ? pRequest.fromRow : 0;

    int? rowCount = pRequest.fromRow > -1 ? pRequest.rowCount : null;

    if (rowCount == null) {
      _databookFetchMap[pRequest.dataProvider] = -1;
    } else {
      int maximumFetch = _databookFetchMap[pRequest.dataProvider] ?? 0;

      if (maximumFetch != -1 && maximumFetch < (fromRow + rowCount)) {
        _databookFetchMap[pRequest.dataProvider] = (fromRow + rowCount);
      }
    }

    Filter? lastFilter = _databookLastFilter[pRequest.dataProvider];

    Map<String, dynamic>? filter = lastFilter != null ? _createSQLFilter(lastFilter) : null;

    DataBook dataBook = getDataService().getDataBook(pRequest.dataProvider)!;

    List<String> columnNames = pRequest.columnNames ?? dataBook.columnDefinitions.map((e) => e.name).toList();

    List<Map<String, dynamic>> selectionResult = await offlineDatabase!.select(
      pTableName: pRequest.dataProvider,
      pOffset: fromRow,
      pLimit: rowCount,
      pFilter: filter,
    );

    List<List<dynamic>> sortedMap = [];
    for (Map<String, dynamic> map in selectionResult) {
      List<dynamic> valueList = [];
      for (String columnName in columnNames) {
        valueList.add(map[columnName]);
      }

      sortedMap.add(valueList);
    }

    int rowCountDatabase = await offlineDatabase!.getCount(pTableName: pRequest.dataProvider, pFilter: filter);

    bool isAllFetched = rowCount == null;

    if (!isAllFetched && fromRow == 0 && rowCountDatabase <= rowCount) {
      isAllFetched = true;
    }

    return [
      DalFetchResponse(
        dataProvider: pRequest.dataProvider,
        from: fromRow,
        selectedRow: dataBook.selectedRow,
        isAllFetched: isAllFetched,
        columnNames: columnNames,
        to: fromRow + rowCountDatabase,
        records: sortedMap,
        name: "dal.fetch",
        originalResponse: pRequest,
      )
    ];
  }

  Future<List<ApiResponse>> _filter(ApiFilterRequest pRequest) async {
    if (pRequest.columnNames != null) {
      Filter filter = Filter(
        values: pRequest.columnNames!.map((e) => pRequest.value).toList(),
        columnNames: pRequest.columnNames!,
      );

      _databookLastFilter[pRequest.dataProvider] = filter;
    } else if (pRequest.filter != null) {
      _databookLastFilter[pRequest.dataProvider] = pRequest.filter!;
    }

    return _refetchMaximum(pRequest.dataProvider);
  }

  Future<List<ApiResponse>> _insert(ApiInsertRecordRequest pRequest) async {
    await offlineDatabase!.insert(pTableName: pRequest.dataProvider, pInsert: {});

    return _refetchMaximum(pRequest.dataProvider);
  }

  Future<List<ApiResponse>> _setValues(ApiSetValuesRequest pRequest) async {
    Filter filter;
    if (pRequest.filter == null) {
      DataBook dataBook = getDataService().getDataBook(pRequest.dataProvider)!;

      DataRecord? dataRecord = dataBook.getSelectedRecord(pDataColumnNames: dataBook.metaData!.primaryKeyColumns);

      if (dataRecord == null) {
        return [];
      }

      filter = Filter(values: dataRecord.values, columnNames: dataRecord.columnDefinitions.map((e) => e.name).toList());
    } else {
      filter = pRequest.filter!;
    }

    Map<String, dynamic> updateData = {};
    for (int i = 0; i < pRequest.columnNames.length; i++) {
      updateData[pRequest.columnNames[i]] = pRequest.values[i];
    }

    await offlineDatabase!
        .update(pTableName: pRequest.dataProvider, pUpdate: updateData, pFilter: _createSQLFilter(filter));

    return _refetchMaximum(pRequest.dataProvider);
  }

  Future<List<ApiResponse>> _refetchMaximum(String pDataProvider) async {
    int? maxFetch = _databookFetchMap[pDataProvider];
    if (maxFetch != null) {
      return _fetch(
        ApiFetchRequest(
          clientId: "",
          fromRow: 0,
          rowCount: maxFetch,
          dataProvider: pDataProvider,
        ),
      );
    }

    return [];
  }

  Map<String, dynamic> _createSQLFilter(Filter pFilter) {
    Map<String, dynamic> filterMap = {};

    for (int i = 0; i < pFilter.columnNames.length; i++) {
      String columnName = pFilter.columnNames[i];
      dynamic value = pFilter.values[i];
      filterMap[columnName] = value;
    }

    return filterMap;
  }
}
