import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../models/api/requests/data/delete_record_request.dart';
import '../../../services/repository/api_repository.dart';

import '../../../../injection_container.dart';
import '../../../models/api/errors/failure.dart';
import '../../../models/api/request.dart';
import '../../../models/api/requests/data/fetch_data_request.dart';
import '../../../models/api/requests/data/filter_data_request.dart';
import '../../../models/api/requests/data/insert_record_request.dart';
import '../../../models/api/requests/data/save_data_request.dart';
import '../../../models/api/requests/data/select_record_request.dart';
import '../../../models/api/requests/data/set_values_request.dart';
import '../../../models/api/requests/upload_request.dart';
import '../../../models/api/response_objects/response_data/data/data_book.dart';
import '../../../models/api/response_objects/response_data/data/dataprovider_changed.dart';
import '../../../models/api/response_objects/response_data/data/filter.dart';
import '../../../models/api/response_objects/response_data/data/filter_condition.dart';
import '../../../models/api/response_objects/response_data/meta_data/data_book_meta_data.dart';
import '../../../models/api/response_objects/response_data/meta_data/data_book_meta_data_column.dart';
import '../../../models/state/app_state.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/app/text_utils.dart';
import '../../util/inherited_widgets/app_state_provider.dart';
import 'so_data_screen.dart';

typedef ContextCallback = void Function(BuildContext);

typedef ContextValueCallback = void Function(BuildContext, dynamic);

class SoComponentData {
  String dataProvider;
  bool isFetchingMetaData = false;
  bool isFetching = false;

  DataBook? data;
  DataBookMetaData? metaData;
  SoDataScreen soDataScreen;

  List<ContextCallback> _onDataChanged = [];
  List<VoidCallback> _onMetaDataChanged = [];
  List<ContextValueCallback> _onSelectedRowChanged = [];

  SoComponentData({required this.dataProvider, required this.soDataScreen});

  bool get deleteEnabled => metaData?.deleteEnabled ?? false;

  bool get updateEnabled => metaData?.updateEnabled ?? false;

  bool get insertEnabled => metaData?.insertEnabled ?? false;

  List<String>? get primaryKeyColumns => metaData?.primaryKeyColumns;

  List<dynamic>? primaryKeyColumnsForRow(int index) {
    if (metaData != null && metaData!.primaryKeyColumns != null) {
      return data!.getRow(index, primaryKeyColumns!);
    }
    return null;
  }

  void updateData(BuildContext? context, DataBook pData,
      [bool? overrideData = false]) {
    if (data == null || (overrideData != null && overrideData)) {
      if (data != null && data!.selectedRow != pData.selectedRow) {
        if (context != null)
          _onSelectedRowChanged.forEach((d) => d(context, pData.selectedRow));
      }

      data = pData;
    } else if (true) {
      if (pData.records.length > 0) {
        for (int i = pData.from ?? 0; i <= (pData.to ?? 0); i++) {
          List<dynamic> record = pData.records[(i - pData.from!)];
          String recordState = record[record.length - 1] ?? '';

          if ((i - pData.from!) < data!.records.length &&
              i < data!.records.length) {
            if (recordState == 'I' && data!.selectedRow != pData.selectedRow) {
              data!.records
                  .insert((i - pData.from!), pData.records[(i - pData.from!)]);
            } else if ((recordState != 'I' &&
                    (pData.from == pData.to &&
                        data!.records[pData.from!] != null)) ||
                (recordState == 'I' &&
                    data!.selectedRow == pData.selectedRow &&
                    (pData.from == pData.to &&
                        data!.records[pData.from!] != null))) {
              data!.records[i] = pData.records[(i - pData.from!)];
            } else if (recordState == 'D') {
              data!.records.removeAt((i - pData.from!));
            }
          } else {
            data!.records.add(pData.records[(i - pData.from!)]);
          }
        }
      }

      if (pData.isAllFetched != null) {
        data!.isAllFetched = pData.isAllFetched;
      } else if (data!.isAllFetched == null) {
        data!.isAllFetched = false;
      }

      if (data!.selectedRow != pData.selectedRow && context != null) {
        _onSelectedRowChanged.forEach((d) => d(context, pData.selectedRow));
      }

      data!.selectedRow = pData.selectedRow;
    }

    if (data!.selectedRow == null) data!.selectedRow = 0;

    isFetching = false;
    if (context != null) _onDataChanged.forEach((d) => d(context));
  }

