import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/ui/editor/celleditor/i_cell_editor.dart';
import 'package:jvx_flutterclient/ui/editor/jvx_table_column_calculator.dart';
import '../../model/api/response/meta_data/jvx_meta_data_column.dart';
import '../../model/changed_component.dart';
import '../../model/api/response/data/jvx_data.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/editor/jvx_editor.dart';
import '../../ui/screen/component_creator.dart';
import '../../ui/screen/component_data.dart';
import '../../utils/translations.dart';
import '../../utils/uidata.dart';
import '../../utils/globals.dart' as globals;

enum ContextMenuCommand { INSERT, DELETE }

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

  int selectedRow;

  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _scrollPositionListener =
      ItemPositionsListener.create();
  int pageSize = 100;
  double fetchMoreItemOffset = 20;
  JVxData _data;
  List<JVxTableColumn> columnInfo;
  var _tapPosition;
  ComponentCreator componentCreator;
  bool autoResize = false;
  bool _hasHorizontalScroller = false;

  TextStyle get headerTextStyle {
    return this.style;
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

  /*@override
  get preferredSize {
    if (super.preferredSize!=null) 
      return super.preferredSize;
    return Size(300, 300);
  }

  @override
  get minimumSize {
    if (super.minimumSize!=null) 
      return super.minimumSize;
    return Size(300, 100);
  }*/

  /*@override
  bool get isPreferredSizeSet => true;
  @override
  bool get isMinimumSizeSet => true;
  @override
  bool get isMaximumSizeSet => maximumSize != null;
*/
  JVxTable(GlobalKey componentId, BuildContext context, [this.componentCreator])
      : super(componentId, context) {
    if (componentCreator == null) componentCreator = ComponentCreator(context);
    _scrollPositionListener.itemPositions.addListener(_scrollListener);
  }

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    showVerticalLines = changedComponent.getProperty<bool>(
        ComponentProperty.SHOW_VERTICAL_LINES, showVerticalLines);
    showHorizontalLines = changedComponent.getProperty<bool>(
        ComponentProperty.SHOW_HORIZONTAL_LINES, showHorizontalLines);
    tableHeaderVisible = changedComponent.getProperty<bool>(
        ComponentProperty.TABLE_HEADER_VISIBLE, tableHeaderVisible);
    columnNames = changedComponent.getProperty<List<String>>(
        ComponentProperty.COLUMN_NAMES, columnNames);
    columnLabels = changedComponent.getProperty<List<String>>(
        ComponentProperty.COLUMN_LABELS, columnLabels);
    autoResize = changedComponent.getProperty<bool>(
        ComponentProperty.AUTO_RESIZE, autoResize);

    int newSelectedRow =
        changedComponent.getProperty<int>(ComponentProperty.SELECTED_ROW);
    if (newSelectedRow != null &&
        newSelectedRow >= 0 &&
        newSelectedRow != selectedRow &&
        this.data != null &&
        this.data.data != null)
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
            color: UIData.ui_kit_color_2[500]
                .withOpacity(globals.applicationStyle.controlsOpacity),
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
              : Colors.white.withOpacity(0.1),
        ),
        child: Material(
            color: isSelected
                ? UIData.ui_kit_color_2[100].withOpacity(0.1)
                : Colors.white.withOpacity(0.1),
            child: InkWell(
                highlightColor: UIData.ui_kit_color_2[500]
                    .withOpacity(globals.applicationStyle.controlsOpacity),
                onTap: () {
                  _onRowTapped(index);
                },
                child: Row(children: children))),
      );
    }
  }

  PopupMenuItem<ContextMenuModel> _getContextMenuItem(
      IconData icon, String text, ContextMenuModel value) {
    return PopupMenuItem<ContextMenuModel>(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.grey[600],
          ),
          Text(Translations.of(context).text2(text)),
        ],
      ),
      enabled: true,
      value: value,
    );
  }

  showContextMenu(BuildContext context, int index) {
    List<PopupMenuEntry<ContextMenuModel>> popupMenuEntries =
        List<PopupMenuEntry<ContextMenuModel>>();

    if (this.data.insertEnabled) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.plusSquare,
          'Insert', ContextMenuModel(index, ContextMenuCommand.INSERT)));
    }

    if (this.data.deleteEnabled && index>=0) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.minusSquare,
          'Delete', ContextMenuModel(index, ContextMenuCommand.DELETE)));
    }

    if (this.data.insertEnabled) {
      showMenu(
              position: RelativeRect.fromRect(_tapPosition & Size(40, 40),
                  Offset.zero & MediaQuery.of(context).size),
              context: context,
              items: popupMenuEntries)
          .then((val) {
        if (val != null) {
          if (val.command == ContextMenuCommand.INSERT)
            this.data.insertRecord(context);
          else if (val.command == ContextMenuCommand.DELETE)
            this.data.deleteRecord(context, val.index);
        }
      });
    }
  }

  ICellEditor _getCellEditorForColumn(String text, String columnName) {
    JVxMetaDataColumn column = this.data.getMetaDataColumn(columnName);

    if (column != null) {
      ICellEditor clEditor =
          componentCreator.createCellEditorForTable(column.cellEditor);
      // clEditor.onValueChanged = onValueChanged;
      clEditor?.editable = false;
      clEditor?.value = text;
      return clEditor;
    }
    return null;
  }

  Widget getTableColumn(
      String text, int rowIndex, int columnIndex, String columnName) {
    ICellEditor cellEditor = _getCellEditorForColumn(text, columnName);
    double width = 1;

    if (columnInfo != null && columnIndex < columnInfo.length)
      width = columnInfo[columnIndex].preferredWidth;

    if (rowIndex == -1) {
      return Container(
          width: width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
            child: Container(
              child: Text(text, style: this.headerTextStyle),
            ),
          ));
    } else {
      return Container(
          width: width,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
            child: GestureDetector(
              child: Container(
                  child: (cellEditor != null)
                      ? cellEditor.getWidget()
                      : Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(text, style: this.itemTextStyle),
                        )),
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

      if (this.data.deleteEnabled && !_hasHorizontalScroller) {
        return GestureDetector(
            onLongPress: () => showContextMenu(context, index),
            child: Slidable(
              actionExtentRatio: 0.25,
              child: Container(
                  color: Colors.white
                      .withOpacity(globals.applicationStyle.controlsOpacity),
                  child: getTableRow(children, index, false, isSelected)),
              actionPane: SlidableDrawerActionPane(),
              secondaryActions: <Widget>[
                new IconSlideAction(
                  caption: Translations.of(context).text2('Delete'),
                  color: Colors.red
                      .withOpacity(globals.applicationStyle.controlsOpacity),
                  icon: Icons.delete,
                  onTap: () => this.data.deleteRecord(context, index),
                ),
              ],
            ));
      } else {
        return GestureDetector(
            onLongPress: () => showContextMenu(context, index),
            child: Container(
                color: Colors.white
                    .withOpacity(globals.applicationStyle.controlsOpacity),
                child: getTableRow(children, index, false, isSelected)));
      }
    }

    return Container();
  }

  @override
  void onServerDataChanged() {}

  void onSelectedRowChanged(dynamic selectedRow) {
    if (_scrollController != null &&
        selectedRow is int &&
        selectedRow >= 0 &&
        _scrollController.isAttached) {
      _scrollController.scrollTo(
          index: selectedRow,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease);
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
    ItemPosition pos = this
        ._scrollPositionListener
        .itemPositions
        .value
        .lastWhere((itemPosition) => itemPosition.itemTrailingEdge > 0,
            orElse: () => null);

    if (pos != null &&
        _data != null &&
        _data.records != null &&
        pos.index + fetchMoreItemOffset > _data.records.length) {
      data.getData(context, this.pageSize + _data.records.length);
    }
  }

  @override
  Widget getWidget() {
    double borderWidth = 1;
    int itemCount = tableHeaderVisible ? 1 : 0;
    _data = data.getData(context, pageSize);

    if (_data != null && _data.records != null)
      itemCount += _data.records.length;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        //print(this.rawComponentId + "- Constraints:" + constraints.toString());
        this.columnInfo = JVxTableColumnCalculator.getColumnFlex(
            this.data,
            this.columnLabels,
            this.columnNames,
            itemTextStyle,
            componentCreator,
            autoResize,
            constraints.maxWidth,
            16.0,
            16.0);
        double columnWidth =
            JVxTableColumnCalculator.getColumnWidthSum(this.columnInfo);
        double tableHeight = JVxTableColumnCalculator.getPreferredTableHeight(this.data, this.columnLabels, itemTextStyle, 30, 30);

        _hasHorizontalScroller = (columnWidth > constraints.maxWidth);

        Widget widget = GestureDetector(
          onTapDown: (details) => _tapPosition = details.globalPosition,
          onLongPress: () => showContextMenu(context, -1),
          child: Container(
            decoration: _hasHorizontalScroller
                ? null
                : BoxDecoration(
                    border: Border.all(
                        width: borderWidth,
                        color: UIData.ui_kit_color_2[500].withOpacity(
                            globals.applicationStyle.controlsOpacity)),
                    color: Colors.white
                        .withOpacity(globals.applicationStyle.controlsOpacity)),
            width: columnWidth + (2 * borderWidth),
            height: constraints.maxHeight==double.infinity?tableHeight:constraints.maxHeight,
            child: ScrollablePositionedList.builder(
              key: this.componentId,
              itemScrollController: _scrollController,
              itemPositionsListener: _scrollPositionListener,
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
          ),
        );

        if (_hasHorizontalScroller) {
          return Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      width: borderWidth,
                      color: UIData.ui_kit_color_2[500].withOpacity(
                          globals.applicationStyle.controlsOpacity)),
                  color: Colors.white
                      .withOpacity(globals.applicationStyle.controlsOpacity)),
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, child: widget));
        } else {
          return widget;
        }
      },
    );
  }
}

class ContextMenuModel {
  int index;
  ContextMenuCommand command;

  ContextMenuModel(this.index, this.command);
}
