import '../../../../flutter_ui.dart';
import '../../../../model/api_interaction.dart';
import '../../../../model/data/data_book.dart';
import '../../../../model/data/filter_condition.dart';
import '../../../../model/data/subscriptions/data_record.dart';
import '../../../../model/request/api_dal_save_request.dart';
import '../../../../model/request/api_delete_record_request.dart';
import '../../../../model/request/api_fetch_request.dart';
import '../../../../model/request/api_filter_request.dart';
import '../../../../model/request/api_insert_record_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/request/api_set_values_request.dart';
import '../../../../model/request/filter.dart';
import '../../../../model/response/api_response.dart';
import '../../../../model/response/dal_fetch_response.dart';
import '../../../../model/response/dal_meta_data_response.dart';
import '../../../../util/parse_util.dart';
import '../../../data/i_data_service.dart';
import '../i_repository.dart';
import 'offline/offline_database.dart';

class OfflineApiRepository implements IRepository {
  OfflineDatabase? offlineDatabase;

  /// Every databook saves the maximum fetch registered, that way unspezified fetch responses don't
  /// contain all the data we have available.
  final Map<String, int> _databookFetchMap = {};

  /// Every databook saves the last fetch registered, that way unspezified fetch responses don't
  /// contain all the data we have available.
  final Map<String, Object> _databookLastFilter = {};

  @override
  Future<void> start() async {
    if (isStopped()) {
      offlineDatabase = await OfflineDatabase.open();

      //Init all databooks because there is no OpenScreenCommand offline
      await initDataBooks();
    }
  }