  void updateDataProviderChanged(BuildContext context, DataproviderChanged pDataProviderChanged, [Request? request]) {
    DataBook? dataBook = data;
    if(pDataProviderChanged.reload == -1){
      if(dataBook != null){
        dataBook.records.clear();
      }
    }
    //  DataProviderChanged
    //    ChangedValues - if not - Reload
    List<dynamic>? tempChangedValues = pDataProviderChanged.changedValues;
    List<String>? tempColumnNames = pDataProviderChanged.changedColumnNames;
    int? tempSelectedRow = pDataProviderChanged.selectedRow;
    if(tempChangedValues != null && tempColumnNames != null &&  dataBook != null && tempSelectedRow != null){
      List<dynamic> rowToUpdate = dataBook.getRow(tempSelectedRow, tempColumnNames);
      for(int i = 0; i<rowToUpdate.length; i++){
        rowToUpdate[i] = tempChangedValues[i];
      }
      dataBook.records[tempSelectedRow] = rowToUpdate;
    } else if (pDataProviderChanged.reload != null)
      fetchData(pDataProviderChanged.reload, -1);

    //    SelectedRow
    if (data != null && pDataProviderChanged.selectedRow != null)
      updateSelectedRow(context, pDataProviderChanged.selectedRow!, true);
  }

  void updateSelectedRow(BuildContext context, int selectedRow,
      [bool raiseSelectedRowChangeEvent = false]) {
    if (data != null) {
      _onDataChanged.forEach((d) => d(context));

      if (data!.selectedRow == null || data!.selectedRow != selectedRow) {
        data!.selectedRow = selectedRow;

        if (raiseSelectedRowChangeEvent) {
          _onSelectedRowChanged.forEach((d) => d(context, selectedRow));
        }
      } else {
        print(
            "ComponentData tries to update selectedRow, but data object was null! DataProvider: " +
                this.dataProvider);
      }
    }
  }

  void updateMetaData(DataBookMetaData pMetaData) {
    metaData = pMetaData;
    isFetchingMetaData = false;
    _onMetaDataChanged.forEach((d) => d());
  }

  dynamic getColumnData(BuildContext? context, String columnName) {
    if (data != null &&
        data!.selectedRow != null &&
        data!.selectedRow! < data!.records.length) {
      return _getColumnValue(columnName);
    } else {
      fetchData(null, -1);
    }

    return "";
  }

  DataBook? getData(BuildContext context, int rowCountNeeded) {
    if (!isFetching && (data == null || !data!.isAllFetched!)) {
      if (rowCountNeeded >= 0 &&
          data != null &&
          data!.records.length >= rowCountNeeded) {
        return data!;
      }

      if (!isFetching) {
        fetchData(null, rowCountNeeded);
      }
    }

    return data;
  }

  void reloadData(){
    if(data != null){
      fetchData(-1, -1);
    }
  }

  void selectRecord(BuildContext context, int index, [bool fetch = false]) {
    if (index < data!.records.length) {
      SelectRecordRequest select =
          getSelectRecordRequest(context, index, fetch);

      if (TextUtils.unfocusCurrentTextfield(context)) {
        select.soComponentData = this;
        soDataScreen.requestQueue.add(select);
      } else {
        sl<ApiCubit>().data(select);
      }
    } else {
      throw IndexError(index, data!.records, "Select Record",
          "Select record failed. Index out of bounds!");
    }
  }

  void insertRecord(BuildContext context, [SetValuesRequest? setValues]) {
    if (insertEnabled) {
      InsertRecordRequest insertRecord = InsertRecordRequest(
          dataProvider: dataProvider,
          clientId: AppStateProvider.of(context)!
              .appState
              .applicationMetaData!
              .clientId,
          setValues: setValues);

      sl<ApiCubit>().data(insertRecord);
    }
  }

  void deleteRecord(BuildContext context, int index, [Filter? filter]) {
    if (index < data!.records.length) {
      DeleteRecordRequest request = DeleteRecordRequest(
          dataProvider: dataProvider,
          filter: filter != null
              ? filter
              : Filter(
                  columnNames: primaryKeyColumns,
                  values: data!.getRow(index, primaryKeyColumns)),
          selectedRow: filter != null ? -1 : index,
          clientId: AppStateProvider.of(context)!
              .appState
              .applicationMetaData!
              .clientId);

      sl<ApiCubit>().data(request);
    } else {
      throw IndexError(index, data!.records, "Delete Record",
          "Delete record failed. Index out of bounds!");
    }
  }

  void saveData(BuildContext context) {
    SaveDataRequest saveDataRequest = SaveDataRequest(
      dataProvider: dataProvider,
      clientId:
          AppStateProvider.of(context)!.appState.applicationMetaData!.clientId,
    );

    sl<ApiCubit>().data(saveDataRequest);
  }

