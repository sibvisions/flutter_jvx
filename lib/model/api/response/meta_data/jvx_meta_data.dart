import '../../../../model/api/response/response_object.dart';

import 'jvx_meta_data_column.dart';
import 'jvx_meta_data_data_provider.dart';

class JVxMetaData extends ResponseObject {
  String dataProvider;
  List<JVxMetaDataDataProvider> detailDataProviders = <JVxMetaDataDataProvider>[];
  bool deleteEnabled;
  bool updateEnabled;
  bool insertEnabled;
  List<JVxMetaDataColumn> columns = <JVxMetaDataColumn>[];
  List<String> primaryKeyColumns = <String>[];
  List<String> tableColumnView;

  JVxMetaData({this.dataProvider, this.columns, this.detailDataProviders, this.deleteEnabled, this.updateEnabled});

  JVxMetaData.fromJson(Map<String, dynamic> json) {
    dataProvider = json['dataProvider'];
    if (json['detailDataProviders'] != null) 
      json['detailDataProviders'].forEach((dp) => detailDataProviders.add(JVxMetaDataDataProvider.fromJson(dp)));
    deleteEnabled = json['deleteEnabled'];
    updateEnabled = json['updateEnabled'];
    insertEnabled = json['insertEnabled'];
    if (json['primaryKeyColumns'] != null) 
      primaryKeyColumns = List<String>.from(json['primaryKeyColumns']);
    if (json['columns'] != null) 
      json['columns'].forEach((c) => columns.add(JVxMetaDataColumn.fromJson(c)));
    super.name = json['name'];
    super.componentId = json['componentId'];
    if (json['columnView.table'] != null) tableColumnView = List<String>.from(json['columnView.table']);
  }
}