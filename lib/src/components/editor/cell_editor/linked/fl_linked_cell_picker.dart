import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../../../../../components.dart';
import '../../../../../flutter_jvx.dart';
import '../../../../../services.dart';
import '../../../../model/command/api/filter_command.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/data/column_definition.dart';
import '../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../model/data/subscriptions/data_subscription.dart';

class FlLinkedCellPicker extends StatefulWidget {
  final String name;

  final FlLinkedCellEditorModel model;

  const FlLinkedCellPicker({required this.name, required this.model, Key? key}) : super(key: key);

  @override
  State<FlLinkedCellPicker> createState() => _FlLinkedCellPickerState();
}

class _FlLinkedCellPickerState extends State<FlLinkedCellPicker> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final FlTableModel tableModel = FlTableModel();

  final TextEditingController _controller = TextEditingController();

  final FocusNode focusNode = FocusNode();

  FlLinkedCellEditorModel get model => widget.model;

  int scrollingPage = 1;
  Timer? filterTimer; // 200-300 Milliseconds
  String? lastChangedFilter;
  DataChunk? _chunkData;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    tableModel.columnLabels = [];
    tableModel.tableHeaderVisible = model.tableHeaderVisible;

    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    Size screenSize = MediaQuery.of(context).size;

    EdgeInsets paddingInsets;

    paddingInsets = EdgeInsets.fromLTRB(
      screenSize.width / 16,
      screenSize.height / 16,
      screenSize.width / 16,
      screenSize.height / 16,
    );

    FlTextFieldModel searchFieldModel = FlTextFieldModel();
    searchFieldModel.fontSize = 14;

    return Dialog(
      insetPadding: paddingInsets,
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Text(
                  FlutterJVx.translate("SELECT ITEM"),
                  style: TextStyle(
                    color: colorScheme.brightness == Brightness.light ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FlTextFieldWidget(
                key: widget.key,
                model: searchFieldModel,
                textController: _controller,
                keyboardType: TextInputType.text,
                valueChanged: startTimerValueChanged,
                endEditing: (_) {},
                focusNode: focusNode,
                inputDecoration: InputDecoration(
                  labelText: FlutterJVx.translate("Search"),
                  labelStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(
              child: _chunkData != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: LayoutBuilder(
                        builder: ((context, constraints) {
                          TableSize tableSize = TableSize.direct(
                            tableModel: tableModel,
                            dataChunk: _chunkData,
                            availableWidth: constraints.maxWidth,
                          );
                          tableModel.stickyHeaders =
                              constraints.maxHeight > (2 * tableSize.rowHeight + tableSize.tableHeaderHeight);

                          return FlTableWidget(
                            chunkData: _chunkData!,
                            onEndScroll: increasePageLoad,
                            model: tableModel,
                            disableEditors: true,
                            onRowTap: _onRowTapped,
                            tableSize: tableSize,
                          );
                        }),
                      ),
                    )
                  : Container(),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: Text(
                    FlutterJVx.translate("CANCEL"),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    IUiService().disposeSubscriptions(
      pSubscriber: this,
    );

    IUiService().sendCommand(FilterCommand(
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

    tableModel.columnNames.clear();
    tableModel.columnLabels.clear();
    for (ColumnDefinition colDef
        in _chunkData!.columnDefinitions.where((element) => columnNamesToShow().contains(element.name))) {
      tableModel.columnNames.add(colDef.name);
      tableModel.columnLabels.add(colDef.label);
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

    // Null the filter if the filter is empty.
    if (lastChangedFilter != null && lastChangedFilter!.isEmpty) {
      lastChangedFilter = null;
    }

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

    IUiService()
        .sendCommand(
      FilterCommand(
        editorId: widget.name,
        value: lastChangedFilter,
        columnNames: filterColumns,
        dataProvider: widget.model.linkReference.dataProvider,
        reason: "Filtered the linked cell picker",
      ),
    )
        .then(
      (value) {
        if (!focusNode.hasPrimaryFocus) {
          focusNode.requestFocus();
        }
      },
    );
  }

  void increasePageLoad() {
    scrollingPage++;
    subscribe();
  }

  void subscribe() {
    IUiService().registerDataSubscription(
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
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.linkReference.dataProvider);
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
