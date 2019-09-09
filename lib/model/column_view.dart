class ColumnView {
  List columnNames;
  int columnCount;
  List rowDefinitions;

  ColumnView();

  ColumnView.fromJson(Map<String, dynamic> json)
    : columnNames = json['columnNames'],
      columnCount = json['columnCount'],
      rowDefinitions = json['rowDefinitions'];

  Map<String, dynamic> toJson() => <String, dynamic>{
    'columnNames': columnNames,
    'columnCount': columnCount,
    'rowDefinitions': rowDefinitions
  };
}