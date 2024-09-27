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

  /// All column definitions by name
  Map<String, ColumnDefinition> _columnDefinitionsByName = {};

  /// All column definitions by index
  Map<String, int> _columnDefinitionsIndexByName = {};

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
  }) {
    columnDefinitions.forEach((cd) => _columnDefinitionsByName[cd.name] = cd);

    for (int i = 0; i < columnDefinitions.length; i++) {
      _columnDefinitionsIndexByName[columnDefinitions[i].name] = i;
    }
  }

  DataChunk.empty()
      : data = {},
        isAllFetched = false,
        columnDefinitions = [],
        from = 0,
        dataReadOnly = null,
        recordFormats = null;

  ///Gets the index of the column for [name]
  int columnDefinitionIndex(String name) {
    return _columnDefinitionsIndexByName[name] ?? -1;
  }

  ///Gets the column definition for [name]
  ColumnDefinition? columnDefinition(String name) {
    return _columnDefinitionsByName[name];
  }

  dynamic getValue(String name, int rowIndex) {
    return data[rowIndex]?[columnDefinitionIndex(name)];
  }

  /// The record status of this row.
  RecordStatus getRecordStatus(pRowIndex) {
    return RecordStatus.parseRecordStatus(data[pRowIndex], columnDefinitions);
  }
}
