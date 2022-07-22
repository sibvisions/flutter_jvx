import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/service/api/shared/repository/offline/offline_database.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import '../../../../model/api/requests/i_api_request.dart';
import '../../../../model/api/response/api_response.dart';
import '../../../../model/config/api/api_config.dart';
import '../i_repository.dart';

class OfflineApiRepository with DataServiceGetterMixin implements IRepository {
  late OfflineDatabase _offlineDatabase;

  OfflineApiRepository._();

  static Future<OfflineApiRepository> create() async {
    var offlineApiRepository = OfflineApiRepository._();
    offlineApiRepository._offlineDatabase = await OfflineDatabase.open();
    return offlineApiRepository;
  }

  startDatabase(void Function(int value, int max, {int? progress})? progressUpdate) async {
    var dataBooks = getDataService().getDataBooks().values.toList(growable: false);

    var dalMetaData = dataBooks.map((e) => e.metaData!).toList(growable: false);
    //Drop old data + possible old scheme
    await _offlineDatabase.dropTables(dalMetaData);
    _offlineDatabase.createTables(dalMetaData);

    log("Sum of all dataBook entries: " +
        dataBooks.map((e) => e.records.entries.length).reduce((value, element) => value + element).toString());

    await _offlineDatabase.db.transaction((txn) async {
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
            await _offlineDatabase.rawInsert(pTableName: dataBook.dataProvider, pInsert: rowData, txn: txn);
          }

          progressUpdate?.call(dataBooks.indexOf(dataBook) + 1, dataBooks.length,
              progress: (entry.key / dataBook.records.length * 100).toInt());
        }
      }
    });

    log("done inserting offline data");
  }

  Future<Map<String, List<Map<String, Object?>>>> getChangedRows(String pDataProvider) {
    return _offlineDatabase.getChangedRows(pDataProvider);
  }

  stopDatabase() async {
    await _offlineDatabase.getMetaData().then((value) => _offlineDatabase.dropTables(value));
    await _offlineDatabase.close();
  }

  bool isStopped() {
    return _offlineDatabase.isClosed();
}

  @override
  Future<List<ApiResponse>> sendRequest({required IApiRequest pRequest}) {
    // TODO: implement sendRequest
    throw UnimplementedError();
  }

  @override
  void setApiConfig({required ApiConfig config}) {
    // TODO: implement setApiConfig
  }
}
