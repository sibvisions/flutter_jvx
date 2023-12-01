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

import '../../../service/data/i_data_service.dart';
import '../../response/record_format.dart';
import '../column_definition.dart';
import '../data_book.dart';
import 'data_record.dart';

/// Used as return value when getting subscriptions data from [IDataService]
class DataChunk {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data map, key is the index of the data in the dataBook
  final Map<int, List<dynamic>> data;

  /// Whether or not a data entry is read only.
  final Map<int, List<bool>>? dataReadOnly;

  /// List of all column definitions, order is the same as the columnNames requested in [DataSubscription],
  /// if left empty - will contain all columns
  final List<ColumnDefinition> columnDefinitions;

  /// Only true if server has no more data.
  final bool isAllFetched;

  /// index of first record in databook
  final int from;

  /// Contains record formats
  final Map<String, RecordFormat>? recordFormats;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DataChunk({
    required this.data,
    required this.isAllFetched,
    required this.columnDefinitions,
    required this.from,
    this.dataReadOnly,
    this.recordFormats,
  });

  DataChunk.empty()
      : data = {},
        isAllFetched = false,
        columnDefinitions = [],
        from = 0,
        dataReadOnly = null,
        recordFormats = null;

  int getColumnIndex(String columnName) {
    return DataBook.getColumnIndex(columnDefinitions, columnName);
  }

  ColumnDefinition getColumn(String columnName) {
    return columnDefinitions[getColumnIndex(columnName)];
  }

  dynamic getValue(String columnName, int rowIndex) {
    return data[rowIndex]?[getColumnIndex(columnName)];
  }

  /// The record status of this row.
  RecordStatus getRecordStatus(pRowIndex) => RecordStatus.parseRecordStatus(data[pRowIndex], columnDefinitions);
}
