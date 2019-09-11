import 'package:jvx_mobile_v3/services/restClient.dart';

class DataService {
  RestClient restClient;

  DataService(this.restClient) : assert(restClient != null);
  
  getData(String dataProvider, List<String> columnNames, int fromRow, int rowCount) async {
    if (dataProvider == null || columnNames == null || columnNames.isEmpty)
      return null;

    var body = {
      'dataProvider': dataProvider,
      'columnNames': columnNames,
      'fromRow': fromRow,
      'rowCount': rowCount
    };

    return await restClient.post('/api/dal/fetch', body).then((val) => val);
  }

  getMetaData(String dataProvider, List<String> columnNames) async {
    if (dataProvider == null)
      return null;

    var body = {
      'dataProvider': dataProvider,
      'columnNames': columnNames
    };

    return await restClient.post('/api/dal/metadata', body);
  }

  selectRecord(String dataProvider, List columnNames, List values, bool fetch) async {
    if (values == null || fetch == null || dataProvider == null)
      return null;

    var body = {
      'filter': {
        'dataProvider': dataProvider,
        'columnNames': columnNames,
      },
      'values': values,
      'fetch': fetch
    };

    return await restClient.post('/api/dal/selectRecord', body);
  }

  setValues(String dataProvider, List columnNames, List values, List filterColumnNames, List filterValues) async {
    if (dataProvider == null || columnNames == null || values == null)
      return null;

    var body = {
      'filter': {
        'columnNames': filterColumnNames,
        'values': filterValues
      },
      'dataProvider': dataProvider,
      'columnNames': columnNames,
      'values': values
    };

    return await restClient.post('/api/dal/setValues', body);
  }
}