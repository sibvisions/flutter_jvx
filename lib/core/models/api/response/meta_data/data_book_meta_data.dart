import '../../response_object.dart';

import 'data_book_meta_data_column.dart';
import 'data_book_meta_data_provider.dart';

class DataBookMetaData extends ResponseObject {
  String dataProvider;
  List<DataBookMetaDataProvider> detailDataProviders =
      <DataBookMetaDataProvider>[];
  bool readOnly;
  bool deleteEnabled;
  bool updateEnabled;
  bool insertEnabled;
  List<DataBookMetaDataColumn> columns = <DataBookMetaDataColumn>[];
  List<String> primaryKeyColumns = <String>[];
  List<String> tableColumnView;

  DataBookMetaData(
      {this.dataProvider,
      this.columns,
      this.detailDataProviders,
      this.deleteEnabled,
      this.updateEnabled});

  DataBookMetaData.fromJson(Map<String, dynamic> json) {
    dataProvider = json['dataProvider'];
    if (json['detailDataProviders'] != null)
      json['detailDataProviders'].forEach((dp) =>
          detailDataProviders.add(DataBookMetaDataProvider.fromJson(dp)));
    readOnly = json['readOnly'];
    deleteEnabled = json['deleteEnabled'];
    updateEnabled = json['updateEnabled'];
    insertEnabled = json['insertEnabled'];
    if (json['primaryKeyColumns'] != null)
      primaryKeyColumns = List<String>.from(json['primaryKeyColumns']);
    if (json['columns'] != null)
      json['columns']
          .forEach((c) => columns.add(DataBookMetaDataColumn.fromJson(c)));
    super.name = json['name'];
    super.componentId = json['componentId'];
    if (json['columnView.table'] != null)
      tableColumnView = List<String>.from(json['columnView.table']);
  }
}
