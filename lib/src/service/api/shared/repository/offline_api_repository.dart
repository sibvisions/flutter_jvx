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

  startDatabase(BuildContext context) async {
    var pd = ProgressDialog(context: context);
    pd.show(
      msg: "Loading data...",
      max: 100,
      progressType: ProgressType.valuable,
      barrierDismissible: false,
    );

    var dataBooks = getDataService().getDataBooks().values.toList(growable: false);
    _offlineDatabase = await OfflineDatabase.open();

    var dalMetaData = dataBooks.map((e) => e.metaData!).toList(growable: false);
    //Drop old data + possible old scheme
    await _offlineDatabase.dropTables(dalMetaData);
    _offlineDatabase.createTables(dalMetaData);

    log("Sum of all databook entries: " +
        dataBooks.map((e) => e.records.entries.length).reduce((value, element) => value + element).toString());

    await _offlineDatabase.db.transaction((txn) async {
      for (var dataBook in dataBooks) {
        pd.update(
          value: 0,
          msg: "Loading data (${dataBooks.indexOf(dataBook) + 1} / ${dataBooks.length})...",
        );

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
          pd.update(
            value: (entry.key / dataBook.records.length * 100).toInt(),
          );
        }
      }
    });
    pd.close();

    print("done inserting offline data");
  }

  stopDatabase(BuildContext context) async {
    await _offlineDatabase.getMetaData().then((value) => _offlineDatabase.dropTables(value));
    await _offlineDatabase.close();
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
