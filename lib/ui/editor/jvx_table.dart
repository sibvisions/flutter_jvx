import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_label.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_editor.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';
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

  JVxTable(Key componentId, BuildContext context) : super(componentId, context);

  @override
  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    maximumSize = properties.getProperty<Size>("maximumSize", null);
    showVerticalLines =
        properties.getProperty<bool>("showVerticalLines", showVerticalLines);
    showHorizontalLines = properties.getProperty<bool>(
        "showHorizontalLines", showHorizontalLines);
    tableHeaderVisible =
        properties.getProperty<bool>("tableHeaderVisible", tableHeaderVisible);
    columnNames =
        properties.getProperty<List<String>>("columnNames", columnNames);
    reload = properties.getProperty<int>("reload");
    columnLabels = properties.getProperty<List<String>>("columnLabels", columnLabels);
    reload = -1;
  }

  void _onRowTapped(int index) {
    getIt.get<JVxScreen>().selectRecord(dataProvider, index, false);
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
          child: Text(JVxLabel.utf8convert(text), style: TextStyle(fontSize: style.fontSize, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          padding: EdgeInsets.all(5),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          child: Container(
              child: Text(JVxLabel.utf8convert(text), style: this.style),
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
      data.columnNames.asMap().forEach((i, r) {
        if (columnNames.contains(r)) {
          visibleColumnsIndex.add(i);
        }
      });
      data.records.asMap().forEach((i, r) {
        if (r is List) {
          List<Widget> children = new List<Widget>();
          r.asMap().forEach((j, c) {
            if (visibleColumnsIndex.contains(j)) {
              children.add(getTableColumn(c.toString(), i));
            }
          });

          rows.add(getTableRow(children, false));
        }
      });
    }
    return rows;
  }

  @override
  Widget getWidget() {
    JVxData data = getIt
        .get<JVxScreen>()
        .getData(dataProvider, this.columnNames, this.reload);
    this.reload = null;
    List<TableRow> rows = new List<TableRow>();
    TableBorder border = TableBorder();

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

    rows.addAll(getDataRows(data));

    if (rows.length > 0 &&
        rows[0].children != null &&
        rows[0].children.length > 0) {
      return Table(
        border: border,
        children: rows,
      );
    } else {
      return Container(child: Text("No table data"));
    }
  }
}
