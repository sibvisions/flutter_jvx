/* Copyright 2022 SIB Visions GmbH
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
import '../column_definition.dart';
import '../data_book.dart';

/// Used as return value when getting subscriptions data from [IDataService]
class DataChunk {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data map, key is the index of the data in the dataBook
  final Map<int, List<dynamic>> data;

  /// List of all column definitions, order is the same as the columnNames requested in [DataSubscription],
  /// if left empty - will contain all columns
  final List<ColumnDefinition> columnDefinitions;

  /// Only true if server has no more data.
  final bool isAllFetched;

  /// index of first record in databook
  final int from;

  /// index to which data has been fetched
  final int to;

  /// True if this chunk is only an update on already fetched data
  bool update;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DataChunk({
    required this.data,
    required this.isAllFetched,
    required this.columnDefinitions,
    required this.from,
    required this.to,
    this.update = false,
  });

  int getColumnIndex(String columnName) {
    return DataBook.getColumnIndex(columnDefinitions, columnName);
  }

  dynamic getValue(String columnName, int rowIndex) {
    return data[rowIndex]?[getColumnIndex(columnName)];
  }

  List<dynamic> getValues(String columnName) {
    return data.values.map((value) => value[getColumnIndex(columnName)]).toList();
  }
}
