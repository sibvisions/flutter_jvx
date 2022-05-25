import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/model/component/table/fl_table_model.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_chunk.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FlTableWidget extends FlStatelessWidget<FlTableModel> {
  final double tableWidth;

  final List<double> columnSizes;

  final Function(int)? onRowTapDown;

  final Function(int)? onRowTap;

  final Function(int)? onRowSwipe;

  final VoidCallback? onLongPress;

  final VoidCallback? onEndScroll;

  final DataChunk chunkData;

  FlTableWidget({
    Key? key,
    required FlTableModel model,
    required this.chunkData,
    required this.columnSizes,
    required this.tableWidth,
    this.onRowTapDown,
    this.onRowTap,
    this.onRowSwipe,
    this.onLongPress,
    this.onEndScroll,
  }) : super(key: key, model: model) {
    //log("length of chunk data: ${chunkData.data.length}");
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: onInternalEndScroll,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: tableWidth.toDouble(),
          ),
          child: ScrollablePositionedList.builder(
            itemBuilder: buildItem,
            itemCount: chunkData.data.length + 1,
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

      rowWidgets.add(
        SizedBox(
          width: columnSizes[model.columnNames.indexOf(columnName)].toDouble(),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              (data[columnIndex] ?? '').toString(),
              style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onPanDown: (_) => onRowTapDown?.call(pIndex),
      onTap: () => onRowTap?.call(pIndex),
      child: Container(
        height: 50,
        decoration: pIndex % 2 == 0
            ? BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.05))
            : BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.15)),
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
          width: columnSizes[headerList.indexOf(columnName)].toDouble(),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              columnName,
              style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.05)),
      height: 50,
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
      onEndScroll?.call();
    }
    return true;
  }
}
