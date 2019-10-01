/// Data holding Class for [JVxComponent]'s.
class JVxData {
  int selectedRow;
  bool isAllFetched;
  String dataProvider;
  String name;
  List<dynamic> records;
  List<dynamic> columnNames;

  JVxData({this.selectedRow, this.isAllFetched, this.dataProvider, this.name, this.records, this.columnNames});

  JVxData.fromJson(Map<String, dynamic> json)
    : selectedRow = json['selectedRow'],
      isAllFetched = json['isAllFetched'],
      dataProvider = json['dataProvider'],
      name = json['name'],
      records = json['records'],
      columnNames = json['columnNames'];
}