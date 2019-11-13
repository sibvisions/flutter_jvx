import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_label.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_editor.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class JVxTable extends JVxEditor {
  // visible column names
  List<String> columnNames = <String>[];

  // column labels for header
  List<String> columnLabels = <String>[];

  // the show vertical lines flag.
  bool showVerticalLines = false;

  // the show horizontal lines flag.
  bool showHorizontalLines = false;

  // the show table header flag
  bool tableHeaderVisible = true;

  Size maximumSize;

  ScrollController _scrollController = ScrollController();
  int pageSize = 40;
  int pageIndex = 0;

  @override
  set data(ComponentData data) {
    super.data?.unregisterDataChanged(onServerDataChanged);
    super.data = data;
    super.data?.registerDataChanged(onServerDataChanged);
  }

  JVxTable(Key componentId, BuildContext context) : super(componentId, context) {
    _scrollController.addListener(_scrollListener);
  }

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    maximumSize = changedComponent.getProperty<Size>(ComponentProperty.MAXIMUM_SIZE, null);
    showVerticalLines =
        changedComponent.getProperty<bool>(ComponentProperty.SHOW_VERTICAL_LINES, showVerticalLines);
    showHorizontalLines = changedComponent.getProperty<bool>(
        ComponentProperty.SHOW_HORIZONTAL_LINES, showHorizontalLines);
    tableHeaderVisible =
        changedComponent.getProperty<bool>(ComponentProperty.TABLE_HEADER_VISIBLE, tableHeaderVisible);
    columnNames =
        changedComponent.getProperty<List<String>>(ComponentProperty.COLUMN_NAMES, columnNames);
    reload = changedComponent.getProperty<int>(ComponentProperty.RELOAD);
    columnLabels = changedComponent.getProperty<List<String>>(ComponentProperty.COLUMN_LABELS, columnLabels);
    reload = changedComponent.getProperty<int>(ComponentProperty.RELOAD, reload);
  }

  void _onRowTapped(int index) {
    data.selectRecord(context, index);
  }

  TableRow getTableRow(List<Widget> children, bool isHeader) {
    if (isHeader) {
      return TableRow(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: UIData.ui_kit_color_2[200],
          ),
          children: children);
    } else {
      return TableRow(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: Colors.white,
          ),
          children: children);
    }
  }

  Widget getTableColumn(String text, int rowIndex) {
    if (rowIndex == -1) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Text(Properties.utf8convert(text), style: TextStyle(fontSize: style.fontSize, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          padding: EdgeInsets.all(5),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          child: Container(
              child: Text(Properties.utf8convert(text), style: this.style),
              padding: EdgeInsets.all(5)),
          onTap: () => _onRowTapped(rowIndex),
        ),
      );
    }
  }

  TableRow getHeaderRow() {
    List<Widget> children = new List<Widget>();

    if (this.columnLabels != null) {
      this.columnLabels.forEach((c) {
        children.add(getTableColumn(c.toString(), -1));
      });
    }

    return getTableRow(children, true);
  }

  List<TableRow> getDataRows(JVxData data) {
    List<TableRow> rows = new List<TableRow>();
    List<int> visibleColumnsIndex = new List<int>();

    if (data != null) {
      columnNames.forEach((r) {
        visibleColumnsIndex.add(
          data.columnNames.indexOf(r)); 
      });
      data.records.asMap().forEach((i, r) {
        if (i>=pageIndex*pageSize && i<(pageIndex+1)*pageSize) {
          if (r is List) {
            List<Widget> children = new List<Widget>();

            visibleColumnsIndex.forEach((j) {
              if (j<r.length)
                children.add(getTableColumn(r[j]!=null?r[j].toString():"", i));
              else 
                children.add(getTableColumn("", i));
            });

            rows.add(getTableRow(children, false));
          }
        }
      });
    }
    return rows;
  }

  @override
  void onServerDataChanged() {

  }

  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      this.pageIndex += 1;
      data.getData(context, this.reload, this.pageSize*(this.pageIndex+1));
    } else if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      this.pageIndex -= 1;
      if (this.pageIndex<0) this.pageIndex = 0;
    }
  }

  @override
  Widget getWidget() {
    List<TableRow> rows = new List<TableRow>();
    TableBorder border = TableBorder();
    Map<int, TableColumnWidth> columnWidths = Map<int,TableColumnWidth>();

    if (showHorizontalLines && !showVerticalLines) {
      border = TableBorder(bottom: BorderSide(), top: BorderSide());
    } else if (!showHorizontalLines && showVerticalLines) {
      border = TableBorder(left: BorderSide(), right: BorderSide());
    } else if (showHorizontalLines && showVerticalLines) {
      border = TableBorder.all();
    }

    if (tableHeaderVisible) {
      rows.add(getHeaderRow());
    }

    rows.addAll(getDataRows(data.getData(context, this.reload, (this.pageIndex+1)*this.pageSize)));
    this.reload = null;

    if (rows.length > 0 &&
        rows[0].children != null &&
        rows[0].children.length > 0) {

      /*rows[0].children.asMap().forEach((i,c) {
        columnWidths.putIfAbsent(i, () => IntrinsicColumnWidth());
      });
      */

      return Container(
        child: SingleChildScrollView(
          controller: _scrollController,
          child:  Table(
            border: border,
            children: rows,
            columnWidths: columnWidths
          )
        )
      );
    } else {
      return Container(child: Text("No table data"));
    }
  }
}
