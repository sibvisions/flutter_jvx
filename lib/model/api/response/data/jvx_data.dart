import 'package:jvx_mobile_v3/model/api/response/response_object.dart';

/// Data holding Class for [JVxComponent]'s.
class JVxData extends ResponseObject {
  int selectedRow;
  bool isAllFetched;
  String dataProvider;
  List<dynamic> records;
  List<dynamic> columnNames;

  JVxData({this.selectedRow, this.isAllFetched, this.dataProvider, this.records, this.columnNames});

  List<dynamic> getRow(int index, [List<String> pColumnNames]) {
    List<dynamic> row = <dynamic>[];
    
    if (index<this.records.length) {
      if (pColumnNames==null) pColumnNames = this.columnNames;
      List<int> columnIndexes = <int>[];

      pColumnNames.forEach((c) {
        int index = this.columnNames.indexOf(c);
        if (index>=0) columnIndexes.add(index);
      });

      columnIndexes.forEach((i) {
        row.add(this.records[index][i]);
      });
    }

    return row;
  }

  JVxData.fromJson(Map<String, dynamic> json)
    : selectedRow = json['selectedRow'],
      isAllFetched = json['isAllFetched'],
      dataProvider = json['dataProvider'],
      records = json['records'],
      columnNames = json['columnNames'],
      super.fromJson(json);
}