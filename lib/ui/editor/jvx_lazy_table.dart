import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
import 'package:jvx_mobile_v3/ui/editor/jvx_editor.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';
import 'package:jvx_mobile_v3/utils/text_utils.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class JVxLazyTable extends JVxEditor {
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
  int pageSize = 100;
  double fetchMoreYOffset = 0;
  JVxData _data;
  List<int> columnFlex;

  TextStyle get headerTextStyle {
    return TextStyle(
        fontSize: style.fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700]);
  }

  TextStyle get itemTextStyle {
    return this.style;
  }

  @override
  set data(ComponentData data) {
    super.data?.unregisterDataChanged(onServerDataChanged);
    super.data = data;
    super.data?.registerDataChanged(onServerDataChanged);
  }

  JVxLazyTable(Key componentId, BuildContext context)
      : super(componentId, context) {
    _scrollController.addListener(_scrollListener);
  }

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, null);
    showVerticalLines = changedComponent.getProperty<bool>(
        ComponentProperty.SHOW_VERTICAL_LINES, showVerticalLines);
    showHorizontalLines = changedComponent.getProperty<bool>(
        ComponentProperty.SHOW_HORIZONTAL_LINES, showHorizontalLines);
    tableHeaderVisible = changedComponent.getProperty<bool>(
        ComponentProperty.TABLE_HEADER_VISIBLE, tableHeaderVisible);
    columnNames = changedComponent.getProperty<List<String>>(
        ComponentProperty.COLUMN_NAMES, columnNames);
    reload = changedComponent.getProperty<int>(ComponentProperty.RELOAD);
    columnLabels = changedComponent.getProperty<List<String>>(
        ComponentProperty.COLUMN_LABELS, columnLabels);
    reload =
        changedComponent.getProperty<int>(ComponentProperty.RELOAD, reload);
  }

  void _onRowTapped(int index) {
    data.selectRecord(context, index);
  }

  Widget getTableRow(List<Widget> children, int index, bool isHeader) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: UIData.ui_kit_color_2[200],
          ),
          child: Row(children: children));
    } else {
      return Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: Colors.white,
          ),
        child: ListTile(onTap: () => _onRowTapped(index), title: Row(children: children)),
      );
    }
  }

  Widget getTableColumn(String text, int rowIndex, int columnIndex) {
    int flex = 1;

    if (columnFlex != null && columnIndex < columnFlex.length)
      flex = columnFlex[columnIndex];

    if (rowIndex == -1) {
      return Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Text(Properties.utf8convert(text),
                  style: this.headerTextStyle),
              padding: EdgeInsets.all(5),
            ),
          ));
    } else {
      return Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: Container(
                  child: Text(Properties.utf8convert(text),
                      style: this.itemTextStyle),
                  padding: EdgeInsets.all(5)),
              onTap: () => _onRowTapped(rowIndex),
            ),
          ));
    }
  }

  Container getHeaderRow() {
    List<Widget> children = new List<Widget>();

    if (this.columnLabels != null) {
      this.columnLabels.asMap().forEach((i, c) {
        children.add(getTableColumn(c.toString(), -1, i));
      });
    }

    return getTableRow(children, 0, true);
  }

  Widget getDataRow(JVxData data, int index) {

    if (data != null && data.records != null && index < data.records.length) {
      List<Widget> children = new List<Widget>();

      data.getRow(index, columnNames).asMap().forEach((i,c) {
        children.add(getTableColumn(
              c != null ? c.toString() : "", index, i));
      });

      return Dismissible(
        confirmDismiss: (DismissDirection direction) async =>
            Future.delayed(Duration(seconds: 2), () => true),
        background: Container(
          color: Colors.red,
          child: Text('DELETE'),
        ),
        child: Container(color: Colors.white, child: getTableRow(children, index, false)),
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) => this.data.deleteRecord(context, index),
      );
    }

    return Container();
  }

  @override
  void onServerDataChanged() {}

  Widget itemBuilder(BuildContext ctxt, int index) {
    if (index == 0 && tableHeaderVisible) {
      return getHeaderRow();
    } else {
      if (tableHeaderVisible) index--;
      return getDataRow(_data, index);
    }
  }

  _scrollListener() {
    fetchMoreYOffset = MediaQuery.of(context).size.height * 4;
    if (_scrollController.offset + this.fetchMoreYOffset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_data != null && _data.records != null)
        data.getData(
            context, this.reload, this.pageSize + _data.records.length);
    }
  }

  @override
  Widget getWidget() {
    //List<TableRow> rows = new List<TableRow>();
    TableBorder border = TableBorder();
    //Map<int, TableColumnWidth> columnWidths = Map<int,TableColumnWidth>();

    if (showHorizontalLines && !showVerticalLines) {
      border = TableBorder(bottom: BorderSide(), top: BorderSide());
    } else if (!showHorizontalLines && showVerticalLines) {
      border = TableBorder(left: BorderSide(), right: BorderSide());
    } else if (showHorizontalLines && showVerticalLines) {
      border = TableBorder.all();
    }

    int itemCount = tableHeaderVisible ? 1 : 0;
    _data = data.getData(context, reload, pageSize);
    this.reload = null;

    this.columnFlex = _data.getColumnFlex(this.columnLabels, this.columnNames, itemTextStyle);

    if (_data != null && _data.records != null)
      itemCount += _data.records.length;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Container(
        width: constraints.minWidth,
        height: constraints.minHeight,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}
