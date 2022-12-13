/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/command/api/filter_command.dart';
import '../../../../model/command/api/select_record_command.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../../model/component/table/fl_table_model.dart';
import '../../../../model/data/column_definition.dart';
import '../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../model/data/subscriptions/data_subscription.dart';
import '../../../../model/request/filter.dart';
import '../../../../model/response/dal_meta_data_response.dart';
import '../../../../service/command/i_command_service.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../table/fl_table_widget.dart';
import '../../../table/table_size.dart';
import '../../text_field/fl_text_field_widget.dart';

class FlLinkedCellPicker extends StatefulWidget {
  static const Object NULL_OBJECT = Object();

  final String name;

  final FlLinkedCellEditorModel model;

  final ColumnDefinition? editorColumnDefinition;

  const FlLinkedCellPicker({
    super.key,
    required this.name,
    required this.model,
    this.editorColumnDefinition,
  });

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
  DalMetaDataResponse? _metaData;

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
              onTap: _onNoValue,
              child: Builder(
                builder: (context) => Text(
                  style: TextStyle(
                    shadows: [
                      Shadow(
                        offset: const Offset(0, -2),
                        color: DefaultTextStyle.of(context).style.color!,
                      )
                    ],
                    color: Colors.transparent,
                    decoration: TextDecoration.underline,
                    decorationColor: DefaultTextStyle.of(context).style.color,
                    decorationThickness: 1,
                  ),
                  FlutterUI.translate("No value"),
                ),
              ),
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
              FlutterUI.translate("Cancel"),
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
          children: [
            Text(
              FlutterUI.translate("Select value"),
              style: Theme.of(context).dialogTheme.titleTextStyle,
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
                labelText: FlutterUI.translate("Search"),
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
                          showFloatingButton: false,
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

  void _receiveMetaData(DalMetaDataResponse pMetaData) {
    _metaData = pMetaData;

    if (mounted) {
      setState(() {});
    }
  }

  void _onNoValue() {
    Navigator.of(context).pop(FlLinkedCellPicker.NULL_OBJECT);
  }

  void _onRowTapped(int index) {
    List<dynamic> data = _chunkData!.data[index]!;

    List<String> columnOrder = _columnNamesToSubscribe();

    selectRecord(index).then((value) {
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
    }).catchError(IUiService().handleAsyncError);
  }

  /// Selects the record.
  Future<void> selectRecord(int pRowIndex) async {
    if (_metaData == null && _chunkData == null) {
      return;
    } else if (pRowIndex == -1) {
      return ICommandService().sendCommand(
        SelectRecordCommand(
          dataProvider: model.linkReference.dataProvider,
          selectedRecord: -1,
          reason: "Tapped",
          filter: null,
        ),
      );
    }

    List<String> listColumnNames = [];
    List<dynamic> listValues = [];

    if (_metaData!.primaryKeyColumns.isNotEmpty) {
      listColumnNames.addAll(_metaData!.primaryKeyColumns);
    } else {
      listColumnNames.addAll(model.linkReference.referencedColumnNames);
    }

    for (String column in listColumnNames) {
      listValues.add(_getValue(pColumnName: column, pRowIndex: pRowIndex));
    }

    var filter = Filter(values: listValues, columnNames: listColumnNames);

    return ICommandService().sendCommand(
      SelectRecordCommand(
        dataProvider: model.linkReference.dataProvider,
        selectedRecord: pRowIndex,
        reason: "Tapped",
        filter: filter,
      ),
    );
  }

  dynamic _getValue({required String pColumnName, required int pRowIndex}) {
    int colIndex = _chunkData!.columnDefinitions.indexWhere((element) => element.name == pColumnName);

    if (colIndex == -1) {
      return null;
    }

    return _chunkData!.data[pRowIndex]![colIndex];
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
        onMetaData: _receiveMetaData,
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
