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

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../component/i_font_style.dart';
import '../data/sort_definition.dart';

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

  /// Clear data before filling
  final bool clear;

  /// The cell formats for this dataprovider.
  final Map<String, RecordFormat>? recordFormats;

  /// The sort definitions
  final List<SortDefinition>? sortDefinitions;

  final List<dynamic>? masterRow;
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
    this.masterRow,
    this.clear = false,
    this.recordFormats,
    this.sortDefinitions,
    this.selectedColumn,
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
            ? Map.fromIterable((json[ApiObjectProperty.recordFormat] as Map<String, dynamic>).keys,
                value: (key) => RecordFormat.fromJson(json[ApiObjectProperty.recordFormat]![key]))
            : null,
        sortDefinitions =
            (json[ApiObjectProperty.sortDefinition] as List<dynamic>?)?.map((e) => SortDefinition.fromJson(e)).toList(),
        super.fromJson();
}

class RecordFormat {
  final List<CellFormat?> _formats = [];
  final List<List<int>> _recordFormatIndexes = [];

  RecordFormat.fromJson(Map<String, dynamic> json) {
    List<String>? formatJson = json[ApiObjectProperty.format]?.cast<String?>();
    for (String? formatString in formatJson ?? []) {
      _formats.add(CellFormat.fromString(formatString));
    }

    dynamic recordsJson = json[ApiObjectProperty.records];
    for (List<dynamic> recordIndexesDynamic in recordsJson ?? []) {
      _recordFormatIndexes.add(recordIndexesDynamic.map<int>((e) => e).toList());
    }
  }

  CellFormat? getCellFormat(int row, int column) {
    if (row >= _recordFormatIndexes.length || row < 0) {
      return null;
    }

    List<int> rowFormatIndex = _recordFormatIndexes[row];

    if (rowFormatIndex.isEmpty) {
      return null;
    }

    // Every row has column indexes. The last one counts for all following columns
    // E.g. 5 Columns, indexes are 0, 1, 2 -> Format applied is 0, 1, 2, 2, 2

    int formatIndex = rowFormatIndex[min(column, rowFormatIndex.length - 1)];

    return _formats[formatIndex];
  }
}

class CellFormat {
  Color? background;
  Color? foreground;
  JVxFont? font;
  String imageString = "";

  CellFormat.fromString(String? pFormatString) {
    List<String> entries = pFormatString?.split(";") ?? [];

    for (int entryIndex = 0; entryIndex < entries.length; entryIndex++) {
      dynamic entryValue = entries[entryIndex];
      if (entryValue == null) {
        continue;
      }

      switch (entryIndex) {
        case 0:
          background = ParseUtil.parseServerColor(entryValue);
          break;
        case 1:
          foreground = ParseUtil.parseServerColor(entryValue);
          break;
        case 2:
          font = JVxFont.fromString(entryValue);
          break;
        default:
          if (imageString.isEmpty) {
            imageString = entryValue.toString();
          } else {
            imageString += ";$entryValue";
          }
      }
    }
  }
}
