import 'dart:ui';

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
