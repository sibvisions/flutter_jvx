import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_dal_save_request.dart';
import 'package:flutter_client/src/model/api/requests/api_delete_record_request.dart';
import 'package:flutter_client/src/model/api/requests/api_fetch_request.dart';
import 'package:flutter_client/src/model/api/requests/api_filter_model.dart';
import 'package:flutter_client/src/model/api/requests/api_filter_request.dart';
import 'package:flutter_client/src/model/api/requests/api_insert_record_request.dart';
import 'package:flutter_client/src/model/api/requests/api_select_record_request.dart';
import 'package:flutter_client/src/model/api/requests/api_set_values_request.dart';
import 'package:flutter_client/src/service/api/shared/repository/offline/offline_database.dart';

import '../../../../model/api/requests/i_api_request.dart';
import '../../../../model/api/response/api_response.dart';
import '../../../../model/config/api/api_config.dart';
import '../i_repository.dart';

class OfflineApiRepository with DataServiceGetterMixin implements IRepository {
  OfflineDatabase? _offlineDatabase;

  @override
  Future<void> start() async {
    if (isStopped()) {
      _offlineDatabase = await OfflineDatabase.open();
    }
  }

  @override
  Future<void> stop() async {
    if (!isStopped()) {
      await _offlineDatabase!.close();
    }
  }

  @override
  bool isStopped() {
    return _offlineDatabase?.isClosed() ?? true;
  }

  /// Init database with currently available dataBooks
  Future<void> initDatabase(void Function(int value, int max, {int? progress})? progressUpdate) async {
    var dataBooks = getDataService().getDataBooks().values.toList(growable: false);

    var dalMetaData = dataBooks.map((e) => e.metaData!).toList(growable: false);
    //Drop old data + possible old scheme
    await _offlineDatabase!.dropTables(dalMetaData);
    _offlineDatabase!.createTables(dalMetaData);

    log("Sum of all dataBook entries: " +
        dataBooks.map((e) => e.records.entries.length).reduce((value, element) => value + element).toString());

    await _offlineDatabase!.db.transaction((txn) async {
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
            await _offlineDatabase!.rawInsert(pTableName: dataBook.dataProvider, pInsert: rowData, txn: txn);
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
    return _offlineDatabase!.getMetaData().then((value) => _offlineDatabase!.dropTables(value));
  }

  Future<Map<String, List<Map<String, Object?>>>> getChangedRows(String pDataProvider) {
    return _offlineDatabase!.getChangedRows(pDataProvider);
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
    } else if (pRequest is ApiSelectRecordRequest) {
      return _select(pRequest);
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

  Future<List<ApiResponse>> _delete(ApiDeleteRecordRequest pRequest) {
    Map<String, dynamic> filter = {};
    if (pRequest.filter != null) {
      ApiFilterModel requestFilter = pRequest.filter!;

      for (int i = 0; i < requestFilter.columnNames.length; i++) {
        filter[requestFilter.columnNames[i]] = requestFilter.values[i];
      }
    } else {
      filter["ROWID"] = pRequest.selectedRow;
    }

    _offlineDatabase!.delete(pTableName: pRequest.dataProvider, pFilter: filter);

    if (pRequest.fetch) {}

    return SynchronousFuture([]);
  }

  Future<List<ApiResponse>> _fetch(ApiFetchRequest pRequest) {
    return SynchronousFuture([]);
  }

  Future<List<ApiResponse>> _filter(ApiFilterRequest pRequest) {
    return SynchronousFuture([]);
  }

  Future<List<ApiResponse>> _insert(ApiInsertRecordRequest pRequest) {
    return SynchronousFuture([]);
  }

  Future<List<ApiResponse>> _select(ApiSelectRecordRequest pRequest) {
    return SynchronousFuture([]);
  }

  Future<List<ApiResponse>> _setValues(ApiSetValuesRequest pRequest) {
    return SynchronousFuture([]);
  }
}