  void filterData(
      String value, String editorComponentId, List<String>? columnNames) {
    FilterDataRequest request = FilterDataRequest(
        columnNames: columnNames,
        dataProvider: dataProvider,
        value: value,
        editorComponentId: editorComponentId,
        clientId: sl<AppState>().applicationMetaData!.clientId,
        fromRow: 0,
        rowCount: 100,
        reload: true);

    sl<ApiCubit>().data(request);
  }

  void filterDataExtended(
      BuildContext context, int? reload, int? rowCountedNeeded,
      [Filter? filter,
      FilterCondition? filterCondition,
      bool showLoading = true]) {
    isFetching = true;
    FilterDataRequest filterDataRequest = FilterDataRequest(
        dataProvider: dataProvider,
        value: null,
        editorComponentId: null,
        clientId: sl<AppState>().applicationMetaData?.clientId ?? '',
        reload: (reload == -1),
        condition: filterCondition,
        showLoading: showLoading);

    if (reload != null && reload >= 0) {
      filterDataRequest.fromRow = reload;
      filterDataRequest.rowCount = 1;
    } else if (reload != null && reload == -1 && rowCountedNeeded != -1) {
      filterDataRequest.fromRow = 0;
      filterDataRequest.rowCount = rowCountedNeeded! - data!.records.length;
    } else if (data != null && data!.isAllFetched! && rowCountedNeeded != -1) {
      filterDataRequest.fromRow = data!.records.length;
      filterDataRequest.rowCount = rowCountedNeeded! - data!.records.length;
    }

    filterDataRequest.filter = filter;

    if (metaData == null) {
      filterDataRequest.includeMetaData = true;
      isFetchingMetaData = true;
    }

    sl<ApiCubit>().data(filterDataRequest);
  }

  Future<void> setValues(BuildContext context, List<dynamic> values,
      [List<dynamic>? columnNames,
      Filter? filter,
      bool isTextField = false]) async {
    SetValuesRequest setValues = SetValuesRequest(
        columnNames: columnNames ?? data!.columnNames,
        dataProvider: dataProvider,
        values: values,
        clientId: AppStateProvider.of(context)!
            .appState
            .applicationMetaData!
            .clientId,
        offlineSelectedRow: data?.selectedRow);

    if (columnNames != null) {
      columnNames.asMap().forEach((i, f) {
        if (i < values.length &&
            (filter == null || data?.selectedRow == filter.values![0]) &&
            f != null) {
          _setColumnValue(f, values[i]);
        }
      });

      setValues.columnNames = columnNames;
    }

    if (filter != null) {
      setValues.filter = filter;
    } else if (data != null &&
        data!.selectedRow != null &&
        data!.selectedRow! >= 0) {
      final values = data!.getRow(data!.selectedRow, primaryKeyColumns);

      if (values != null && values.isNotEmpty) {
        setValues.filter = Filter(
            compareOperator: [FilterCompareOperator.EQUAL],
            columnNames: primaryKeyColumns,
            values: values);
      }
    }

    setValues.offlineSelectedRow = data?.selectedRow;

    if (!isTextField) {
      TextUtils.unfocusCurrentTextfield(context);

      Future.delayed(const Duration(milliseconds: 100), () async {
        await sl<ApiCubit>().data(setValues);
      });
    } else {
      await sl<ApiCubit>().data(setValues);
    }
  }

  dynamic _getColumnValue(String columnName) {
    int? columnIndex = _getColumnIndex(columnName);

    if (columnIndex != null &&
        columnIndex >= 0 &&
        data!.selectedRow! >= 0 &&
        data!.selectedRow! < data!.records.length) {
      dynamic value = data!.records[data!.selectedRow!][columnIndex];
      if (value is String)
        return value;
      else
        return value;
    }

    return "";
  }

  void _setColumnValue(String columnName, dynamic value) {
    int? columnIndex = _getColumnIndex(columnName);
    if (columnIndex != null &&
        data!.selectedRow != null &&
        data!.selectedRow! >= 0 &&
        data!.selectedRow! < data!.records.length &&
        columnIndex >= 0) {
      data!.records[data!.selectedRow!][columnIndex] = value;
    }
  }

  int? _getColumnIndex(String columnName) {
    return data?.columnNames.indexWhere((c) => c == columnName);
  }

  DataBookMetaDataColumn? getMetaDataColumn(String columnName) {
    try {
      return metaData!.columns!.firstWhere((col) => col.name == columnName);
    } catch (e) {
      return null;
    }
  }

