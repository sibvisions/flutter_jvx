import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';

import '../../../../mixin/ui_service_mixin.dart';
import '../../../../model/command/api/filter_command.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../model/data/subscriptions/data_subscription.dart';

class FlLinkedCellPicker extends StatefulWidget {
  final String name;

  final FlLinkedCellEditorModel model;

  const FlLinkedCellPicker({required this.name, required this.model, Key? key}) : super(key: key);

  @override
  _FlLinkedCellPickerState createState() => _FlLinkedCellPickerState();
}

class _FlLinkedCellPickerState extends State<FlLinkedCellPicker> with UiServiceMixin, ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextEditingController _controller = TextEditingController();

  FlLinkedCellEditorModel get model => widget.model;

  int scrollingPage = 1;
  Timer? filterTimer; // 200-300 Milliseconds
  dynamic lastChangedFilter;
  DataChunk? _chunkData;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = themeData;
    ColorScheme colorScheme = theme.colorScheme;

    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.width / 8,
        MediaQuery.of(context).size.height / 8,
        MediaQuery.of(context).size.width / 8,
        MediaQuery.of(context).size.height / 8,
      ),
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: themeData.primaryColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text(
                  configService.translateText("SELECT ITEM"),
                  style: TextStyle(
                    color: colorScheme.brightness == Brightness.light ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextFormField(
                  key: widget.key,
                  controller: _controller,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  onChanged: startTimerValueChanged,
                  style: TextStyle(fontSize: 14.0, color: themeData.colorScheme.onPrimary),
                  decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.green),
                      labelText: configService.translateText("Search"),
                      labelStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600)),
                )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: onNotification,
                  child: ListView.builder(
                    itemBuilder: itemBuilder,
                    itemCount: (_chunkData?.data.length ?? 1) + (hasHeader() ? 1 : 0),
                    scrollDirection: Axis.vertical,
                  ),
                ),
              ),
            ),
            ButtonBar(alignment: MainAxisAlignment.center, children: <Widget>[
              ElevatedButton(
                child: Text(
                  configService.translateText("CANCEL"),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    uiService.disposeSubscriptions(
      pSubscriber: this,
    );

    uiService.sendCommand(FilterCommand(
        editorId: widget.name,
        value: "",
        dataProvider: widget.model.linkReference.dataProvider,
        reason: "Closed the linked cell picker"));

    _controller.dispose();
    filterTimer?.cancel();

    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void receiveData(DataChunk pChunkData) {
    if (pChunkData.update && _chunkData != null) {
      for (int index in pChunkData.data.keys) {
        _chunkData!.data[index] = pChunkData.data[index]!;
      }
    } else {
      _chunkData = pChunkData;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onRowTapped(int index) {
    List<dynamic> data = _chunkData!.data[index]!;

    List<String> columnOrder = columnNamesToSubscribe();

    if (model.linkReference.columnNames.isEmpty) {
      Navigator.of(context).pop(data[columnOrder.indexOf(model.linkReference.referencedColumnNames[0])]);
    } else {
      HashMap<String, dynamic> dataMap = HashMap<String, dynamic>();

      for (int i = 0; i < model.linkReference.columnNames.length; i++) {
        String columnName = model.linkReference.columnNames[i];
        String referencedColumnName = model.linkReference.referencedColumnNames[i];

        dataMap[columnName] = data[columnOrder.indexOf(referencedColumnName)];
      }

      Navigator.of(context).pop(dataMap);
    }
  }

  void startTimerValueChanged(String value) {
    lastChangedFilter = value;

    if (filterTimer != null) {
      filterTimer!.cancel();
    }

    filterTimer = Timer(const Duration(milliseconds: 300), onTextFieldValueChanged);
  }

  void onTextFieldValueChanged() {
    List<String> columnOrder = columnNamesToSubscribe();

    List<String> filterColumns = [];

    if (model.linkReference.columnNames.isEmpty) {
      filterColumns.add(columnOrder.firstWhere(((element) => element == model.linkReference.referencedColumnNames[0])));
    } else {
      for (int i = 0; i < model.linkReference.columnNames.length; i++) {
        String referencedColumnName = model.linkReference.referencedColumnNames[i];
        String columnName = model.linkReference.columnNames[i];

        if (model.columnView == null || model.columnView!.columnNames.contains(referencedColumnName)) {
          filterColumns.add(columnName);
        }
      }
    }

    uiService.sendCommand(
      FilterCommand(
          editorId: widget.name,
          value: lastChangedFilter,
          columnNames: filterColumns,
          dataProvider: widget.model.linkReference.dataProvider,
          reason: "Filtered the linked cell picker"),
    );
  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    int dataIndex = index;
    if (hasHeader()) {
      if (index == 0) {
        return SizedBox(
          height: 50,
          child: Row(
            children: columnNamesToSubscribe()
                .map(
                  (e) => Expanded(
                    child: Column(
                      children: [
                        Text(
                          e,
                          style: TextStyle(fontSize: 14.0, color: themeData.colorScheme.onPrimary),
                        ),
                        const Divider(
                          color: Colors.grey,
                          indent: 10,
                          endIndent: 10,
                          thickness: 0.5,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );
      } else {
        //Decrease by one because of the header
        dataIndex--;
      }
    }
    if (_chunkData == null) {
      return SizedBox(
        height: 50,
        child: Center(
          child: Text(configService.translateText("Loading...")),
        ),
      );
    }

    List<dynamic> data = _chunkData!.data[dataIndex]!;

    List<Widget> rowWidgets = [];

    List<String> columnNamesOrder = columnNamesToSubscribe();

    for (String columnName in columnNamesToShow()) {
      int columnIndex = columnNamesOrder.indexOf(columnName);
      rowWidgets.add(
        Expanded(
          child: SizedBox(
            height: double.infinity,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                (data[columnIndex] ?? '').toString(),
                style: TextStyle(fontSize: 14.0, color: themeData.colorScheme.onPrimary),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onRowTapped(dataIndex),
      child: Container(
        decoration: dataIndex % 2 == 0
            ? BoxDecoration(color: themeData.primaryColor.withOpacity(0.05))
            : BoxDecoration(color: themeData.primaryColor.withOpacity(0.15)),
        height: 50,
        child: Row(
          children: rowWidgets,
        ),
      ),
    );
  }

  bool onNotification(ScrollEndNotification t) {
    if (t.metrics.pixels > 0 && t.metrics.atEdge) {
      scrollingPage++;
      subscribe();
    }
    return true;
  }

  void subscribe() {
    uiService.registerDataSubscription(
      pDataSubscription: DataSubscription(
        subbedObj: this,
        dataProvider: model.linkReference.dataProvider,
        onDataChunk: receiveData,
        dataColumns: columnNamesToSubscribe(),
        from: 0,
        to: 100 * scrollingPage,
      ),
    );
  }

  void unsubscribe() {
    uiService.disposeDataSubscription(pSubscriber: this, pDataProvider: model.linkReference.dataProvider);
  }

  List<String> columnNamesToShow() {
    if (model.displayReferencedColumnName != null) {
      return [model.displayReferencedColumnName!];
    } else if ((model.columnView?.columnCount ?? 0) >= 1) {
      return model.columnView!.columnNames;
    } else {
      return model.linkReference.referencedColumnNames;
    }
  }

  List<String> columnNamesToSubscribe() {
    Set<String> columnNames = <String>{};

    if (model.columnView != null) {
      columnNames.addAll(model.columnView!.columnNames);
    }

    if (model.displayReferencedColumnName != null) {
      columnNames.add(model.displayReferencedColumnName!);
    }

    columnNames.addAll(model.linkReference.referencedColumnNames);
    return columnNames.toList();
  }

  bool hasHeader() => columnNamesToShow().length > 1;
}
