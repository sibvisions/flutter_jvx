import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/meta_data/data_book_meta_data_column.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_creator.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_data.dart';
import 'package:flutterclient/src/util/app/text_utils.dart';

class SoTableColumnCalculator {
  static double defaultMinWidh = 15;

  static List<SoTableColumn> getColumnFlex(
      SoComponentData componentData,
      List<String> columnLabels,
      List<String> columnNames,
      TextStyle textStyle,
      SoComponentCreator componentCreator,
      bool autoResize,
      double textScaleFactor,
      [double? containerWidth,
      double headerPadding = 13,
      double itemPadding = 8,
      double borderWidth = 1,
      int calculateForRecordCount = 10]) {
    List<SoTableColumn> columns = <SoTableColumn>[];

    if (containerWidth != null) containerWidth -= (borderWidth * 2);

    // get preferred header widths

    if (columnLabels.length > 0) {
      columnLabels.forEach((l) {
        double textWidth =
            TextUtils.getTextWidth(l, textStyle, textScaleFactor) +
                headerPadding;
        columns.add(SoTableColumn(textWidth + headerPadding, defaultMinWidh));
      });
    } else {
      columns.add(SoTableColumn(
          TextUtils.getTextWidth('User', textStyle, textScaleFactor) +
              headerPadding,
          defaultMinWidh));

      columns.add(SoTableColumn(
          TextUtils.getTextWidth('Active', textStyle, textScaleFactor) +
              headerPadding,
          defaultMinWidh));
    }

    // get preferred data widths
    if (componentData.data?.records != null) {
      if (componentData.data!.records.length < calculateForRecordCount)
        calculateForRecordCount = componentData.data!.records.length;

      for (int ii = 0; ii < calculateForRecordCount; ii++) {
        componentData.data!.getRow(ii, columnNames)!.asMap().forEach((i, c) {
          CoCellEditorWidget? editor;
          DataBookMetaDataColumn? metaDataColumn =
              componentData.getMetaDataColumn(columnNames[i]);
          String value = c != null ? c.toString() : "";

          if (metaDataColumn != null && metaDataColumn.cellEditor != null) {
            editor = componentCreator.createCellEditorForTable(
                metaDataColumn.cellEditor!, componentData);
            editor?.cellEditorModel.cellEditorValue = value;
            editor?.cellEditorModel.textScaleFactor = textScaleFactor;
          }

          if (editor != null && editor.cellEditorModel.isTableMinimumSizeSet) {
            columns[i].minWidth =
                editor.cellEditorModel.tableMinimumSize!.width + itemPadding;
          } else if (editor != null &&
              editor.cellEditorModel.isTablePreferredSizeSet) {
            columns[i].preferredWidth =
                editor.cellEditorModel.tablePreferredSize!.width;
          } else {
            columns[i].preferredWidth =
                TextUtils.getTextWidth(value, textStyle, textScaleFactor) +
                    itemPadding;
          }
        });
      }

      // Autp resize columns
      if (containerWidth != null && containerWidth != double.infinity) {
        double columnWidthSum = getColumnWidthSum(columns);
        if (autoResize || containerWidth > columnWidthSum) {
          _calculateAutoSizeColumnWidths(columns, containerWidth);
        }
      } else {
        print('SoTableColumCalculator: Container size width is infinity!');
      }
    }

    return columns;
  }

  static double getPreferredTableHeight(
      SoComponentData componentData,
      List<String> columnLabels,
      TextStyle textStyle,
      bool tableHeaderVisible,
      double textScaleFactor,
      [double headerPadding = 13,
      double itemPadding = 8,
      double borderWidth = 1,
      int calculateForRecordCount = 1]) {
    double headerHeight = 0;
    double itemHeight = 0;
    int recordCount = calculateForRecordCount;

    if (columnLabels.length > 0) {
      double textHeight =
          TextUtils.getTextHeight(columnLabels[0], textStyle, textScaleFactor);
      if (tableHeaderVisible) headerHeight = textHeight + headerPadding;
      itemHeight = textHeight + itemPadding;
    }

    if (componentData.data?.records != null &&
        componentData.data!.records.length > calculateForRecordCount) {
      recordCount = componentData.data!.records.length;
    }

    return headerHeight + (itemHeight * recordCount) + (borderWidth * 2);
  }

  static void _calculateAutoSizeColumnWidths(
      List<SoTableColumn> columns, double containerWidth) {
    double sumFixedColumnWidth = _getFixedColumnWidthSum(columns);
    double sumFlexColumnWidth = _getFlexColumnWidthSum(columns);
    bool moreFlexAvailable = sumFlexColumnWidth > 0;
    double flexReduceFactor =
        sumFlexColumnWidth / (containerWidth - sumFixedColumnWidth);

    while (moreFlexAvailable &&
        ((containerWidth < getColumnWidthSum(columns) &&
                flexReduceFactor > 1.0) ||
            (containerWidth > getColumnWidthSum(columns) &&
                flexReduceFactor > 0.0))) {
      moreFlexAvailable = false;

      for (int i = 0; i < columns.length; i++) {
        SoTableColumn c = columns[i];
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

  static double getColumnWidthSum(List<SoTableColumn> columns) {
    double columnWidths = 0;
    columns.forEach((f) => columnWidths += f.preferredWidth!);

    return columnWidths;
  }

  static double _getFixedColumnWidthSum(List<SoTableColumn> columns) {
    double columnWidths = 0;
    columns.forEach((f) {
      if (f.isFixColumn) columnWidths += f.preferredWidth!;
    });

    return columnWidths;
  }

  static double _getFlexColumnWidthSum(List<SoTableColumn> columns) {
    double columnWidths = 0;
    columns.forEach((f) {
      if (f.isFlexColumn) columnWidths += f.preferredWidth!;
    });

    return columnWidths;
  }
}

class SoTableColumn {
  double? _preferredWidth;
  double? _minWidth;
  double? width;

  double? get preferredWidth => _preferredWidth;
  set preferredWidth(double? value) {
    if (_preferredWidth == null || _preferredWidth! < value!) {
      _preferredWidth = value;
    }
  }

  double? get minWidth => _minWidth;
  set minWidth(double? value) {
    if (preferredWidth == null || preferredWidth! < value!) {
      preferredWidth = value;
    }

    _minWidth = value;
  }

  bool get isFlexColumn => this.preferredWidth! > this.minWidth!;
  bool get isFixColumn => this.preferredWidth == this.minWidth;

  SoTableColumn([double? preferredWidth, double? minWidth, this.width]) {
    this.preferredWidth = preferredWidth;
    this.minWidth = minWidth;
  }

  void reducePreferredWidth(double reduceFactor) {
    if ((_preferredWidth! / reduceFactor) < _minWidth!)
      _preferredWidth = _minWidth;
    else
      _preferredWidth = _preferredWidth! / reduceFactor;
  }
}
