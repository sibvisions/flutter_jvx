import '../../../../model/api/response/response_object.dart';

class JVxDataproviderChanged extends ResponseObject {
  String dataProvider;
  int reload;
  int selectedRow;
  List<String> columnNames;

  JVxDataproviderChanged({this.dataProvider, this.reload, this.selectedRow, this.columnNames});

  JVxDataproviderChanged.fromJson(Map<String, dynamic> json) {
    dataProvider = json['dataProvider'];
    reload = json['reload'];
    selectedRow = json['selectedRow'];
    columnNames = json['columnNames'];
  }
}