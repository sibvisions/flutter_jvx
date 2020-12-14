import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../models/api/response/data/data_book.dart';
import '../../models/api/response/meta_data/data_book_meta_data_column.dart';
import '../../utils/translation/app_localizations.dart';
import '../editor/co_editor_widget.dart';
import '../screen/so_component_creator.dart';
import 'models/table_component_model.dart';
import 'so_table_column_calculator.dart';

enum ContextMenuCommand { INSERT, DELETE }

class CoTableWidget extends CoEditorWidget {
  final TableComponentModel componentModel;
  final BuildContext customDataOperationContext;

  CoTableWidget({this.componentModel, this.customDataOperationContext})
      : super(componentModel: componentModel);

  State<StatefulWidget> createState() => CoTableWidgetState();
}

class CoTableWidgetState extends CoEditorWidgetState<CoTableWidget> {
  ItemScrollController scrollController;
  ItemPositionsListener scrollPositionListener;

  void onSelectedRowChanged(dynamic selectedRow) {
    if (this.scrollController != null &&
        selectedRow is int &&
        selectedRow >= 0 &&
        this.scrollController.isAttached) {
      this.scrollController.scrollTo(
          index: selectedRow,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease);
    }
  }

  @override
  void onServerDataChanged() {
    setState(() {});
  }

  @override
  void registerCallbacks() {
    super.registerCallbacks();

    widget.componentModel.onSelectedRowChangedCallback =
        this.onSelectedRowChanged;
  }

  scrollListener(BuildContext context) {
    ItemPosition pos = this
        .scrollPositionListener
        .itemPositions
        .value
        .lastWhere((itemPosition) => itemPosition.itemTrailingEdge > 0,
            orElse: () => null);

    if (pos != null &&
        widget.componentModel.data.data != null &&
        widget.componentModel.data.data.records != null &&
        pos.index + widget.componentModel.fetchMoreItemOffset >
            widget.componentModel.data.data.records.length) {
      widget.componentModel.data?.getData(
          widget.customDataOperationContext != null
              ? widget.customDataOperationContext
              : context,
          widget.componentModel.pageSize +
              widget.componentModel.data.data.records.length);
    }
  }

  void _onRowTapped(int index) {
    if (widget.componentModel.onRowTapped == null) {
      widget.componentModel?.data?.selectRecord(
          widget.customDataOperationContext != null
              ? widget.customDataOperationContext
              : context,
          index);
    } else {
      widget.componentModel.onRowTapped(index);
    }
  }

