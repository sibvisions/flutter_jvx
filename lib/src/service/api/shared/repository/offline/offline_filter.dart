enum FilterCompareOperator { EQUAL, LIKE }

class OfflineFilter {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of columns, order corresponds to values in [values]
  List<String> columnNames;

  /// Value of columns, order corresponds to names in [columnNames]
  List<dynamic> values;

  /// How they should be compared, used in offlineMode
  List<FilterCompareOperator>? compareOperator;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OfflineFilter({
    required this.values,
    required this.columnNames,
    this.compareOperator,
  });
}
