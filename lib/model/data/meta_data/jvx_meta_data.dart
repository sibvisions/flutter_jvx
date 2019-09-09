import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data_column.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data_data_provider.dart';

class JVxMetaData {
  String dataProvider;
  String name;
  List<JVxMetaDataDataProvider> detailDataProviders;
  bool deleteEnabled;
  bool updateEnabled;
  List<JVxMetaDataColumn> columns;

  JVxMetaData({this.dataProvider, this.name, this.columns, this.detailDataProviders, this.deleteEnabled, this.updateEnabled});

  JVxMetaData.fromJson(Map<String, dynamic> json) {
    dataProvider = json['dataProvider'];
    name = json['name'];
    if (json['detailDataProviders'] != null) detailDataProviders = json['detailDataProviders'].forEach((dp) => JVxMetaDataDataProvider.fromJson(dp));
    deleteEnabled = json['deleteEnabled'];
    updateEnabled = json['updateEnabled'];
    if (json['columns'] != null) columns = json['columns'].forEach((c) => JVxMetaDataColumn.fromJson(c));
  }
}