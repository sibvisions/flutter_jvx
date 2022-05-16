import 'package:flutter_client/src/model/data/column_definition.dart';

class DataRecord {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Index of this row in the dataProvider
  final int index;

  /// Column info
  final List<ColumnDefinition> columnDefinitions;

  /// Values of this row, order corresponds to order of [columnDefinitions]
  final List<dynamic> values;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DataRecord({
    required this.columnDefinitions,
    required this.index,
    required this.values,
  });
}
