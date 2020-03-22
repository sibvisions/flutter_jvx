import '../../../../model/api/response/response_object.dart';

class JVxDataproviderChanged extends ResponseObject {
  String dataProvider;
  int reload;
  int selectedRow;

  JVxDataproviderChanged({this.dataProvider, this.reload, this.selectedRow});

  JVxDataproviderChanged.fromJson(Map<String, dynamic> json) {
    dataProvider = json['dataProvider'];
    reload = json['reload'];
    selectedRow = json['selectedRow'];
  }
}