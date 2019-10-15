import 'package:jvx_mobile_v3/model/api/response/response_object.dart';

/// Data holding Class for [JVxComponent]'s.
class JVxData extends ResponseObject {
  int selectedRow;
  bool isAllFetched;
  String dataProvider;
  List<dynamic> records;
  List<dynamic> columnNames;

  JVxData({this.selectedRow, this.isAllFetched, this.dataProvider, this.records, this.columnNames});

  JVxData.fromJson(Map<String, dynamic> json)
    : selectedRow = json['selectedRow'],
      isAllFetched = json['isAllFetched'],
      dataProvider = json['dataProvider'],
      records = json['records'],
      columnNames = json['columnNames'],
      super.fromJson(json);
}