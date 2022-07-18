import 'package:flutter_client/src/mixin/data_service_mixin.dart';
import 'package:flutter_client/src/service/api/shared/repository/offline/offline_database.dart';

import '../../../../model/api/requests/i_api_request.dart';
import '../../../../model/api/response/api_response.dart';
import '../../../../model/config/api/api_config.dart';
import '../i_repository.dart';

class OfflineApiRepository with DataServiceGetterMixin implements IRepository {
  late OfflineDatabase _offlineDatabase;

  startDatabase() async {
    var dataBooks = getDataService().getDataBooks();
    _offlineDatabase = await OfflineDatabase.open();

    var dalMetaData = dataBooks.map((e) => e.metaData!).toList(growable: false);
    //Drop old data + possible old scheme
    _offlineDatabase.dropTables(dalMetaData);
    _offlineDatabase.createTables(dalMetaData);

    // await offlineDatabase.db.transaction((txn) {
    for (var dataBook in dataBooks) {
      for (var entry in dataBook.records.entries) {
        Map<String, dynamic> rowData = {};
        entry.value.asMap().forEach((key, value) {
          if (key < dataBook.columnDefinitions.length) {
            var columnName = dataBook.columnDefinitions[key].name;
            rowData[columnName] = value;
          }
        });
        if (rowData.isNotEmpty) {
          _offlineDatabase.rawInsert(pTableName: dataBook.dataProvider, pInsert: rowData);
        }
      }
    }
    print("done inserting offline data");
    // });
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
