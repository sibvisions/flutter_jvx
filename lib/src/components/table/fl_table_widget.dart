import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/api/response/dal_meta_data_response.dart';
import '../../model/component/table/fl_table_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'table_size.dart';

class FlTableWidget extends FlStatelessWidget<FlTableModel> with UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Contains all relevant table size information.
  final TableSize tableSize;

  /// The selected current row.
  final int selectedRow;

  /// Gets called with the index of the row that was touched when the user starts to pan.
  final Function(int, DragDownDetails?)? onRowTapDown;

  /// Gets called with the index of the row that was touched when the user tapped a row.
  final Function(int)? onRowTap;

  /// Gets called when the user swiped a row. -> use index of [onRowTapDown] to know which one.
  final Function()? onRowSwipe;

  /// Gets called when the user long pressed a row. -> use index of [onRowTapDown] to know which one.
  final VoidCallback? onLongPress;

  /// Gets called when the user scrolled to the edge of the table.
  final VoidCallback? onEndScroll;

  /// The data of the table.
  final DataChunk chunkData;

  /// The scroll controller of the table.
  final ItemScrollController? itemScrollController;

  /// The callback if a value has ended beeing changed in the table.
  final Function(dynamic value, int row, String column)? onEndEditing;

  /// The callback if a value has been changed in the table.
  final Function(dynamic value, int row, String column)? onValueChanged;

  /// Whether or not to disable all editors.
  final bool disableEditors;

  /// The scroll controller for the table.
  final ScrollController? tableHorizontalController;

  /// The scroll controller for the headers if they are set to sticky.
  final ScrollController? headerHorizontalController;

  /// The meta data of the data book.
  final DalMetaDataResponse? metaData;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If the headers are at the top of the list in the scrollable list.
  bool get buildHeadersInList => model.tableHeaderVisible && !model.stickyHeaders;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTableWidget({
    Key? key,
    required FlTableModel model,
    required this.chunkData,
    required this.tableSize,
    this.tableHorizontalController,
    this.headerHorizontalController,
    this.selectedRow = -1,
    this.onRowTapDown,
    this.onRowTap,
    this.onRowSwipe,
    this.onLongPress,
    this.onEndScroll,
    this.itemScrollController,
    this.onEndEditing,
    this.onValueChanged,
    this.metaData,
    this.disableEditors = false,
  }) : super(key: key, model: model);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(5.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(width: tableSize.borderWidth, color: Theme.of(context).primaryColor),
        color: Theme.of(context).backgroundColor,
      ),
      child: ClipRRect(
        // The clip rect is there to stop the rendering of the children.
        borderRadius: borderRadius, // Otherwise the children would clip the border of the parent container.
        child: createTable(context),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget createTable(BuildContext pContext) {
    Widget table = GestureDetector(
      onLongPress: model.isEnabled ? onLongPress : null,
      onPanDown: model.isEnabled ? ((DragDownDetails? pDragDetails) => onRowTapDown?.call(-1, pDragDetails)) : null,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: onInternalEndScroll,
        child: SingleChildScrollView(
          controller: tableHorizontalController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: max(tableSize.size.width, 0),
            ),
            child: ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemBuilder: itemBuilder,
              itemCount: _itemCount,
            ),
          ),
        ),
      ),
    );

    if (buildHeadersInList) {
      return table;
    }

    Widget headerRow = buildHeaderRow(pContext);

    return LayoutBuilder(
      builder: ((context, constraints) {
        return Column(
          children: [
            SizedBox(
              height: tableSize.tableHeaderHeight,
              width: max(constraints.maxWidth, 0),
              child: headerRow,
            ),
            SizedBox(
              height: max(constraints.maxHeight - tableSize.tableHeaderHeight, 0),
              width: max(constraints.maxWidth, constraints.maxWidth),
              child: table,
            ),
          ],
        );
      }),
    );
  }

  /// The item builder of the scrollable positioned list.
  Widget itemBuilder(BuildContext pContext, int pIndex) {
    int index = pIndex;
    if (buildHeadersInList) {
      index--;
      if (pIndex == 0) {
        return buildHeaderRow(pContext);
      }
    }

    return buildDataRow(index, pContext);
  }

  /// How many items the scrollable list should build.
  int get _itemCount {
    int itemCount = chunkData.data.length;

    if (buildHeadersInList) {
      itemCount += 1;
    }

    return itemCount;
  }

  /// Builds a data row.
  Widget buildDataRow(int pIndex, BuildContext context) {
    List<dynamic> data = chunkData.data[pIndex]!;

    List<Widget> rowWidgets = [];

    List<ColumnDefinition> columnsToShow =
        model.columnNames.map((e) => chunkData.columnDefinitions.firstWhere((element) => element.name == e)).toList();

    for (ColumnDefinition colDef in columnsToShow) {
      int columnIndex = columnsToShow.indexOf(colDef);
      int dataIndex = chunkData.columnDefinitions.indexOf(colDef);

      Widget? widget;
      var value = data[dataIndex];

      if (!disableEditors) {
        ICellEditor cellEditor = ICellEditor.getCellEditor(
          pName: model.name,
          pCellEditorJson: colDef.cellEditorJson,
          onChange: (value) => onValueChanged?.call(value, pIndex, colDef.name),
          onEndEditing: (value) => onEndEditing?.call(value, pIndex, colDef.name),
          pUiService: getUiService(),
        );

        cellEditor.setValue(value);

        FlStatelessWidget? tableWidget = cellEditor.createTableWidget();

        tableWidget?.model.applyFromJson(model.json);
        // Some parts of a json have to take priority.
        // As they override the properties.
        tableWidget?.model.applyCellEditorOverrides(model.json);

        widget = tableWidget;
      }

      widget ??= Text(
        (value ?? '').toString(),
        style: model.getTextStyle(),
        overflow: TextOverflow.ellipsis,
      );

      rowWidgets.add(
        IgnorePointer(
          ignoring: colDef.readonly || (metaData?.readOnly ?? false),
          child: SizedBox(
            width: tableSize.columnWidths[columnIndex].toDouble(),
            child: Padding(
              padding: tableSize.cellPadding,
              child: widget,
            ),
          ),
        ),
      );
    }

    double opacity = pIndex % 2 == 0 ? 0.00 : 0.15;

    if (pIndex == selectedRow) {
      opacity += 0.15;
    }

    return IgnorePointer(
      ignoring: !model.isEnabled,
      child: GestureDetector(
        onPanDown: (DragDownDetails? pDragDetails) => onRowTapDown?.call(pIndex, pDragDetails),
        onTap: () => onRowTap?.call(pIndex),
        child: Container(
          height: tableSize.rowHeight,
          decoration: BoxDecoration(
            color: pIndex == selectedRow
                ? Colors.blue.withOpacity(opacity)
                : Theme.of(context).primaryColor.withOpacity(opacity),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: rowWidgets,
          ),
        ),
      ),
    );
  }

  Widget buildHeaderRow(BuildContext context) {
    List<Widget> rowWidgets = [];

    for (String columnName in model.columnNames) {
      int colIndex = model.columnNames.indexOf(columnName);

      String headerText = (model.columnLabels?.isNotEmpty ?? false) ? model.columnLabels![colIndex] : columnName;

      ColumnDefinition? colDef = metaData?.columns.firstWhere((element) => element.name == columnName);

      if (colDef != null && colDef.nullable == true) {
        headerText += "*";
      }

      rowWidgets.add(
        SizedBox(
          width: tableSize.columnWidths[colIndex].toDouble(),
          child: Padding(
            padding: tableSize.cellPadding,
            child: Text(
              headerText,
              style: model.getTextStyle(pFontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    Widget header = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        border: const Border(
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      height: tableSize.tableHeaderHeight,
      child: Row(
        children: rowWidgets,
      ),
    );

    if (buildHeadersInList) {
      return header;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: headerHorizontalController,
      child: header,
    );
  }

  bool onInternalEndScroll(ScrollEndNotification notification) {
    if (notification.metrics.pixels > 0 && notification.metrics.atEdge) {
      if (notification.metrics.axis == Axis.horizontal) {
        /// Scrolled all the way to the left.
        // onRowSwipe?.call();
      } else {
        /// Scrolled to the bottom
        onEndScroll?.call();
      }
    }

    return true;
  }

  onInternalEndSwipe(DragEndDetails pDragEndDetails) {
    if (pDragEndDetails.primaryVelocity != null && pDragEndDetails.primaryVelocity! < 0.0) {
      // onRowSwipe?.call();
    }
  }
}
