
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_label.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_editor.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';

class JVxTable extends JVxEditor {
  // the show vertical lines flag.
	bool showVerticalLines = false;
	// the show horizontal lines flag.
	bool showHorizontalLines = false;

  //
  bool tableHeaderVisible = true;

  Size maximumSize;

  JVxTable(Key componentId, BuildContext context) : super(componentId, context);

  @override
  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    maximumSize = properties.getProperty<Size>("maximumSize",null);
    showVerticalLines = properties.getProperty<bool>("showVerticalLines", showVerticalLines);
    showVerticalLines = properties.getProperty<bool>("showVerticalLines");
    tableHeaderVisible = properties.getProperty<bool>("tableHeaderVisible", tableHeaderVisible);
  }

  void _onRowTapped() {

  }

  TableRow getTableRow(List<Widget> children, bool isHeader) {
    if (isHeader) {
      return TableRow(
        decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      children: children);
    } else {
      return TableRow(
        decoration: BoxDecoration(
        color: Colors.grey[200]
      ),
      children: children);
    }
  }

  Widget getTableColumn(String text, bool isHeader) {
    if (isHeader) {
      return Container(
        child: 
          Text(text, 
            style: this.style),
        padding: EdgeInsets.all(5),
      );
    } else {
      return Container(
        child: 
          Text(text, 
            style: this.style),
        padding: EdgeInsets.all(5),
      );
    }
  }

  TableRow getHeaderRow() {
    JVxData data = getIt.get<JVxScreen>().getData(dataProvider);
    List<Widget> children = new List<Widget>();

    if (data!=null && data.columnNames!=null) {
      data.columnNames.forEach((c) {
        children.add(getTableColumn(c.toString(), true));
      });
    }

    return getTableRow(children, true);
  }

  List<TableRow> getDataRows() {
    List<TableRow> rows = new List<TableRow>();
    
    JVxData data = getIt.get<JVxScreen>().getData(dataProvider);

    if (data!=null) {
      data.records.forEach((r) {
        if (r is List) {
          List<Widget> children = new List<Widget>();
          r.forEach((c) {
            children.add(getTableColumn(c.toString(), false));
          });

          rows.add(getTableRow(children, false));
        }
      });
    }
    return rows;
  }

  @override
  Widget getWidget() {

    TableBorder border = TableBorder.all();
    List<TableRow> rows = new List<TableRow>();

    if (tableHeaderVisible) {
      rows.add(getHeaderRow());
    }

    rows.addAll(getDataRows());

    return Table(
      border: border,
      children: rows,
    );
  }
}