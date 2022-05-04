import '../../../../api/api_object_property.dart';

class ColumnView {
  List<String> columnNames = <String>[];
  int? columnCount;
  List? rowDefinitions;

  ColumnView();

  ColumnView.fromJson(Map<String, dynamic> json) {
    var jsonColumnNames = json[ApiObjectProperty.columnNames];
    if (jsonColumnNames != null) {
      columnNames = List<String>.from(jsonColumnNames);
    }

    var jsonColumnCount = json[ApiObjectProperty.columnCount];
    if (jsonColumnCount != null) {
      columnCount = jsonColumnCount;
    }

    var jsonRowDefinitions = json[ApiObjectProperty.rowDefinitions];
    if (jsonRowDefinitions != null) {
      rowDefinitions = List.from(jsonRowDefinitions);
    }
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'columnNames': columnNames, 'columnCount': columnCount, 'rowDefinitions': rowDefinitions};
}
