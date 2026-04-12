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

import 'package:sqflite/sqflite.dart';
import 'package:universal_io/io.dart';

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
import '../../../../model/request/api_reload_data_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/request/api_select_record_request.dart';
import '../../../../model/request/api_set_values_request.dart';
import '../../../../model/request/filter.dart';
import '../../../../model/response/api_response.dart';
import '../../../../model/response/dal_data_provider_changed_response.dart';
import '../../../../model/response/dal_fetch_response.dart';
import '../../../../util/jvx_logger.dart';
import '../../../config/i_config_service.dart';
import '../../../data/i_data_service.dart';
import '../api_object_property.dart';
import '../api_response_names.dart';
import '../i_repository.dart';
import 'offline/offline_database.dart';

class OfflineApiRepository extends IRepository {
  OfflineDatabase? offlineDatabase;

  /// Every data book saves the maximum fetch registered, that way unspecified fetch responses don't
  /// contain all the data we have available.
  final Map<String, int> _dataBookFetchMap = {};

  /// Every data book saves the last fetch registered, that way unspecified fetch responses don't
  /// contain all the data we have available.
  final Map<String, Object> _dataBookLastFilter = {};

  @override
  Future<void> start() async {
    if (isStopped()) {
      offlineDatabase = await OfflineDatabase.open();

      // Init all current data books because there is no OpenScreenCommand offline
      await initDataBooks();
    }
  }

  Future<void> initDataBooks() async {
    _checkStatus();

    List<DalMetaData> metaData = await offlineDatabase!.getMetaData(IConfigService().currentApp.value!);
    metaData.forEach((element) => IDataService().setMetaData(element));
  }

  @override
  Future<void> stop() async {
    await super.stop();
    if (!isStopped()) {
      await offlineDatabase!.close();
    }
  }

  @override
  bool isStopped() {
    return offlineDatabase?.isClosed() ?? true;
  }

  @override
  Set<Cookie> getCookies() => {};

  @override
  void setCookies(Set<Cookie> cookies) => {};

  @override
  Map<String, String> getHeaders() => {};

