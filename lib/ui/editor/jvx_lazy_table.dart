import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../model/api/response/meta_data/jvx_meta_data_column.dart';
import '../../model/changed_component.dart';
import '../../model/api/response/data/jvx_data.dart';
import '../../model/properties/component_properties.dart';
import '../../model/properties/properties.dart';
import '../../ui/editor/celleditor/jvx_cell_editor.dart';
import '../../ui/editor/celleditor/jvx_checkbox_cell_editor.dart';
import '../../ui/editor/celleditor/jvx_choice_cell_editor.dart';
import '../../ui/editor/jvx_editor.dart';
import '../../ui/screen/component_creator.dart';
import '../../ui/screen/component_data.dart';
import '../../utils/translations.dart';
import '../../utils/uidata.dart';

class JVxLazyTable extends JVxEditor {
  Key key = GlobalKey();
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

  int selectedRow;

  Size maximumSize;

  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _scrollPositionListener = ItemPositionsListener.create();
  int pageSize = 100;
  double fetchMoreItemOffset = 20;
  JVxData _data;
  List<int> columnFlex;
  var _tapPosition;
  ComponentCreator componentCreator;

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
    super.data?.unregisterSelectedRowChanged(onSelectedRowChanged);
    super.data = data;
    super.data?.registerDataChanged(onServerDataChanged);
    super.data?.registerSelectedRowChanged(onSelectedRowChanged);
  }

  @override
  get preferredSize {
    return Size(300,300);
  }

  @override
  get minimumSize {
    return Size(50,100);
  }

  @override
  bool get isPreferredSizeSet => preferredSize!=null;
  @override
  bool get isMinimumSizeSet => minimumSize!=null;
  @override
  bool get isMaximumSizeSet => maximumSize!=null;

  JVxLazyTable(Key componentId, BuildContext context)
      : super(componentId, context) {
    componentCreator = ComponentCreator(context);
    _scrollPositionListener.itemPositions.addListener(_scrollListener);
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

    int newSelectedRow = changedComponent.getProperty<int>(
        ComponentProperty.SELECTED_ROW);
    if (newSelectedRow!=null && newSelectedRow>=0 && newSelectedRow!=selectedRow && this.data!=null && this.data.data!=null)
      this.data.updateSelectedRow(newSelectedRow, true);
    
    selectedRow = changedComponent.getProperty<int>(
        ComponentProperty.SELECTED_ROW, selectedRow);
  }

  void _onRowTapped(int index) {
    data.selectRecord(context, index);
  }

  Widget getTableRow(
      List<Widget> children, int index, bool isHeader, bool isSelected) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: UIData.ui_kit_color_2[500],
          ),
          child: Row(children: children));
    } else {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.grey[400].withOpacity(0.5), spreadRadius: 1)
          ],
          color: isSelected
              ? UIData.ui_kit_color_2[100].withOpacity(0.1)
              : Colors.white,
        ),
        child: Material(
            color: isSelected
                ? UIData.ui_kit_color_2[100].withOpacity(0.1)
                : Colors.white,
            child: InkWell(
                highlightColor: UIData.ui_kit_color_2[500],
                onTap: () {
                  _onRowTapped(index);
                },
                child: Container(height: 60, child: Row(children: children)))),
      );
    }
  }

  showContextMenu(BuildContext context) {
    if (this.data.insertEnabled) {
      showMenu(
          position: RelativeRect.fromRect(_tapPosition & Size(40, 40),
              Offset.zero & MediaQuery.of(context).size),
          context: context,
          items: <PopupMenuEntry<int>>[
            PopupMenuItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.plusSquare,
                    color: Colors.grey[600],
                  ),
                  Text(Translations.of(context).text2('Insert')),
                ],
              ),
              enabled: true,
              value: 1,
            )
          ]).then((val) {
        if (val != null) {
          this.data.insertRecord(context);
        }
      });
    }
  }

  JVxCellEditor _getCellEditorForColumn(String text, String columnName) {
    JVxMetaDataColumn column = this
        .data
        .metaData
        .columns
        .firstWhere((col) => col.name == columnName, orElse: () => null);

    if (column != null) {
      JVxCellEditor clEditor = componentCreator.createCellEditor(column.cellEditor);
      // clEditor.onValueChanged = onValueChanged;
      clEditor.editable = false;
      clEditor.value = text;
      return clEditor;
    }
    return null;
  }

  Widget getTableColumn(
      String text, int rowIndex, int columnIndex, String columnName) {
    JVxCellEditor cellEditor = _getCellEditorForColumn(text, columnName);
    int flex = 1;

    if (columnFlex != null && columnIndex < columnFlex.length)
      flex = columnFlex[columnIndex];

    if (rowIndex == -1) {
      return Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Text(text,
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
                  // only for development
                  child: (cellEditor is JVxChoiceCellEditor || cellEditor is JVxCheckboxCellEditor)
                      ? cellEditor.getWidget()
                      : Text(text),
                  // child: Text(Properties.utf8convert(text),
                  //     style: this.itemTextStyle),
                  padding: EdgeInsets.all(5)),
              onTap: () => _onRowTapped(rowIndex),
            ),
          ));
    }
  }

  Widget getHeaderRow() {
    List<Widget> children = new List<Widget>();

    if (this.columnLabels != null) {
      this.columnLabels.asMap().forEach((i, c) {
        children.add(getTableColumn(c.toString(), -1, i, columnNames[i]));
      });
    }

    return getTableRow(children, 0, true, false);
  }

  Widget getDataRow(JVxData data, int index) {
    if (data != null && data.records != null && index < data.records.length) {
      List<Widget> children = new List<Widget>();

      data.getRow(index, columnNames).asMap().forEach((i, c) {
        children.add(getTableColumn(
            c != null ? c.toString() : "", index, i, columnNames[i]));
      });

      bool isSelected = index == data.selectedRow;
      if (this.selectedRow != null) isSelected = index == this.selectedRow;

      if (this.data.deleteEnabled) {
        return Slidable(
          actionExtentRatio: 0.25,
          child: Container(
              color: Colors.white,
              child: getTableRow(children, index, false, isSelected)),
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: <Widget>[
            new IconSlideAction(
              caption: Translations.of(context).text2('Delete'),
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => this.data.deleteRecord(context, index),
            ),
          ],
        );
      } else {
        return Container(
            color: Colors.white,
            child: getTableRow(children, index, false, isSelected));
      }
    }

    return Container();
  }

  @override
  void onServerDataChanged() {}

  void onSelectedRowChanged(dynamic selectedRow) {
    if (_scrollController!=null && selectedRow is int && selectedRow >=0) {
      _scrollController.scrollTo(index: selectedRow, duration: Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    if (index == 0 && tableHeaderVisible) {
      return getHeaderRow();
    } else {
      if (tableHeaderVisible) index--;
      return getDataRow(_data, index);
    }
  }

  _scrollListener() {
    ItemPosition pos = this._scrollPositionListener.itemPositions.value.lastWhere((itemPosition) => itemPosition.itemTrailingEdge>0);

    if (pos!=null && _data!=null && _data.records!=null && pos.index+fetchMoreItemOffset > _data.records.length) {
      data.getData(
            context, this.reload, this.pageSize + _data.records.length);
    }
  }

  @override
  Widget getWidget() {
    int itemCount = tableHeaderVisible ? 1 : 0;
    _data = data.getData(context, reload, pageSize);
    this.reload = null;

    this.columnFlex =
        _data.getColumnFlex(this.columnLabels, this.columnNames, itemTextStyle);

    if (_data != null && _data.records != null)
      itemCount += _data.records.length;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          GestureDetector(
        onTapDown: (details) => _tapPosition = details.globalPosition,
        onLongPress: () => showContextMenu(context),
        child: Container(
          width: constraints.minWidth,
          height: constraints.minHeight,
          child: ScrollablePositionedList.builder(
            key: this.key,
            itemScrollController: _scrollController,
            itemPositionsListener: _scrollPositionListener,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        ),
      ),
    );
  }
}
