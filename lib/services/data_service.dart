import 'dart:convert';

import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/data/select_record_resp.dart';
import 'package:jvx_mobile_v3/model/open_screen/open_screen_resp.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';
import 'package:jvx_mobile_v3/utils/log.dart';

class DataService {
  RestClient restClient;

  DataService(this.restClient) : assert(restClient != null);
  
  Future<JVxData> getData(String dataProvider, String clientId, [List<dynamic> columnNames, int fromRow = -1, int rowCount = -1]) async {
    if (dataProvider == null || columnNames == null || columnNames.isEmpty)
      return null;

    var body = {
      'dataProvider': dataProvider,
      'columnNames': columnNames,
      'fromRow': fromRow,
      'rowCount': rowCount,
      'clientId': clientId
    };

    var result = await restClient.post('/api/dal/fetch', body).then((val) => val);

    JVxData jVxData = JVxData.fromJson(json.decode(result)[0]);

    Log.printLong(jVxData.records.toString());

    return jVxData;
  }

  getMetaData(String dataProvider, List<dynamic> columnNames) async {
    if (dataProvider == null)
      return null;

    var body = {
      'dataProvider': dataProvider,
      'columnNames': columnNames
    };

    return await restClient.post('/api/dal/metadata', body);
  }

  Future<SelectRecordResponse> selectRecord(String dataProvider, List columnNames, List values, bool fetch, String clientId) async {
    if (values == null || fetch == null || dataProvider == null)
      return null;

    var body = {
      'filter': {
        'values': values,
        'columnNames': columnNames,
      },
      'dataProvider': dataProvider,
      'fetch': fetch,
      'clientId': clientId,
    };

    var responseBody = (await restClient.post('/api/dal/selectRecord', body));

    return SelectRecordResponse.fromJson(json.decode(responseBody));
  }

  Future<OpenScreenResponse> setValues(String dataProvider, List columnNames, List values, String clientId, [List filterColumnNames, List filterValues]) async {
    if (dataProvider == null || columnNames == null || values == null)
      return null;

    var body = {
      'filter': {
        'columnNames': filterColumnNames,
        'values': filterValues
      },
      'dataProvider': dataProvider,
      'columnNames': columnNames,
      'values': values,
      'clientId': clientId,
    };

    OpenScreenResponse openScreenResponse = OpenScreenResponse.fromJson(json.decode(await restClient.post('/api/dal/setValues', body)));

    print(openScreenResponse.name);

    return openScreenResponse;
  }
}