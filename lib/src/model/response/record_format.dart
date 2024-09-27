/*
 * Copyright 2023 SIB Visions GmbH
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
import 'dart:ui';

import '../../../flutter_jvx.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../util/parse_util.dart';
import '../component/i_font_style.dart';

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

    if (rowFormat.columnIndexToFormatIndex.isEmpty) {
      formatIndex = 0;
    } else if (column < rowFormat.columnIndexToFormatIndex.length) {
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
  String? imageString;
  String? style;
  int? leftIndent;

  CellFormat.fromString(String? pFormatString) {

    List<String> entries = pFormatString?.asList(";") ?? [];

    for (int entryIndex = 0; entryIndex < entries.length; entryIndex++) {
      dynamic entryValue = entries[entryIndex];
      if (entryValue == null) {
        continue;
      }

      switch (entryIndex) {
        case 0:
          background = ParseUtil.parseColor(entryValue);
          break;
        case 1:
          foreground = ParseUtil.parseColor(entryValue);
          break;
        case 2:
          font = JVxFont.fromString(entryValue);
          break;
        case 3:
            imageString = entryValue.toString();
          break;
        case 4:
            style = entryValue.toString();
          break;
        case 5:
            String? indent = entryValue.toString();

            if (indent.isNotEmpty) {
              leftIndent = int.parse(indent);
            }
          break;
        default:
          FlutterUI.log.e("Invalid form index: ($entryIndex)");
      }
    }
  }
}
