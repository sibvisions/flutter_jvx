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

  Container getTableRow(List<Widget> children, bool isHeader) {
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
          child: Row(children: children));
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

    return getTableRow(children, true);
  }

  Widget getDataRow(JVxData data, int index) {
    List<Widget> children = new List<Widget>();
    List<int> visibleColumnsIndex = new List<int>();

    if (data != null && data.records != null && index < data.records.length) {
      List<dynamic> columns = data.records[index];

      columnNames.forEach((r) {
        visibleColumnsIndex.add(data.columnNames.indexOf(r));
      });

      visibleColumnsIndex.asMap().forEach((i, j) {
        if (j < columns.length)
          children.add(getTableColumn(
              columns[j] != null ? columns[j].toString() : "", index, i));
        else
          children.add(getTableColumn("", index, j));
      });

      return Dismissible(
        confirmDismiss: (DismissDirection direction) async => Future.delayed(Duration(seconds: 2), () => true),
        background: Container(color: Colors.red, child: Text('DELETE'),),
        child: getTableRow(children, false),
        key: Key(index.toString()),
        onDismissed: (DismissDirection direction) =>
            print(direction.toString()),
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

  void calculateColumnFlex() {
    int calculateForRecordCount = 10;

    List<int> maxLengthPerColumn = new List<int>(this.columnLabels.length);
    columnLabels.asMap().forEach((i, l) {
      int textWidth = TextUtils.getTextWidth(l, itemTextStyle);
      maxLengthPerColumn[i] = textWidth;
    });

    if (_data != null && _data.records != null) {
      List<int> visibleColumnsIndex = new List<int>();
      columnNames.forEach((r) {
        visibleColumnsIndex.add(_data.columnNames.indexOf(r));
      });

      if (_data.records.length < calculateForRecordCount)
        calculateForRecordCount = _data.records.length;

      for (int ii = 0; ii < calculateForRecordCount; ii++) {
        List<dynamic> columns = _data.records[ii];
        visibleColumnsIndex.asMap().forEach((i, j) {
          if (j < columns.length && columns[j] != null) {
            String value = columns[j] != null ? columns[j].toString() : "";
            int textWidth = TextUtils.getTextWidth(value, itemTextStyle);
            if (maxLengthPerColumn[i] == null ||
                maxLengthPerColumn[i] < textWidth) {
              maxLengthPerColumn[i] = textWidth;
            }
          }
        });
      }
    }

    columnFlex = maxLengthPerColumn;
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

    this.calculateColumnFlex();

    if (_data != null && _data.records != null)
      itemCount += _data.records.length;

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