  Widget getTableRow(
      List<Widget> children, int index, bool isHeader, bool isSelected) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white.withOpacity(widget.componentModel.appState
                    .applicationStyle?.controlsOpacity ??
                1.0),
          ),
          child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 1,
                          color: Colors.grey[800],
                          style: BorderStyle.solid))),
              child: Row(children: children)));
    } else {
      Color backgroundColor = Colors.white.withOpacity(
          widget.componentModel.appState.applicationStyle?.controlsOpacity ??
              1.0);

      if (isSelected)
        backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
      else if (index % 2 == 1) {
        backgroundColor = Colors.grey[200].withOpacity(
            widget.componentModel.appState.applicationStyle?.controlsOpacity ??
                1.0);
      }
      return Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Colors.grey[400],
                    width: 1,
                    style: BorderStyle.solid)),
          ),
          child: Material(
              color: backgroundColor,
              child: InkWell(
                  highlightColor: Theme.of(context).primaryColor.withOpacity(
                      widget.componentModel.appState.applicationStyle
                              ?.controlsOpacity ??
                          1.0),
                  onTap: () {
                    _onRowTapped(index);
                  },
                  child: Row(children: children))),
        ),
      );
    }
  }

  PopupMenuItem<ContextMenuModel> _getContextMenuItem(
      IconData icon, String text, ContextMenuModel value) {
    return PopupMenuItem<ContextMenuModel>(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.grey[600],
          ),
          Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(AppLocalizations.of(context).text(text))),
        ],
      ),
      enabled: true,
      value: value,
    );
  }

  showContextMenu(BuildContext context, int index) {
    List<PopupMenuEntry<ContextMenuModel>> popupMenuEntries =
        List<PopupMenuEntry<ContextMenuModel>>();

    if (widget.componentModel.data?.insertEnabled ?? false) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.plusSquare,
          'Insert', ContextMenuModel(index, ContextMenuCommand.INSERT)));
    }

    if (index >= 0 &&
        (widget.componentModel.data != null &&
            widget.componentModel.data.deleteEnabled)) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.minusSquare,
          'Delete', ContextMenuModel(index, ContextMenuCommand.DELETE)));
    }

    if (widget.componentModel.data?.insertEnabled ?? false) {
      showMenu(
              position: RelativeRect.fromRect(
                  widget.componentModel.tapPosition & Size(40, 40),
                  Offset.zero & MediaQuery.of(context).size),
              context: context,
              items: popupMenuEntries)
          .then((val) {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        if (val != null) {
          if (val.command == ContextMenuCommand.INSERT)
            widget.componentModel.data?.insertRecord(context);
          else if (val.command == ContextMenuCommand.DELETE)
            widget.componentModel.data?.deleteRecord(context, val.index);
        }
      });
    }
  }

  Widget getTableColumn(
      String text, int rowIndex, int columnIndex, String columnName,
      {bool nullable}) {
    CoEditorWidget editor = widget.componentModel
        .getEditorForColumn(context, text, columnName, rowIndex);
    double width = 1;

    if (widget.componentModel.columnInfo != null &&
        columnIndex < widget.componentModel.columnInfo.length)
      width = widget.componentModel.columnInfo[columnIndex].preferredWidth;

    if (rowIndex == -1) {
      return Container(
          width: width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
            child: Container(
              child: Row(
                children: [
                  Text(text,
                      style: !nullable
                          ? widget.componentModel.headerStyleMandatory
                          : widget.componentModel.headerTextStyle),
                  SizedBox(
                    width: 2,
                  ),
                  !nullable
                      ? Container(
                          child: FaIcon(
                            FontAwesomeIcons.asterisk,
                            size: 8,
                          ),
                          alignment: Alignment.bottomRight,
                        )
                      : Text(''),
                ],
              ),
            ),
          ));
    } else {
      return Container(
          width: width,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
            child: GestureDetector(
              child: Container(
                  child: (editor != null)
                      ? editor
                      : Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(text,
                              style: (widget?.componentModel
                                      as TableComponentModel)
                                  .itemTextStyle),
                        )),
              onTap: () => _onRowTapped(rowIndex),
            ),
          ));
    }
  }

  Widget getHeaderRow() {
    List<Widget> children = new List<Widget>();

    if (widget.componentModel.columnLabels != null) {
      widget.componentModel.columnLabels.asMap().forEach((i, c) {
        DataBookMetaDataColumn column = widget.componentModel.data
            ?.getMetaDataColumn(widget.componentModel.columnNames[i]);
        if (column != null && column.nullable) {
          children.add(getTableColumn(
              c.toString(), -1, i, widget.componentModel.columnNames[i],
              nullable: column?.nullable ?? false));
        } else {
          children.add(getTableColumn(
              c.toString(), -1, i, widget.componentModel.columnNames[i],
              nullable: column?.nullable ?? false));
        }
      });
    }

    return getTableRow(children, 0, true, false);
  }

  Widget getDataRow(DataBook data, int index) {
    if (data != null && data.records != null && index < data.records.length) {
      List<Widget> children = new List<Widget>();

      data
          .getRow(index, widget.componentModel.columnNames)
          .asMap()
          .forEach((i, c) {
        children.add(getTableColumn(c != null ? c.toString() : "", index, i,
            widget.componentModel.columnNames[i]));
      });

      bool isSelected = index == data.selectedRow;
      if (widget.componentModel.selectedRow != null)
        isSelected = index == widget.componentModel.selectedRow;

      if (widget.componentModel.data != null &&
          widget.componentModel.data.deleteEnabled &&
          !widget.componentModel.hasHorizontalScroller) {
        return widget.componentModel.editable
            ? GestureDetector(
                onLongPress: () => showContextMenu(context, index),
                child: Slidable(
                  actionExtentRatio: 0.25,
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(widget.componentModel
                                .appState.applicationStyle?.controlsOpacity ??
                            1.0),
                      ),
                      child: getTableRow(children, index, false, isSelected)),
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: <Widget>[
                    new IconSlideAction(
                      caption: AppLocalizations.of(context).text('Delete'),
                      color: Colors.red.withOpacity(widget.componentModel
                              .appState.applicationStyle?.controlsOpacity ??
                          1.0),
                      icon: Icons.delete,
                      onTap: () => widget.componentModel.data
                          ?.deleteRecord(context, index),
                    ),
                  ],
                ))
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(widget.componentModel.appState
                          .applicationStyle?.controlsOpacity ??
                      1.0),
                ),
                child: getTableRow(children, index, false, isSelected));
      } else {
        return GestureDetector(
            onLongPress: () => widget.componentModel.editable
                ? showContextMenu(context, index)
                : null,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(widget.componentModel
                            .appState.applicationStyle?.controlsOpacity ??
                        1.0)),
                child: getTableRow(children, index, false, isSelected)));
      }
    }

    return Container();
  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    if (index == 0 && widget.componentModel.tableHeaderVisible) {
      return getHeaderRow();
    } else {
      if (widget.componentModel.tableHeaderVisible) index--;
      return getDataRow(widget.componentModel.data.data, index);
    }
  }

  @override
  void initState() {
    super.initState();
    this.scrollController = ItemScrollController();
    this.scrollPositionListener = ItemPositionsListener.create();
    if (widget.componentModel.componentCreator == null)
      widget.componentModel.componentCreator = SoComponentCreator(context);
    this
        .scrollPositionListener
        .itemPositions
        .addListener(() => this.scrollListener(context));
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = widget.componentModel.tableHeaderVisible ? 1 : 0;
    widget.componentModel.data
        ?.getData(context, widget.componentModel.pageSize);

    if (widget.componentModel.data?.data != null &&
        widget.componentModel.data?.data?.records != null)
      itemCount += widget.componentModel.data.data.records.length;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        //print(this.rawComponentId + "- Constraints:" + constraints.toString());
        widget.componentModel.columnInfo =
            SoTableColumnCalculator.getColumnFlex(
                widget.componentModel.data,
                widget.componentModel.columnLabels,
                widget.componentModel.columnNames,
                widget.componentModel.itemTextStyle,
                widget.componentModel.componentCreator,
                widget.componentModel.autoResize,
                constraints.maxWidth,
                16.0,
                16.0);
        double columnWidth = SoTableColumnCalculator.getColumnWidthSum(
            widget.componentModel.columnInfo);
        double tableHeight = SoTableColumnCalculator.getPreferredTableHeight(
            widget.componentModel.data,
            widget.componentModel.columnLabels,
            widget.componentModel.itemTextStyle,
            widget.componentModel.tableHeaderVisible,
            30,
            30);

        widget.componentModel.hasHorizontalScroller =
            (columnWidth + (2 * widget.componentModel.borderWidth) >
                constraints.maxWidth);

        Widget child = GestureDetector(
            onTapDown: (details) =>
                widget.componentModel.tapPosition = details.globalPosition,
            onLongPress: () => showContextMenu(context, -1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    width: widget.componentModel.borderWidth,
                    color: Theme.of(context).primaryColor.withOpacity(widget
                            .componentModel
                            .appState
                            .applicationStyle
                            ?.controlsOpacity ??
                        1.0)),
                color: Colors.white.withOpacity(widget.componentModel.appState
                        .applicationStyle?.controlsOpacity ??
                    1.0),
              ),
              child: widget.componentModel.hasHorizontalScroller
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: columnWidth +
                            (2 * widget.componentModel.borderWidth) +
                            100,
                        height: constraints.maxHeight == double.infinity
                            ? tableHeight
                            : constraints.maxHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: ScrollablePositionedList.builder(
                            itemScrollController: this.scrollController,
                            itemPositionsListener: this.scrollPositionListener,
                            itemCount: itemCount,
                            itemBuilder: itemBuilder,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: (columnWidth +
                              (2 * widget.componentModel.borderWidth) +
                              100) -
                          widget.componentModel.borderWidth,
                      height: constraints.maxHeight == double.infinity
                          ? tableHeight - widget.componentModel.borderWidth
                          : constraints.maxHeight -
                              widget.componentModel.borderWidth,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: ScrollablePositionedList.builder(
                          itemScrollController: this.scrollController,
                          itemPositionsListener: this.scrollPositionListener,
                          itemCount: itemCount,
                          itemBuilder: itemBuilder,
                        ),
                      ),
                    ),
            ));

        return child;
      },
    );
  }
}

class ContextMenuModel {
  int index;
  ContextMenuCommand command;

  ContextMenuModel(this.index, this.command);
}
