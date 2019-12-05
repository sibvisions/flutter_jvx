import 'package:flutter/rendering.dart';
import 'package:jvx_mobile_v3/model/api/response/response_object.dart';
import 'package:jvx_mobile_v3/model/filter.dart';
import 'package:jvx_mobile_v3/utils/text_utils.dart';

/// Data holding Class for [JVxComponent]'s.
class JVxData extends ResponseObject {
  int selectedRow;
  bool isAllFetched;
  String dataProvider;
  List<dynamic> records = <dynamic>[];
  List<dynamic> columnNames;
  int from;
  int to;

  JVxData({this.selectedRow, this.isAllFetched, this.dataProvider, this.records, this.columnNames});

  List<dynamic> getRow(int index, [List<String> pColumnNames]) {
    List<dynamic> row = <dynamic>[];
    
    if (index<this.records.length) {
      if (pColumnNames==null) pColumnNames = List<String>.from(this.columnNames);
      List<int> columnIndexes = <int>[];

      pColumnNames.forEach((c) {
        int index = this.columnNames.indexOf(c);
        if (index>=0) columnIndexes.add(index);
      });

      columnIndexes.forEach((i) {
        row.add(this.records[index][i]);
      });
    }

    return row;
  }

  List<int> getColumnFlex(List<String> columnLabels, List<String> columnNames, TextStyle textStyle, [int calculateForRecordCount = 10]) {
    List<int> maxLengthPerColumn = new List<int>(columnLabels.length);
    columnLabels.asMap().forEach((i, l) {
      int textWidth = TextUtils.getTextWidth(l, textStyle);
      maxLengthPerColumn[i] = textWidth;
    });

    if (this.records != null) {
      if (this.records.length < calculateForRecordCount)
        calculateForRecordCount = this.records.length;

      for (int ii = 0; ii < calculateForRecordCount; ii++) {
        this.getRow(ii, columnNames).asMap().forEach((i,c) {
          String value = c != null ? c.toString() : "";
          int textWidth = TextUtils.getTextWidth(value, textStyle);
          if (maxLengthPerColumn[i] == null || maxLengthPerColumn[i] < textWidth) 
            maxLengthPerColumn[i] = textWidth;
        });
      }
    }

    return maxLengthPerColumn;
  }

  List<int> getColumnIndex(List<dynamic> columnNames) {
    List<int> visibleColumnsIndex = <int>[];
      this.columnNames.asMap().forEach((i, v) {
        if (columnNames != null) {
          if (columnNames.contains(v)) {
            visibleColumnsIndex.add(i);
          }
        } 
      });

    return visibleColumnsIndex;
  }

  int getRowIndexWithFilter(Filter filter) {
    int rowIndex  = -1;
    if (this.records!=null && filter.values!=null && filter.columnNames!=null && 
      filter.values.length == filter.columnNames.length) {
      List<int> columnIndex = this.getColumnIndex(filter.columnNames);
      for (int i=0; i<this.records.length;i++) {
        dynamic r = this.records[i];
        if (r is List) {
          bool found = true;
          columnIndex.asMap().forEach((j,ci) {
            found = (r[ci] == filter.values[j]) & found;
          });

          if (found) {
            rowIndex = i;
            break;
          }
        }
      }
    }

    return rowIndex;
  }

  bool deleteLocalRecord(Filter filter) {
    int index = this.getRowIndexWithFilter(filter);
    if (index>=0) {
      this.records.removeAt(index);
      return true;
    }

    return false;
  }

  JVxData.fromJson(Map<String, dynamic> json)
    : selectedRow = json['selectedRow'],
      isAllFetched = json['isAllFetched'],
      dataProvider = json['dataProvider'],
      records = json['records'],
      columnNames = json['columnNames'],
      from = json['from'],
      to = json['to'],
      super.fromJson(json);
}