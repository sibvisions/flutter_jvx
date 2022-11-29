import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../model/component/table/fl_table_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/layout/alignments.dart';
import '../../model/response/dal_meta_data_response.dart';
import '../../util/jvx_colors.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../editor/cell_editor/date/fl_date_cell_editor.dart';
import '../editor/cell_editor/fl_check_box_cell_editor.dart';
import '../editor/cell_editor/fl_choice_cell_editor.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import '../editor/cell_editor/linked/fl_linked_cell_editor.dart';
import 'table_size.dart';

class FlTableWidget extends FlStatelessWidget<FlTableModel> {
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

  /// If a button is shown at the bottom.
  final bool showFloatingButton;

  /// The action the floating button calls.
  final VoidCallback? floatingOnPress;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTableWidget({
    super.key,
    required super.model,
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
    this.showFloatingButton = false,
    this.floatingOnPress,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(5.0);

    List<Widget> children = [createTable(context)];

    if (showFloatingButton && floatingOnPress != null) {
      children.add(
        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton(
            onPressed: floatingOnPress,
            child: FaIcon(
              FontAwesomeIcons.squarePlus,
              color: model.foreground,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(width: tableSize.borderWidth, color: Theme.of(context).primaryColor),
        color: Theme.of(context).backgroundColor,
      ),
      child: ClipRRect(
        // The clip rect is there to stop the rendering of the children.
        borderRadius: borderRadius, // Otherwise the children would clip the border of the parent container.
        child: Stack(
          children: children,
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget createTable(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        double maxWidth = max(max(tableSize.size.width, constraints.maxWidth), 0);

        bool canScrollHorizontally = tableSize.size.width > constraints.maxWidth;

        Widget table = GestureDetector(
          onLongPress: model.isEnabled ? onLongPress : null,
          onPanDown: model.isEnabled ? ((DragDownDetails? pDragDetails) => onRowTapDown?.call(-1, pDragDetails)) : null,
          child: NotificationListener<ScrollEndNotification>(
            onNotification: onInternalEndScroll,
            child: SingleChildScrollView(
              physics: canScrollHorizontally ? null : const NeverScrollableScrollPhysics(),
              controller: tableHorizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: ScrollablePositionedList.builder(
                  scrollDirection: Axis.vertical,
                  itemScrollController: itemScrollController,
                  itemBuilder: itemBuilder,
                  itemCount: _itemCount,
                ),
              ),
            ),
          ),
        );

        if (!model.stickyHeaders || !model.tableHeaderVisible) {
          return table;
        }

        List<Widget> children = [];

        if (model.tableHeaderVisible) {
          children.add(
            SizedBox(
              height: tableSize.tableHeaderHeight,
              child: buildHeaderRow(context, canScrollHorizontally),
            ),
          );
        }

        children.add(
          SizedBox(
            height: max(constraints.maxHeight - tableSize.tableHeaderHeight, 0),
            child: table,
          ),
        );

        return Column(
          children: children,
        );
      }),
    );
  }

  /// The item builder of the scrollable positioned list.
  Widget itemBuilder(BuildContext context, int pIndex) {
    int index = pIndex;
    if (model.tableHeaderVisible && !model.stickyHeaders) {
      index--;
      if (pIndex == 0) {
        // Header gets a false scrollable as it is already handled by the item scroller.
        return buildHeaderRow(context, false);
      }
    }

    return buildDataRow(index, context);
  }

  /// How many items the scrollable list should build.
  int get _itemCount {
    int itemCount = chunkData.data.length;

    if (model.tableHeaderVisible && !model.stickyHeaders) {
      itemCount += 1;
    }

    return itemCount;
  }

  /// Builds a data row.
  Widget buildDataRow(int pIndex, BuildContext context) {
    List<dynamic> data = chunkData.data[pIndex]!;

    List<Widget> rowWidgets = [];

    List<ColumnDefinition> columnsToShow = tableSize.columnWidths.keys
        .map((e) => chunkData.columnDefinitions.firstWhere((element) => element.name == e))
        .toList();

    for (ColumnDefinition colDef in columnsToShow) {
      int dataIndex = chunkData.columnDefinitions.indexOf(colDef);

      Widget? widget;
      var rawValue = data[dataIndex];

      ICellEditor cellEditor = ICellEditor.getCellEditor(
        pName: model.name,
        columnDefinition: colDef,
        pCellEditorJson: colDef.cellEditorJson,
        onChange: (value) => onValueChanged?.call(value, pIndex, colDef.name),
        onEndEditing: (value) => onEndEditing?.call(value, pIndex, colDef.name),
        onFocusChanged: (_) {},
      );

      var formattedValue = cellEditor.formatValue(rawValue);

      if (!disableEditors) {
        cellEditor.setValue(rawValue);

        if (cellEditor.canBeInTable) {
          FlStatelessWidget tableWidget = cellEditor.createWidget(null, true);

          tableWidget.model.applyFromJson(model.json);
          // Some parts of a json have to take priority.
          // As they override the properties.
          tableWidget.model.applyCellEditorOverrides(model.json);

          widget = tableWidget;

          if (((cellEditor is FlDateCellEditor || cellEditor is FlLinkedCellEditor) &&
                  cellEditor.model.preferredEditorMode == ICellEditorModel.DOUBLE_CLICK) ||
              ((cellEditor is FlCheckBoxCellEditor || cellEditor is FlChoiceCellEditor) &&
                  !cellEditor.model.directCellEditor)) {
            widget = IgnorePointer(child: widget);
          }
        }
      }

      widget ??= Text(
        (formattedValue).toString(),
        style: model.createTextStyle(),
        overflow: TextOverflow.ellipsis,
      );

      rowWidgets.add(
        IgnorePointer(
          ignoring: colDef.readonly || (metaData?.readOnly ?? false),
          child: Container(
            width: tableSize.columnWidths[colDef.name]!.toDouble(),
            alignment: FLUTTER_ALIGNMENT[colDef.cellEditorHorizontalAlignment.index][VerticalAlignment.CENTER.index],
            padding: tableSize.cellPadding,
            child: widget,
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
                width: 0.3,
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

  Widget buildHeaderRow(BuildContext context, bool pCanScroll) {
    List<Widget> rowWidgets = [];

    for (int colIndex = 0; colIndex < model.columnNames.length; colIndex++) {
      String columnName = model.columnNames[colIndex];

      if (!tableSize.columnWidths.keys.contains(columnName)) {
        // No size calculated for this column
        continue;
      }

      String headerText = model.columnLabels[colIndex];

      ColumnDefinition colDef = chunkData.columnDefinitions.firstWhere((element) => element.name == columnName);

      if (colDef.nullable != true) {
        headerText += " *";
      }

      rowWidgets.add(
        SizedBox(
          width: tableSize.columnWidths[columnName]!.toDouble(),
          child: Container(
            padding: tableSize.cellPadding,
            alignment: FLUTTER_ALIGNMENT[colDef.cellEditorHorizontalAlignment.index][VerticalAlignment.CENTER.index],
            child: Text(
              headerText,
              style: model.createTextStyle(pFontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    Widget header = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        border: const Border(
          bottom: BorderSide(color: JVxColors.COMPONENT_BORDER),
        ),
      ),
      height: tableSize.tableHeaderHeight,
      child: Row(
        children: rowWidgets,
      ),
    );

    if (!model.stickyHeaders && model.tableHeaderVisible) {
      return header;
    }

    return SingleChildScrollView(
      physics: pCanScroll ? null : const NeverScrollableScrollPhysics(),
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
