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

import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../util/parse_util.dart';
import '../component/i_font_style.dart';
import '../data/sort_definition.dart';
import 'api_response.dart';

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
    required this.recordReadOnly,
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

/// A RecordFormat represents the cell formats of all records inside a specific component.
class RecordFormat {
  Map<int, RowFormat> rowFormats = {};

  RecordFormat();

  RecordFormat.fromJson(Map<String, dynamic> json, int from) {
    List<String?>? formatJson = List<String?>.from(json[ApiObjectProperty.format]);

    List<CellFormat> formats = [];
    for (String? formatString in formatJson) {
      formats.add(CellFormat.fromString(formatString));
    }

    dynamic recordsJson = json[ApiObjectProperty.records];
    int recordIndex = from;
    for (List<dynamic> recordIndexesDynamic in recordsJson ?? []) {
      rowFormats[recordIndex] = RowFormat(List<int>.from(recordIndexesDynamic), formats);
      recordIndex++;
    }
  }

  CellFormat? getCellFormat(int row, int column) {
    if (!rowFormats.containsKey(row) || column < 0) {
      return null;
    }

    RowFormat rowFormat = rowFormats[row]!;
    // Every row has column indexes. The last one counts for all following columns
    // E.g. 5 Columns, indexes are 0, 1, 2 -> Format applied is 0, 1, 2, 2, 2

    int formatIndex;
    if (column < rowFormat.columnIndexToFormatIndex.length) {
      formatIndex = rowFormat.columnIndexToFormatIndex[column];
    } else {
      formatIndex = rowFormat.columnIndexToFormatIndex.last;
    }

    if (formatIndex >= rowFormat.formats.length) {
      return null;
    }

    return rowFormat.formats[formatIndex];
  }
}

class RowFormat {
  List<int> columnIndexToFormatIndex = [];
  List<CellFormat?> formats = [];

  RowFormat(this.columnIndexToFormatIndex, this.formats);
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
