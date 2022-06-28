import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/components/editor/cell_editor/i_cell_editor.dart';
import 'package:flutter_client/src/components/table/column_size_calculator.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/api/response/dal_meta_data_response.dart';
import 'package:flutter_client/src/model/component/table/fl_table_model.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_chunk.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FlTableWidget extends FlStatelessWidget<FlTableModel> with UiServiceMixin {
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

  /// The meta data of the table.
  final DalMetaDataResponse? metaData;

  final Function(dynamic value, int row, String column)? onEndEditing;

  final Function(dynamic value, int row, String column)? onValueChanged;

  FlTableWidget({
    Key? key,
    required FlTableModel model,
    required this.chunkData,
    required this.tableSize,
    this.selectedRow = -1,
    this.onRowTapDown,
    this.onRowTap,
    this.onRowSwipe,
    this.onLongPress,
    this.onEndScroll,
    this.itemScrollController,
    this.metaData,
    this.onEndEditing,
    this.onValueChanged,
  }) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(5.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(width: TableSize.borderWidth, color: Theme.of(context).primaryColor),
        color: Theme.of(context).backgroundColor,
      ),
      child: ClipRRect(
        // The clip rect is there to stop the rendering of the children.
        borderRadius: borderRadius, // Otherwise the children would clip the border of the parent container.
        child: GestureDetector(
          onLongPress: onLongPress,
          onPanDown: (DragDownDetails? pDragDetails) => onRowTapDown?.call(-1, pDragDetails),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: onInternalEndScroll,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: tableSize.size.width,
                ),
                child: ScrollablePositionedList.builder(
                  addAutomaticKeepAlives: true,
                  itemScrollController: itemScrollController,
                  itemBuilder: buildItem,
                  itemCount: chunkData.data.length + 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(BuildContext context, int pIndex) {
    List<dynamic> data = chunkData.data[pIndex]!;

    List<Widget> rowWidgets = [];

    for (String columnName in model.columnNames) {
      int columnIndex = chunkData.columnDefinitions.indexWhere((e) => e.name == columnName);

      ICellEditor cellEditor = ICellEditor.getCellEditor(
        pName: model.name,
        pCellEditorJson: chunkData.columnDefinitions[columnIndex].cellEditorJson,
        onChange: (value) => onValueChanged?.call(value, pIndex, columnName),
        onEndEditing: (value) => onEndEditing?.call(value, pIndex, columnName),
        pUiService: uiService,
      );

      var value = data[columnIndex];
      cellEditor.setValue(value);

      Widget? tableWidget = cellEditor.createTableWidget(context);

      tableWidget ??= Text(
        (value ?? '').toString(),
        style: model.getTextStyle(),
        overflow: TextOverflow.ellipsis,
      );

      rowWidgets.add(
        SizedBox(
          width: tableSize.columnWidths[model.columnNames.indexOf(columnName)].toDouble(),
          child: Padding(
            padding: EdgeInsets.only(
              left: TableSize.cellPadding,
              right: TableSize.cellPadding,
            ),
            child: tableWidget,
          ),
        ),
      );
    }

    double opacity = pIndex % 2 == 0 ? 0.00 : 0.15;

    if (pIndex == selectedRow) {
      opacity += 0.15;
    }

    return GestureDetector(
      onPanDown: (DragDownDetails? pDragDetails) => onRowTapDown?.call(pIndex, pDragDetails),
      onTap: () => onRowTap?.call(pIndex),
      //onHorizontalDragEnd: onInternalEndSwipe,
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
    );
  }

  Widget buildHeaderRow(BuildContext context) {
    List<Widget> rowWidgets = [];

    List<String> headerList = (model.columnLabels ?? model.columnNames);

    for (String columnName in headerList) {
      rowWidgets.add(
        SizedBox(
          width: tableSize.columnWidths[headerList.indexOf(columnName)].toDouble(),
          child: Padding(
            padding: EdgeInsets.only(
              left: TableSize.cellPadding,
              right: TableSize.cellPadding,
            ),
            child: Text(
              columnName,
              style: model.getTextStyle(pFontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Container(
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
  }

  Widget buildItem(BuildContext context, int index) {
    if (index == 0) {
      return buildHeaderRow(context);
    } else {
      return buildRow(context, index - 1);
    }
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
