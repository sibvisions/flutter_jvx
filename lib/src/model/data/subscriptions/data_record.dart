/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import '../column_definition.dart';
import '../data_book.dart';

enum RecordStatus {
  INSERTED,
  UPDATED,
  NONE;

  static parseRecordStatus(List<dynamic>? values, List<ColumnDefinition> columnDefinitions) {
    if (values == null || values.length <= columnDefinitions.length || values.isEmpty || values.last == null) {
      return NONE;
    }

    String recordStatus = values.last.toString();

    switch (recordStatus) {
      case "I":
        return INSERTED;
      case "U":
        return UPDATED;
      default:
        return NONE;
    }
  }
}

class DataRecord {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The record status of this row.
  RecordStatus get recordStatus => RecordStatus.parseRecordStatus(values, columnDefinitions);

  /// Index of this row in the dataProvider
  final int index;

  /// The name of the selected column
  final String? selectedColumn;

  /// Column info
  final List<ColumnDefinition> columnDefinitions;

  /// Values of this row, order corresponds to order of [columnDefinitions]
  final List<dynamic> values;

  /// Path to this row in the tree
  final List<int>? treePath;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DataRecord({
    required this.columnDefinitions,
    required this.index,
    required this.values,
    this.selectedColumn,
    this.treePath,
  });

  int getColumnIndex(String columnName) {
    return DataBook.getColumnIndex(columnDefinitions, columnName);
  }

  dynamic getValue(String columnName) {
    return values[getColumnIndex(columnName)];
  }
}
