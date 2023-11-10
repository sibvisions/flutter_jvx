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

import '../../flutter_ui.dart';
import '../../service/api/shared/api_object_property.dart';
import '../data/sort_definition.dart';
import 'api_response.dart';
import 'record_format.dart';

class DalFetchResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// List of all Columns names present in fetch, order is important
  final List<String> columnNames;

  /// Fetch data in this response are from this index.
  final int from;

  /// Fetch data in this response are to this index.
  final int to;

  /// Selected row of this dataBook.
  final int selectedRow;

  /// Selected column
  final String? selectedColumn;

  /// True if all data for this dataBook have been fetched
  final bool isAllFetched;

  /// Link to the connected dataBook
  final String dataProvider;

  /// Fetched records
  final List<List<dynamic>> records;

  /// Saves which records are read only and which are not.
  final List<List<dynamic>>? recordReadOnly;

  /// Clear data before filling
  final bool clear;

  /// The cell formats for this dataprovider.
  final Map<String, RecordFormat>? recordFormats;

  /// The sort definitions
  final List<SortDefinition>? sortDefinitions;

  final List<dynamic>? masterRow;

  /// The tree path
  final List<int>? treePath;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates an [DalFetchResponse] Object
  DalFetchResponse({
    required this.dataProvider,
    required this.from,
    required this.selectedRow,
    required this.isAllFetched,
    required this.columnNames,
    required this.to,
    required this.records,
    this.recordReadOnly,
    this.masterRow,
    this.clear = false,
    this.recordFormats,
    this.sortDefinitions,
    this.selectedColumn,
    this.treePath,
    required super.name,
  });

  /// Parses a json into an [DalFetchResponse] Object
  DalFetchResponse.fromJson(super.json)
      : records = json[ApiObjectProperty.records].cast<List<dynamic>>(),
        masterRow = cast<List<dynamic>>(json[ApiObjectProperty.masterRow]),
        to = json[ApiObjectProperty.to],
        from = json[ApiObjectProperty.from],
        columnNames = json[ApiObjectProperty.columnNames].cast<String>(),
        isAllFetched = json[ApiObjectProperty.isAllFetched] ?? false,
        selectedRow = json[ApiObjectProperty.selectedRow],
        selectedColumn = json[ApiObjectProperty.selectedColumn],
        dataProvider = json[ApiObjectProperty.dataProvider],
        clear = json[ApiObjectProperty.clear] ?? false,
        recordFormats = json[ApiObjectProperty.recordFormat] != null
            ? (json[ApiObjectProperty.recordFormat] as Map<String, dynamic>).map((componentName, recordFormatJson) =>
                MapEntry(componentName, RecordFormat.fromJson(recordFormatJson, json[ApiObjectProperty.from])))
            : null,
        recordReadOnly = json[ApiObjectProperty.recordReadOnly] != null
            ? List.from(json[ApiObjectProperty.recordReadOnly][ApiObjectProperty.records])
            : null,
        sortDefinitions =
            (json[ApiObjectProperty.sortDefinition] as List<dynamic>?)?.map((e) => SortDefinition.fromJson(e)).toList(),
        treePath = json[ApiObjectProperty.treePath]?.cast<int>(),
        super.fromJson();
}
