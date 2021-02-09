enum FilterCompareOperator { EQUAL, LIKE }

class Filter {
  List<dynamic> columnNames;
  List<dynamic> values;
  FilterCompareOperator compareOperator;

  Filter(
      {this.columnNames,
      this.values,
      this.compareOperator = FilterCompareOperator.EQUAL});

  Filter.fromJson(Map<String, dynamic> json)
      : columnNames = json['columnNames'],
        values = json['values'];

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'columnNames': columnNames, 'values': values};
}