  /// Init database with currently available dataBooks.
  Future<void> initDatabase(
    List<DataBook> dataBooks,
    void Function(int value, int max, {int? progress})? progressUpdate,
  ) async {
    _checkStatus();

    var dalMetaData = dataBooks.map((e) => e.metaData).nonNulls.toList(growable: false);
    // Drop old data + possible old scheme
    await offlineDatabase!.dropTables(IConfigService().currentApp.value!);
    await offlineDatabase!.createTables(IConfigService().currentApp.value!, dalMetaData);

    bool bLogDebug = FlutterUI.logAPI.cl(Lvl.d);

    if (bLogDebug) {
      FlutterUI.logAPI.d(
          "Sum of all dataBook entries: ${dataBooks.isNotEmpty ? dataBooks.map((e) => e.records.entries.length).reduce((value, element) => value + element) : 0}");
    }

    await offlineDatabase!.db.transaction((txn) async {
      Batch batch = txn.batch();
      for (var dataBook in dataBooks) {

        if (bLogDebug) {
          FlutterUI.logAPI.d("Fill offline table for dataProvider: ${dataBook.dataProvider}");
        }

        progressUpdate?.call(dataBooks.indexOf(dataBook) + 1, dataBooks.length);

        for (var entry in dataBook.records.entries) {
          Map<String, dynamic> rowData = {};
          entry.value.asMap().forEach((key, value) {
            if (key < dataBook.metaData!.columnDefinitions.length) {
              var columnName = dataBook.metaData!.columnDefinitions[key].name;
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
    _checkStatus();
    return offlineDatabase!.dropTables(IConfigService().currentApp.value!);
  }

  Future<Map<String, List<Map<String, Object?>>>> getChangedRows(String dataProvider) {
    _checkStatus();
    return offlineDatabase!.getChangedRows(dataProvider);
  }

  Future<int> resetState(String dataProvider, Map<String, Object?> resetRow) {
    _checkStatus();
    return offlineDatabase!.resetState(dataProvider, resetRow);
  }

  @override
  Future<ApiInteraction> sendRequest(ApiRequest request, [bool? retryRequest]) async {
    _checkStatus();

    ApiResponse? response;

    if (request is ApiDalSaveRequest) {
      // Does nothing but is supported as api
    } else if (request is ApiDeleteRecordRequest) {
      response = await _delete(request);
    } else if (request is ApiFetchRequest) {
      response = await _fetch(request);
    } else if (request is ApiReloadDataRequest) {
      response = await _reload(request);
    } else if (request is ApiFilterRequest) {
      response = await _filter(request);
    } else if (request is ApiInsertRecordRequest) {
      response = await _insert(request);
    } else if (request is ApiSetValuesRequest) {
      response = await _setValues(request);
    } else if (request is ApiSelectRecordRequest) {
      response = await _select(request);
    } else {
      throw Exception("${request.runtimeType} is not supported while offline");
    }

    return ApiInteraction(responses: response != null ? [response] : [], request: request);
  }

  void _checkStatus() {
    if (isStopped()) throw Exception("Repository not initialized");
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<DalFetchResponse?> _delete(ApiDeleteRecordRequest request) async {
    List<FilterCondition> filters = [];

    FilterCondition? requestFilter = _getFilter(request.filter, null);
    if (requestFilter != null) {
      filters.add(requestFilter);
    }

    if (filters.isEmpty && request.rowNumber != null) {
      filters.add(FilterCondition(columnName: "ROWID", value: request.rowNumber));
    }

    // Fallback
    if (filters.isEmpty) {
      Filter? selectedRowFilter = _createSelectedRowFilter(dataProvider: request.dataProvider);
      if (selectedRowFilter != null) {
        filters.add(selectedRowFilter.asFilterCondition());
      } else {
        // Cancel when no filter
        return _reFetchMaximum(request.dataProvider);
      }
    }

    FilterCondition? lastFilter = _getLastFilter(request.dataProvider);
    if (lastFilter != null) {
      filters.add(lastFilter);
    }

    await offlineDatabase!.delete(
      tableName: request.dataProvider,
      filter: FilterCondition(conditions: filters),
    );

    // JVx Server does also ignore fetch and always fetches.
    // if (request.fetch) {

    await DataBook.deselectRecord(dataProvider: request.dataProvider);

    return _reFetchMaximum(request.dataProvider);
    // }
  }

  Future<DalFetchResponse?> _fetch(ApiFetchRequest request) async {
    return _fetchData(request.dataProvider, request.fromRow, request.rowCount);
  }

  Future<DalFetchResponse?> _reload(ApiReloadDataRequest request) async {
    return _fetchData(request.dataProvider, request.fromRow, request.rowCount);
  }

  Future<DalFetchResponse?> _fetchData(String dataProvider, int fromRow, int rowCount) async {
    if (fromRow <= -1) {
      return null;
    }

    int? rowCount_ = rowCount >= 0 ? rowCount : null;

    if (rowCount_ == null) {
      _dataBookFetchMap[dataProvider] = -1;
    } else {
      int currentMaxFetch = _dataBookFetchMap[dataProvider] ?? 0;

      int maxFetch = fromRow + rowCount_;

      if (currentMaxFetch != -1 && currentMaxFetch < maxFetch) {
        _dataBookFetchMap[dataProvider] = maxFetch;
      }
    }

    FilterCondition? filter = _getLastFilter(dataProvider);

    DataBook dataBook = IDataService().getDataBook(dataProvider)!;

    List<String> columnNames = dataBook.metaData!.columnDefinitions.map((e) => e.name).toList();

    List<Map<String, dynamic>> selectionResult = await offlineDatabase!.select(
      columns: columnNames,
      tableName: dataProvider,
      offset: fromRow > 0 ? fromRow : null,
      limit: rowCount_,
      filter: filter,
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
      tableName: dataProvider,
      filter: filter,
    );

    bool isAllFetched = rowCountDatabase <= sortedMap.length;

    return DalFetchResponse(
      dataProvider: dataProvider,
      from: fromRow,
      selectedRow: dataBook.selectedRow,
      isAllFetched: isAllFetched,
      columnNames: columnNames,
      to: fromRow + (sortedMap.length - 1),
      records: sortedMap,
      name: "dal.fetch",
    );
  }

  Future<DalFetchResponse?> _filter(ApiFilterRequest request) async {
    if (request.columnNames != null) {
      Filter filter = Filter(
        values: request.columnNames!.map((e) => request.value).toList(),
        columnNames: request.columnNames!,
      );

      _dataBookLastFilter[request.dataProvider] = filter;
    } else if ((request.filter?.isEmpty ?? true) && request.filterCondition == null) {
      _dataBookLastFilter.remove(request.dataProvider);
    } else {
      _dataBookLastFilter[request.dataProvider] = request.filterCondition ?? request.filter!;
    }

    return _reFetchMaximum(request.dataProvider);
  }

  Future<ApiResponse?> _insert(ApiInsertRecordRequest request) async {
    await offlineDatabase!.insert(tableName: request.dataProvider, insert: {});

    return _reFetchMaximum(request.dataProvider);
  }

  DalDataProviderChangedResponse _deselect(String dataProvider) {
    return DalDataProviderChangedResponse.fromJson(
      {
        ApiObjectProperty.name: ApiResponseNames.dalDataProviderChanged,
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.selectedRow: -1,
        ApiObjectProperty.selectedColumn: null,
      },
    );
  }

  Future<DalDataProviderChangedResponse?> _select(ApiSelectRecordRequest request) async {
    if (request.filter == null) {
      if (request.rowNumber != null && request.rowNumber! < 0) {
        return _deselect(request.dataProvider);
      } else {
        // Cancel when no filter
        throw Exception("A filter is required!");
      }
    }

    Filter selectionFilter = request.filter!;

    var filterColumns = selectionFilter.columnNames;
    var filterValues = selectionFilter.values;

    if (filterColumns.isEmpty && filterValues.isEmpty) {
      throw Exception("A filter is required!");
    }

    DataBook dataBook = IDataService().getDataBook(request.dataProvider)!;

    //no specific filter columns -> we support using the PK columns
    if (filterColumns.isEmpty) {
      filterColumns = dataBook.metaData!.primaryKeyColumns;
    }

    if (filterColumns.length != filterValues.length) {
      throw Exception("The filter doesn't contain enough values to search with primary key!");
    }

    List<String> columnNames = dataBook.metaData!.columnDefinitions.map((e) => e.name).toList();

    List<Map<String, dynamic>> selectionResult = await offlineDatabase!.select(
      columns: columnNames,
      tableName: request.dataProvider,
      offset: 0,
      limit: -1,
      filter: _getLastFilter(request.dataProvider),
    );

    int iFoundRow = -1;

    if (selectionResult.isNotEmpty) {
      if (request.rowNumber != null && selectionResult.length > request.rowNumber!) {
        /// check if every value of the selected result at this row number fulfills all values provided by the filter
        bool bFound = true;
        var rowToCheck = selectionResult[request.rowNumber!];
        for (int i = 0; i < filterColumns.length && bFound; i++) {
          bFound = rowToCheck[filterColumns[i]] == filterValues[i];
        }

        if (bFound) {
          iFoundRow = request.rowNumber!;
        }
      }

      if (iFoundRow < 0) {
        bool bFound = false;
        for (int rowIndex = 0; rowIndex < selectionResult.length && !bFound; rowIndex++) {
          bFound = true;
          var rowToCheck = selectionResult[request.rowNumber!];
          for (int i = 0; i < filterColumns.length && bFound; i++) {
            bFound = rowToCheck[filterColumns[i]] == filterValues[i];
          }

          if (bFound) {
            iFoundRow = request.rowNumber!;
          }
        }
      }
    }

    if (iFoundRow < 0) {
      throw Exception("Record not found in databook, with [${Map.fromIterables(filterColumns, filterValues)}]");
    }

    return DalDataProviderChangedResponse.fromJson(
      {
        ApiObjectProperty.name: ApiResponseNames.dalDataProviderChanged,
        ApiObjectProperty.dataProvider: request.dataProvider,
        ApiObjectProperty.selectedRow: iFoundRow,
        if (request.selectedColumn != null) ApiObjectProperty.selectedColumn: request.selectedColumn,
      },
    );
  }

  Future<DalFetchResponse?> _setValues(ApiSetValuesRequest request) async {
    List<FilterCondition> filters = [];

    FilterCondition? requestFilter = _getFilter(request.filter, null);
    if (requestFilter != null) {
      filters.add(requestFilter);
    }

    // Fallback
    if (filters.isEmpty) {
      Filter? selectedRowFilter = _createSelectedRowFilter(dataProvider: request.dataProvider);
      if (selectedRowFilter != null) {
        filters.add(selectedRowFilter.asFilterCondition());
      } else {
        // Cancel when no filter
        return _reFetchMaximum(request.dataProvider);
      }
    }

    FilterCondition? lastFilter = _getLastFilter(request.dataProvider);
    if (lastFilter != null) {
      filters.add(lastFilter);
    }

    Map<String, dynamic> updateData = {};
    for (int i = 0; i < request.columnNames.length; i++) {
      updateData[request.columnNames[i]] = request.values[i];
    }

    await offlineDatabase!.update(
      tableName: request.dataProvider,
      update: updateData,
      filter: FilterCondition(conditions: filters),
    );

    return _reFetchMaximum(request.dataProvider);
  }

  FilterCondition? _getLastFilter(String dataProvider) {
    return _getFilter(
      cast(_dataBookLastFilter[dataProvider]),
      cast(_dataBookLastFilter[dataProvider]),
    );
  }

  Future<DalFetchResponse?> _reFetchMaximum(String dataProvider) async {
    int? maxFetch = _dataBookFetchMap[dataProvider];
    if (maxFetch != null) {
      return _fetch(
        ApiFetchRequest(
          fromRow: 0,
          rowCount: maxFetch,
          dataProvider: dataProvider,
          includeMetaData: true,
        ),
      );
    }

    return null;
  }

  FilterCondition? _getFilter(Filter? filter, FilterCondition? filterCondition) {
    if (filterCondition != null) {
      return filterCondition;
    } else if (!(filter?.isEmpty ?? true)) {
      // Not null and not empty
      return filter!.asFilterCondition();
    }
    return null;
  }

  Filter? _createSelectedRowFilter({required String dataProvider, int? selectedRow}) {
    DataBook dataBook = IDataService().getDataBook(dataProvider)!;

    DataRecord? dataRecord = dataBook.getRecord(
      dataColumnNames: dataBook.metaData!.primaryKeyColumns,
      recordIndex: selectedRow ?? dataBook.selectedRow,
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
