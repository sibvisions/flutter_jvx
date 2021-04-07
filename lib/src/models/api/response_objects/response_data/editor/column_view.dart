class ColumnView {
  List<String> columnNames = <String>[];
  int? columnCount;
  List? rowDefinitions;

  ColumnView();

  ColumnView.fromJson(Map<String, dynamic> json) {
    if (json['columnNames'] != null)
      columnNames = List<String>.from(json['columnNames']);
    columnCount = json['columnCount'];
    rowDefinitions = json['rowDefinitions'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'columnNames': columnNames,
        'columnCount': columnCount,
        'rowDefinitions': rowDefinitions
      };
}
