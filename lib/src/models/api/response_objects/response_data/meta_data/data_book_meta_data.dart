import '../../../response_object.dart';
import 'data_book_meta_data_column.dart';
import 'data_book_meta_data_provider.dart';

class DataBookMetaData extends ResponseObject {
  String? dataProvider;
  List<DataBookMetaDataProvider>? detailDataProviders =
      <DataBookMetaDataProvider>[];
  bool? readOnly;
  bool? deleteEnabled;
  bool? updateEnabled;
  bool? insertEnabled;
  List<DataBookMetaDataColumn>? columns = <DataBookMetaDataColumn>[];
  List<String>? primaryKeyColumns = <String>[];
  List<String>? tableColumnView;
  String? offlineScreenComponentId;

  List<String> get columnNames {
    List<String> names = <String>[];
    columns?.forEach((element) => names.add(element.name!));
    return names;
  }

  DataBookMetaData({
    required String name,
    String? componentId,
    this.dataProvider,
    this.columns,
    this.detailDataProviders,
    this.deleteEnabled,
    this.updateEnabled,
  }) : super(name: name, componentId: componentId);

  DataBookMetaData.fromJson({required Map<String, dynamic> map})
      : super.fromJson(map: map) {
    dataProvider = map['dataProvider'];
    if (map['detailDataProviders'] != null)
      map['detailDataProviders'].forEach((dp) =>
          detailDataProviders?.add(DataBookMetaDataProvider.fromJson(dp)));
    readOnly = map['readOnly'];
    deleteEnabled = map['deleteEnabled'];
    updateEnabled = map['updateEnabled'];
    insertEnabled = map['insertEnabled'];
    if (map['primaryKeyColumns'] != null)
      primaryKeyColumns = List<String>.from(map['primaryKeyColumns']);
    if (map['columns'] != null)
      map['columns']
          .forEach((c) => columns?.add(DataBookMetaDataColumn.fromJson(c)));
    super.name = map['name'];
    super.componentId = map['componentId'];
    if (map['columnView.table'] != null)
      tableColumnView = List<String>.from(map['columnView.table']);
  }

  DataBookMetaDataColumn? getColumn(String columnName) {
    for (var element in columns!) {
      if (element.name?.toUpperCase() == columnName.toUpperCase()) {
        return element;
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dataProvider': dataProvider,
        'readOnly': readOnly,
        'deleteEnabled': deleteEnabled,
        'updateEnabled': updateEnabled,
        'insertEnabled': insertEnabled,
        'primaryKeyColumns': primaryKeyColumns,
        'tableColumnView': tableColumnView,
        'detailDataProviders': detailDataProviders
            ?.map<Map<String, dynamic>>((dp) => dp.toJson())
            .toList(),
        'columns':
            columns?.map<Map<String, dynamic>>((c) => c.toJson()).toList(),
      };
}
