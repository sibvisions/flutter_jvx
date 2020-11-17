import '../../response_object.dart';

class DataproviderChanged extends ResponseObject {
  String dataProvider;
  int reload;
  int selectedRow;
  List<String> columnNames;
  bool readOnly;
  bool deleteEnabled;
  bool updateEnabled;
  bool insertEnabled;

  DataproviderChanged(
      {this.dataProvider, this.reload, this.selectedRow, this.columnNames});

  DataproviderChanged.fromJson(Map<String, dynamic> json) {
    dataProvider = json['dataProvider'];
    reload = json['reload'];
    selectedRow = json['selectedRow'];
    columnNames = json['columnNames'];
    readOnly = json['readOnly'];
    deleteEnabled = json['deleteEnabled'];
    updateEnabled = json['updateEnabled'];
    insertEnabled = json['insertEnabled'];
  }
}
