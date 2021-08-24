enum FilterCompareOperator { EQUAL, LIKE }

class Filter {
  List<dynamic>? columnNames;
  List<dynamic>? values;
  List<FilterCompareOperator>? compareOperator;

  Filter({this.columnNames, this.values, this.compareOperator});

  Filter.fromJson(Map<String, dynamic> json)
      : columnNames = json['columnNames'],
        values = json['values'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (_checkListForNull(columnNames) && _checkListForNull(values))
          'columnNames': columnNames,
        if (_checkListForNull(values) && _checkListForNull(columnNames))
          'values': values
      };

  bool _checkListForNull(List? list) {
    if (list != null) {
      try {
        list.firstWhere((element) => element == null);

        return false;
      } on StateError {
        return true;
      }
    } else {
      return false;
    }
  }
}
