class Filter {
  List<dynamic> columnNames;
  List<dynamic> values;

  Filter({this.columnNames, this.values});

  Filter.fromJson(Map<String, dynamic> json)
      : columnNames = json['columnNames'],
        values = json['values'];

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'columnNames': columnNames, 'values': values};
}