  void fetchData(int? reload, int rowCountNeeded, [Filter? filter]) {
    isFetching = true;

    FetchDataRequest fetch = FetchDataRequest(
        dataProvider: dataProvider,
        clientId: sl<AppState>().applicationMetaData!.clientId,
        reload: (reload == -1));

    if (reload != null && reload >= 0) {
      fetch.fromRow = reload;
      fetch.rowCount = 1;
    } else if (reload == -1 && rowCountNeeded == -1) {
      fetch.fromRow = 0;
      fetch.rowCount =
          rowCountNeeded - (data != null ? data!.records.length : 0);
    } else if (data != null &&
        data!.isAllFetched != null &&
        !data!.isAllFetched!) {
      fetch.fromRow = data!.records.length;
      fetch.rowCount = rowCountNeeded - data!.records.length;
    }

    fetch.filter = filter;

    if (metaData == null) {
      fetch.includeMetaData = true;
      isFetchingMetaData = true;
    }

    sl<ApiCubit>().data(fetch);
  }

  SelectRecordRequest getSelectRecordRequest(BuildContext context, int index,
      [bool fetch = false]) {
    SelectRecordRequest select = SelectRecordRequest(
        dataProvider: dataProvider,
        filter: Filter(
            columnNames: this.primaryKeyColumns ?? data?.columnNames,
            values: data!.getRow(index, this.primaryKeyColumns)),
        selectedRow: index,
        clientId: AppStateProvider.of(context)!
            .appState
            .applicationMetaData!
            .clientId,
        fetch: fetch);

    return select;
  }

  Future<ApiState?> fetchAll(
      ApiRepository repository, int recordsPerRequest) async {
    ApiState? result;
    log('Start fetching all records for ${this.dataProvider}.');

    if (data != null) {
      data!.isAllFetched = false;
      data!.records = <dynamic>[];
    }

    if (data == null || data!.isAllFetched == null || !data!.isAllFetched!) {
      bool reload = true;
      isFetching = true;

      while ((data == null ||
              data!.isAllFetched == null ||
              !data!.isAllFetched!) &&
          result == null) {
        result = await _fetchAllSingle(repository, recordsPerRequest, reload);
        reload = false;
        if (result != null) break;
      }
    }

    if (result == null)
      log('Finished fetching all records for ${this.dataProvider}. Records: ${data!.records.length}');
    else if (result is ApiResponse && result.hasError)
      log('Finished fetching all records for ${this.dataProvider} with error: ${result.getObjectByType<Failure>()!.message}');
    else if (result is ApiError && result.failures.isNotEmpty)
      log('Finished fetching all records for ${this.dataProvider} with error: ${result.failures.first.message}');

    return result;
  }

  Future<ApiState?> _fetchAllSingle(
      ApiRepository repository, int recordsPerRequest, bool reload) async {
    ApiState? result;
    if (reload && data != null) data!.records = [];
    FetchDataRequest fetch = FetchDataRequest(
        dataProvider: dataProvider,
        clientId: sl<AppState>().applicationMetaData!.clientId,
        reload: reload,
        fromRow: reload ? 0 : data!.records.length,
        rowCount: recordsPerRequest,
        includeMetaData: reload);

    List<ApiState> states = await repository.data(fetch);

    if (states.isNotEmpty && states.first is ApiResponse) {
      ApiResponse response = states.first as ApiResponse;

      if (response.hasError)
        result = response;
      else {
        for (final m in response.getAllObjectsByType<DataBookMetaData>()) {
          if (m.dataProvider == this.dataProvider) this.updateMetaData(m);
        }

        for (final d in response.getAllObjectsByType<DataBook>()) {
          if (d.dataProvider == this.dataProvider) {
            if (d.records.length == 0) {
              if (data == null) this.data = d;
              data!.isAllFetched = true;
            } else
              updateData(null, d);
          }
        }
      }
    } else if (states.first is ApiError) {
      result = states.first;
    }
    return result;
  }

  void registerSelectedRowChanged(ContextValueCallback callback) {
    if (!_onSelectedRowChanged.contains(callback))
      _onSelectedRowChanged.add(callback);
  }

  void unregisterSelectedRowChanged(ContextValueCallback callback) {
    _onSelectedRowChanged.remove(callback);
  }

  void registerDataChanged(ContextCallback callback) {
    if (!_onDataChanged.contains(callback)) _onDataChanged.add(callback);
  }

  void unregisterDataChanged(ContextCallback callback) {
    _onDataChanged.remove(callback);
  }

  void registerMetaDataChanged(VoidCallback callback) {
    if (!_onMetaDataChanged.contains(callback))
      _onMetaDataChanged.add(callback);
  }

  void unregisterMetaDataChanged(VoidCallback callback) {
    _onMetaDataChanged.remove(callback);
  }
}
