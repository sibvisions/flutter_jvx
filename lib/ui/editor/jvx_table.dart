
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_editor.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';

class JVxTable extends JVxEditor {
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
    maximumSize = properties.getProperty<Size>("maximumSize",null);
    showVerticalLines = properties.getProperty<bool>("showVerticalLines", showVerticalLines);
    showHorizontalLines = properties.getProperty<bool>("showHorizontalLines", showHorizontalLines);
    tableHeaderVisible = properties.getProperty<bool>("tableHeaderVisible", tableHeaderVisible);
  }

  void _onRowTapped(int index) {
      getIt.get<JVxScreen>().selectRecord(dataProvider, index, false);
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

  Widget getTableColumn(String text, int rowIndex) {
    if (rowIndex==-1) {
      return Container(
            child: 
              Text(text, 
                style: this.style),
            padding: EdgeInsets.all(5),
        );
    } else {
      return GestureDetector( child:
          Container(
            child: 
              Text(text, 
                style: this.style),
            padding: EdgeInsets.all(5)),
        onTap: () => _onRowTapped(rowIndex),
      );
    }
  }

  TableRow getHeaderRow() {
    JVxData data = getIt.get<JVxScreen>().getData(dataProvider);
    List<Widget> children = new List<Widget>();

    if (data!=null && data.columnNames!=null) {
      data.columnNames.forEach((c) {
        children.add(getTableColumn(c.toString(), -1));
      });
    }

    return getTableRow(children, true);
  }

  List<TableRow> getDataRows() {
    List<TableRow> rows = new List<TableRow>();
    
    JVxData data = getIt.get<JVxScreen>().getData(dataProvider);

    if (data!=null) {
      data.records.asMap().forEach((i,r) {
        if (r is List) {
          List<Widget> children = new List<Widget>();
          r.forEach((c) {
            children.add(getTableColumn(c.toString(), i));
          });

          rows.add(getTableRow(children, false));
        }
      });
    }
    return rows;
  }

  @override
  Widget getWidget() {
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

    rows.addAll(getDataRows());

    return Table(
      border: border,
      children: rows,
    );
  }
}