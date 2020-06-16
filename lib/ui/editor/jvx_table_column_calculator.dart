import 'dart:math';

import 'package:flutter/material.dart';
import '../../model/api/response/meta_data/jvx_meta_data_column.dart';
import '../../utils/text_utils.dart';
import '../../ui/editor/celleditor/i_cell_editor.dart';
import '../../ui/screen/component_creator.dart';
import '../../ui/screen/component_data.dart';

class JVxTableColumnCalculator {
  static double defaultMinWidh = 15;

  static List<JVxTableColumn> getColumnFlex(
      ComponentData componentData,
      List<String> columnLabels,
      List<String> columnNames,
      TextStyle textStyle,
      ComponentCreator componentCreator,
      bool autoResize,
      [double containerWidth,
      double headerPadding = 13,
      double itemPadding = 8,
      double borderWidth = 1,
      int calculateForRecordCount = 10]) {
    List<JVxTableColumn> columns = List<JVxTableColumn>();

    if (containerWidth != null) containerWidth -= (borderWidth * 2);

    // get preferred header widths
    columnLabels.forEach((l) {
      double textWidth = TextUtils.getTextWidth(l, textStyle) + headerPadding;
      columns.add(JVxTableColumn(textWidth + headerPadding, defaultMinWidh));
    });

    // get preferred data widths
    if (componentData.data.records != null) {
      if (componentData.data.records.length < calculateForRecordCount)
        calculateForRecordCount = componentData.data.records.length;

      for (int ii = 0; ii < calculateForRecordCount; ii++) {
        componentData.data.getRow(ii, columnNames).asMap().forEach((i, c) {
          ICellEditor editor;
          JVxMetaDataColumn metaDataColumn =
              componentData.getMetaDataColumn(columnNames[i]);
          if (metaDataColumn != null && metaDataColumn.cellEditor != null) {
            editor = componentCreator
                .createCellEditorForTable(metaDataColumn.cellEditor);
          }

          if (editor != null && editor.isTableMinimumSizeSet) {
            columns[i].minWidth = editor.tableMinimumSize.width + itemPadding;
          } else if (editor != null && editor.isPreferredSizeSet) {
            columns[i].preferredWidth = editor.preferredSize.width;
          } else {
            String value = c != null ? c.toString() : "";
            columns[i].preferredWidth =
                TextUtils.getTextWidth(value, textStyle) + itemPadding;
          }
        });
      }

      // Autp resize columns
      if (containerWidth != null && containerWidth != double.infinity) {
        if (autoResize) {
          _calculateAutoSizeColumnWidths(columns, containerWidth);
        }
      } else {
        print('JVxTableColumCalculator: Container size width is infinity!');
      }
    }

    return columns;
  }

  static double getPreferredTableHeight(ComponentData componentData,
      List<String> columnLabels,
      TextStyle textStyle,
      bool tableHeaderVisible,
      [double headerPadding = 13,
      double itemPadding = 8,
      double borderWidth = 1,
      int calculateForRecordCount = 1]) {
    double headerHeight = 0;
    double itemHeight = 0;
    int recordCount = calculateForRecordCount;

    if (columnLabels != null && columnLabels.length > 0) {
      double textHeight = TextUtils.getTextHeight(columnLabels[0], textStyle);
      if (tableHeaderVisible)
        headerHeight = textHeight + headerPadding;
      itemHeight = textHeight + itemPadding;
    }

    if (componentData.data.records != null && componentData.data.records.length>calculateForRecordCount) {
      recordCount = componentData.data.records.length;
    }

    return headerHeight + (itemHeight * recordCount) + (borderWidth*2);
  }

  static void _calculateAutoSizeColumnWidths(
      List<JVxTableColumn> columns, double containerWidth) {
    double sumFixedColumnWidth = _getFixedColumnWidthSum(columns);
    double sumFlexColumnWidth = _getFlexColumnWidthSum(columns);
    bool moreFlexAvailable = sumFlexColumnWidth > 0;
    double flexReduceFactor =
        sumFlexColumnWidth / (containerWidth - sumFixedColumnWidth);

    while (moreFlexAvailable &&
        containerWidth < getColumnWidthSum(columns) &&
        flexReduceFactor > 1.0) {
      moreFlexAvailable = false;

      for (int i = 0; i < columns.length; i++) {
        JVxTableColumn c = columns[i];
        if (c.isFlexColumn) {
          c.reducePreferredWidth(flexReduceFactor);

          if (c.isFlexColumn) moreFlexAvailable = true;
        }
      }

      if (moreFlexAvailable) {
        sumFixedColumnWidth = _getFixedColumnWidthSum(columns);
        sumFlexColumnWidth = _getFlexColumnWidthSum(columns);
        flexReduceFactor =
            sumFlexColumnWidth / (containerWidth - sumFixedColumnWidth);
      }
    }
  }

  static double getColumnWidthSum(List<JVxTableColumn> columns) {
    double columnWidths = 0;
    columns.forEach((f) => columnWidths += f.preferredWidth);

    return columnWidths;
  }

  static double _getFixedColumnWidthSum(List<JVxTableColumn> columns) {
    double columnWidths = 0;
    columns.forEach((f) {
      if (f.isFixColumn) columnWidths += f.preferredWidth;
    });

    return columnWidths;
  }

  static double _getFlexColumnWidthSum(List<JVxTableColumn> columns) {
    double columnWidths = 0;
    columns.forEach((f) {
      if (f.isFlexColumn) columnWidths += f.preferredWidth;
    });

    return columnWidths;
  }
}

class JVxTableColumn {
  double _preferredWidth;
  double _minWidth;
  double width;

  get preferredWidth => _preferredWidth;
  set preferredWidth(double value) {
    if (_preferredWidth == null || _preferredWidth < value) {
      _preferredWidth = value;
    }
  }

  get minWidth => _minWidth;
  set minWidth(double value) {
    if (preferredWidth == null || preferredWidth < value) {
      preferredWidth = value;
    }

    _minWidth = value;
  }

  bool get isFlexColumn => this.preferredWidth > this.minWidth;
  bool get isFixColumn => this.preferredWidth == this.minWidth;

  JVxTableColumn([double preferredWidth, double minWidth, this.width]) {
    this.preferredWidth = preferredWidth;
    this.minWidth = minWidth;
  }

  void reducePreferredWidth(double reduceFactor) {
    if ((_preferredWidth / reduceFactor) < _minWidth)
      _preferredWidth = _minWidth;
    else
      _preferredWidth = _preferredWidth / reduceFactor;
  }
}
