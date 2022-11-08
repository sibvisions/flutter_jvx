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
  static const Object NULL_OBJECT = Object();

  final String name;

  final FlLinkedCellEditorModel model;

  final ColumnDefinition? editorColumnDefinition;

  const FlLinkedCellPicker({required this.name, required this.model, Key? key, this.editorColumnDefinition})
      : super(key: key);

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

    _subscribe();
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

    List<Widget> listBottomButtons = [];

    if (widget.editorColumnDefinition?.nullable == true) {
      listBottomButtons.add(
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              child: Text(
                style: TextStyle(
                  shadows: const [Shadow(offset: Offset(0, -2))],
                  color: Colors.transparent,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).colorScheme.onPrimary,
                  decorationThickness: 1,
                ),
                FlutterJVx.translate("No value"),
              ),
              onTap: () {
                Navigator.of(context).pop(FlLinkedCellPicker.NULL_OBJECT);
              },
            ),
          ),
        ),
      );
    }

    listBottomButtons.add(
      Flexible(
        flex: 1,
        child: Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            child: Text(
              FlutterJVx.translate("Cancel"),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );

    return Dialog(
      insetPadding: paddingInsets,
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              FlutterJVx.translate("Select value"),
              style: TextStyle(
                color: colorScheme.brightness == Brightness.light ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            FlTextFieldWidget(
              key: widget.key,
              model: searchFieldModel,
              textController: _controller,
              keyboardType: TextInputType.text,
              valueChanged: _startTimerValueChanged,
              endEditing: (_) {},
              focusNode: focusNode,
              inputDecoration: InputDecoration(
                labelText: FlutterJVx.translate("Search"),
                labelStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _chunkData != null
                  ? LayoutBuilder(
                      builder: ((context, constraints) {
                        TableSize tableSize = TableSize.direct(
                          tableModel: tableModel,
                          dataChunk: _chunkData!,
                          availableWidth: constraints.maxWidth,
                        );
                        tableModel.stickyHeaders =
                            constraints.maxHeight > (2 * tableSize.rowHeight + tableSize.tableHeaderHeight);

                        return FlTableWidget(
                          chunkData: _chunkData!,
                          onEndScroll: _increasePageLoad,
                          model: tableModel,
                          disableEditors: true,
                          onRowTap: _onRowTapped,
                          tableSize: tableSize,
                        );
                      }),
                    )
                  : Container(),
            ),
            const SizedBox(height: 8),
            Row(
              children: listBottomButtons,
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

    IUiService().sendCommand(
      FilterCommand(
        editorId: widget.name,
        value: "",
        dataProvider: widget.model.linkReference.dataProvider,
        reason: "Closed the linked cell picker",
      ),
    );

    _controller.dispose();
    filterTimer?.cancel();

    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _receiveData(DataChunk pChunkData) {
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
        in _chunkData!.columnDefinitions.where((element) => _columnNamesToShow().contains(element.name))) {
      tableModel.columnNames.add(colDef.name);
      tableModel.columnLabels.add(colDef.label);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onRowTapped(int index) {
    List<dynamic> data = _chunkData!.data[index]!;

    List<String> columnOrder = _columnNamesToSubscribe();

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

  void _startTimerValueChanged(String value) {
    lastChangedFilter = value;

    // Null the filter if the filter is empty.
    if (lastChangedFilter != null && lastChangedFilter!.isEmpty) {
      lastChangedFilter = null;
    }

    if (filterTimer != null) {
      filterTimer!.cancel();
    }

    filterTimer = Timer(const Duration(milliseconds: 300), _onTextFieldValueChanged);

    setState(() {});
  }

  void _onTextFieldValueChanged() {
    List<String> columnOrder = _columnNamesToSubscribe();

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

    ICommandService()
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
    ).catchError(IUiService().handleAsyncError);
  }

  void _increasePageLoad() {
    scrollingPage++;
    _subscribe();
  }

  void _subscribe() {
    IUiService().registerDataSubscription(
      pDataSubscription: DataSubscription(
        subbedObj: this,
        dataProvider: model.linkReference.dataProvider,
        onDataChunk: _receiveData,
        dataColumns: _columnNamesToSubscribe(),
        from: 0,
        to: 100 * scrollingPage,
      ),
    );
  }

  List<String> _columnNamesToShow() {
    if (model.displayReferencedColumnName != null) {
      return [model.displayReferencedColumnName!];
    } else if ((model.columnView?.columnCount ?? 0) >= 1) {
      return model.columnView!.columnNames;
    } else {
      return model.linkReference.referencedColumnNames;
    }
  }

  List<String> _columnNamesToSubscribe() {
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
}