  Future<void> initDataBooks() async {
    List<DalMetaDataResponse> metaData = await offlineDatabase!.getMetaData();
    await Future.wait(metaData.map((element) => IDataService().updateMetaData(pMetaData: element)));
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
  Future<void> initDatabase(
    List<DataBook> dataBooks,
    void Function(int value, int max, {int? progress})? progressUpdate,
  ) async {
    var dalMetaData = dataBooks.map((e) => e.metaData!).toList(growable: false);
    //Drop old data + possible old scheme
    await offlineDatabase!.dropTables(dalMetaData);
    offlineDatabase!.createTables(dalMetaData);

    FlutterUI.logAPI.d(
        "Sum of all dataBook entries: ${dataBooks.map((e) => e.records.entries.length).reduce((value, element) => value + element)}");

    await offlineDatabase!.db.transaction((txn) async {
      var batch = txn.batch();
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
            batch.insert(offlineDatabase!.formatOfflineTableName(dataBook.dataProvider), rowData);
          }

          progressUpdate?.call(dataBooks.indexOf(dataBook) + 1, dataBooks.length,
              progress: (entry.key / dataBook.records.length * 100).round());
        }
      }
      return batch.commit();
    });

    FlutterUI.logAPI.i("done inserting offline data");
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
  Future<ApiInteraction> sendRequest(ApiRequest pRequest) async {
    if (isStopped()) throw Exception("Repository not initialized");

    ApiResponse? response;

    if (pRequest is ApiDalSaveRequest) {
      // Does nothing but is supported as api
    } else if (pRequest is ApiDeleteRecordRequest) {
      response = await _delete(pRequest);
    } else if (pRequest is ApiFetchRequest) {
      response = await _fetch(pRequest);
    } else if (pRequest is ApiFilterRequest) {
      response = await _filter(pRequest);
    } else if (pRequest is ApiInsertRecordRequest) {
      response = await _insert(pRequest);
    } else if (pRequest is ApiSetValuesRequest) {
      response = await _setValues(pRequest);
    } else {
      throw Exception("${pRequest.runtimeType} is not supported while offline");
    }

    return ApiInteraction(responses: response != null ? [response] : [], request: pRequest);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<DalFetchResponse?> _delete(ApiDeleteRecordRequest pRequest) async {
    Map<String, dynamic> filter = {};
    if (pRequest.filter != null) {
      Filter requestFilter = pRequest.filter!;

      for (int i = 0; i < requestFilter.columnNames.length; i++) {
        filter[requestFilter.columnNames[i]] = requestFilter.values[i];
      }
    } else {
      filter['ROWID'] = pRequest.selectedRow;
    }

    List<FilterCondition> filters = [...?_getFilter(pRequest.filter, pRequest.filterCondition)];
    if (filters.isEmpty && pRequest.selectedRow != null) {
      filters.add(FilterCondition(columnName: "ROWID", value: pRequest.selectedRow));
    }

    //Fallback
    if (filters.isEmpty) {
      Filter? selectedRowFilter = _createSelectedRowFilter(pDataProvider: pRequest.dataProvider);
      if (selectedRowFilter != null) {
        filters.addAll(selectedRowFilter.asFilterConditions());
      } else {
        //Cancel when no filter
        return _refetchMaximum(pRequest.dataProvider);
      }
    }

    filters.addAll(_getLastFilter(pRequest.dataProvider));

    await offlineDatabase!.delete(pTableName: pRequest.dataProvider, pFilters: filters);

    // JVx Server does also ignore fetch and always fetches.
    // if (pRequest.fetch) {

    await DataBook.selectRecord(pDataProvider: pRequest.dataProvider, pSelectedRecord: -1);

    return _refetchMaximum(pRequest.dataProvider);
    // }
  }

  Future<DalFetchResponse?> _fetch(ApiFetchRequest pRequest) async {
    if (pRequest.fromRow <= -1) {
      return null;
    }

    int? rowCount = pRequest.rowCount >= 0 ? pRequest.rowCount : null;

    if (rowCount == null) {
      _databookFetchMap[pRequest.dataProvider] = -1;
    } else {
      int currentMaxFetch = _databookFetchMap[pRequest.dataProvider] ?? 0;

      int maxFetch = pRequest.fromRow + rowCount;

      if (currentMaxFetch != -1 && currentMaxFetch < maxFetch) {
        _databookFetchMap[pRequest.dataProvider] = maxFetch;
      }
    }

    List<FilterCondition> filters = _getLastFilter(pRequest.dataProvider);

    DataBook dataBook = IDataService().getDataBook(pRequest.dataProvider)!;

    List<String> columnNames = pRequest.columnNames ?? dataBook.columnDefinitions.map((e) => e.name).toList();

    List<Map<String, dynamic>> selectionResult = await offlineDatabase!.select(
      pColumns: columnNames,
      pTableName: pRequest.dataProvider,
      pOffset: pRequest.fromRow > 0 ? pRequest.fromRow : null,
      pLimit: rowCount,
      pFilters: filters,
    );

    List<List<dynamic>> sortedMap = [];
    for (Map<String, dynamic> map in selectionResult) {
      List<dynamic> valueList = [];
      for (String columnName in columnNames) {
        valueList.add(map[columnName]);
      }

      sortedMap.add(valueList);
    }

    int rowCountDatabase = await offlineDatabase!.getCount(
      pTableName: pRequest.dataProvider,
      pFilters: filters,
    );

    bool isAllFetched = rowCountDatabase <= sortedMap.length;

    return DalFetchResponse(
      dataProvider: pRequest.dataProvider,
      from: pRequest.fromRow,
      selectedRow: dataBook.selectedRow,
      isAllFetched: isAllFetched,
      columnNames: columnNames,
      to: pRequest.fromRow + (sortedMap.length - 1),
      records: sortedMap,
      name: "dal.fetch",
    );
  }

  Future<DalFetchResponse?> _filter(ApiFilterRequest pRequest) async {
    if (pRequest.columnNames != null) {
      Filter filter = Filter(
        values: pRequest.columnNames!.map((e) => pRequest.value).toList(),
        columnNames: pRequest.columnNames!,
      );

      _databookLastFilter[pRequest.dataProvider] = filter;
    } else if ((pRequest.filter?.isEmpty ?? true) && pRequest.filterCondition == null) {
      _databookLastFilter.remove(pRequest.dataProvider);
    } else {
      _databookLastFilter[pRequest.dataProvider] = pRequest.filterCondition ?? pRequest.filter!;
    }

    return _refetchMaximum(pRequest.dataProvider);
  }

  Future<ApiResponse?> _insert(ApiInsertRecordRequest pRequest) async {
    await offlineDatabase!.insert(pTableName: pRequest.dataProvider, pInsert: {});

    return _refetchMaximum(pRequest.dataProvider);
  }

  Future<DalFetchResponse?> _setValues(ApiSetValuesRequest pRequest) async {
    List<FilterCondition> filters = _getLastFilter(pRequest.dataProvider);
    filters.addAll([...?_getFilter(pRequest.filter, pRequest.filterCondition)]);

    //Fallback
    if (filters.isEmpty) {
      Filter? selectedRowFilter = _createSelectedRowFilter(pDataProvider: pRequest.dataProvider);
      if (selectedRowFilter != null) {
        filters.addAll(selectedRowFilter.asFilterConditions());
      } else {
        //Cancel when no filter
        return _refetchMaximum(pRequest.dataProvider);
      }
    }

    Map<String, dynamic> updateData = {};
    for (int i = 0; i < pRequest.columnNames.length; i++) {
      updateData[pRequest.columnNames[i]] = pRequest.values[i];
    }

    await offlineDatabase!.update(pTableName: pRequest.dataProvider, pUpdate: updateData, pFilters: filters);

    return _refetchMaximum(pRequest.dataProvider);
  }

  List<FilterCondition> _getLastFilter(String dataProvider) {
    return [
      ...?_getFilter(
        ParseUtil.castOrNull(_databookLastFilter[dataProvider]),
        ParseUtil.castOrNull(_databookLastFilter[dataProvider]),
      )
    ];
  }

  Future<DalFetchResponse?> _refetchMaximum(String pDataProvider) async {
    int? maxFetch = _databookFetchMap[pDataProvider];
    if (maxFetch != null) {
      return _fetch(
        ApiFetchRequest(
          fromRow: 0,
          rowCount: maxFetch,
          dataProvider: pDataProvider,
        ),
      );
    }

    return null;
  }

  List<FilterCondition>? _getFilter(Filter? pFilter, FilterCondition? pFilterCondition) {
    if (pFilterCondition != null) {
      return [pFilterCondition];
    } else if (!(pFilter?.isEmpty ?? true)) {
      //Not null and not empty
      return pFilter!.asFilterConditions();
    }
    return null;
  }

  Filter? _createSelectedRowFilter({required String pDataProvider, int? pSelectedRow}) {
    DataBook dataBook = IDataService().getDataBook(pDataProvider)!;

    DataRecord? dataRecord = dataBook.getRecord(
      pDataColumnNames: dataBook.metaData!.primaryKeyColumns,
      pRecordIndex: pSelectedRow ?? dataBook.selectedRow,
    );

    if (dataRecord == null) {
      return null;
    }

    return Filter(
      columnNames: dataRecord.columnDefinitions.map((e) => e.name).toList(),
      values: dataRecord.values,
    );
  }
}
