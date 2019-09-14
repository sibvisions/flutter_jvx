
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_editor.dart';

class JVxTable extends JVxEditor {
  // the show vertical lines flag.
	bool showVerticalLines = true;
	// the show horizontal lines flag.
	bool showHorizontalLines = true;

  Size maximumSize;

  JVxTable(Key componentId, BuildContext context) : super(componentId, context);

    @override
  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    maximumSize = properties.getProperty<Size>("maximumSize",null);
    dataProvider = properties.getProperty<String>("dataProvider");
    dataRow = properties.getProperty<String>("dataRow");
    columnName = properties.getProperty<String>("columnName");
    readonly = properties.getProperty<bool>("readonly", readonly);
    eventFocusGained = properties.getProperty<bool>("eventFocusGained", eventFocusGained);
  }

  TableRow getHeaderRow() {
     List<Widget> children = <Widget> [
       Text("Anrede - Test"),
       Text("Title -Test"),
       Text("Nachname"),
       Text("Vorname")
     ]; 

     return TableRow(
       decoration: BoxDecoration(
         color: Colors.grey[300]
       ),
       children: children);
  }

  List<TableRow> getDataRows() {
    
  }

  @override
  Widget getWidget() {

    TableBorder border = TableBorder.all();
    List<TableRow> rows = new List<TableRow>();

    rows.add(getHeaderRow());

    return Table(
      border: border,
      children: rows,
    );
  }
}