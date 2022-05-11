import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/filter_command.dart';
import 'package:flutter_client/src/model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import 'package:flutter_client/src/model/data/chunk/chunk_data.dart';
import 'package:flutter_client/src/model/data/chunk/chunk_subscription.dart';

class FlLinkedCellPicker extends StatefulWidget {
  final String id;

  final String name;

  final FlLinkedCellEditorModel model;

  const FlLinkedCellPicker({required this.id, required this.name, required this.model, Key? key}) : super(key: key);

  @override
  _FlLinkedCellPickerState createState() => _FlLinkedCellPickerState();
}

class _FlLinkedCellPickerState extends State<FlLinkedCellPicker> with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextEditingController _controller = TextEditingController();

  FlLinkedCellEditorModel get model => widget.model;

  int scrollingPage = 1;
  Timer? filterTimer; // 200-300 Milliseconds
  dynamic lastChangedFilter;
  ChunkData? _chunkData;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    registerData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text(
                  "SELECT ITEM",
                  style: TextStyle(
                      color:
                          colorScheme.brightness == Brightness.light ? colorScheme.onPrimary : colorScheme.onSurface),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: TextFormField(
                  key: widget.key,
                  controller: _controller,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  onChanged: startTimerValueChanged,
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                  decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.green),
                      labelText: "Search",
                      labelStyle: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600)),
                )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
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
                child: const Text(
                  "CANCEL",
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
    uiService.unRegisterDataComponent(
      pComponentId: widget.id,
      pDataProvider: model.linkReference.dataProvider,
    );

    if (lastChangedFilter != null) {
      uiService.sendCommand(FilterCommand(
          editorId: widget.name,
          value: "",
          dataProvider: widget.model.linkReference.dataProvider,
          reason: "Filtered the linked cell picker"));
    }

    _controller.dispose();
    filterTimer?.cancel();

    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void receiveData(ChunkData pChunkData) {
    _chunkData = pChunkData;

    for (int i = 0; i < _chunkData!.data.length; i++) {
      List<dynamic> date = _chunkData!.data[i]!;
      log("Row: $i - $date");
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
    uiService.sendCommand(FilterCommand(
        editorId: widget.name,
        value: lastChangedFilter,
        dataProvider: widget.model.linkReference.dataProvider,
        reason: "Filtered the linked cell picker"));
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
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14.0, color: Colors.black),
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
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text("Loading..."),
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
          child: Text(
            (data[columnIndex] ?? '').toString(),
            style: const TextStyle(fontSize: 14.0, color: Colors.black),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onRowTapped(dataIndex),
      child: SizedBox(
        height: 50,
        child: Row(
          children: rowWidgets,
        ),
      ),
    );
  }

  Container getTableRow(List<Widget> children, int index, bool isHeader) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400]!, spreadRadius: 1)],
            color: Theme.of(context).primaryColor,
          ),
          child: ListTile(title: Row(children: children)));
    } else {
      // ignore: avoid_unnecessary_containers
      return Container(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _onRowTapped(index),
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Row(children: children),
              ),
            ),
            const Divider(
              color: Colors.grey,
              indent: 10,
              endIndent: 10,
              thickness: 0.5,
            )
          ],
        ),
      );
    }
  }

  Widget getTableColumn(String text, int rowIndex) {
    int flex = 1;

    return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Container(child: Text(text), padding: const EdgeInsets.all(0)),
        ));
  }

  bool onNotification(ScrollEndNotification t) {
    if (t.metrics.pixels > 0 && t.metrics.atEdge) {
      scrollingPage++;
      registerData();
    }
    return true;
  }

  void registerData() {
    uiService.registerDataChunk(
      chunkSubscription: ChunkSubscription(
        id: widget.id,
        dataProvider: model.linkReference.dataProvider,
        callback: receiveData,
        dataColumns: columnNamesToSubscribe(),
        from: 0,
        to: 100 * scrollingPage,
      ),
    );
  }

  List<String> columnNamesToShow() {
    if (model.displayReferencedColumnName != null) {
      return [model.displayReferencedColumnName!];
    } else if ((model.columnView?.columnCount ?? 0) > 1) {
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
