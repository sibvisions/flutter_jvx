import 'package:jvx_mobile_v3/model/api/response/response_object.dart';

import 'jvx_meta_data_column.dart';
import 'jvx_meta_data_data_provider.dart';

class JVxMetaData extends ResponseObject {
  String dataProvider;
  List<JVxMetaDataDataProvider> detailDataProviders;
  bool deleteEnabled;
  bool updateEnabled;
  List<JVxMetaDataColumn> columns;

  JVxMetaData({this.dataProvider, this.columns, this.detailDataProviders, this.deleteEnabled, this.updateEnabled});

  JVxMetaData.fromJson(Map<String, dynamic> json) {
    dataProvider = json['dataProvider'];
    if (json['detailDataProviders'] != null) detailDataProviders = json['detailDataProviders'].forEach((dp) => JVxMetaDataDataProvider.fromJson(dp));
    deleteEnabled = json['deleteEnabled'];
    updateEnabled = json['updateEnabled'];
    if (json['columns'] != null) columns = json['columns'].forEach((c) => JVxMetaDataColumn.fromJson(c));
    super.name = json['name'];
    super.componentId = json['componentId'];
  }
}