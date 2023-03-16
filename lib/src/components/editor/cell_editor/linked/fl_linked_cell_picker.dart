/* 
 * Copyright 2022 SIB Visions GmbH
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
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/data/column_definition.dart';
import '../../../../model/data/data_book.dart';
import '../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../model/data/subscriptions/data_subscription.dart';
import '../../../../model/request/filter.dart';
import '../../../../service/command/i_command_service.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../table/fl_table_widget.dart';
import '../../../table/table_size.dart';
import '../../text_field/fl_text_field_widget.dart';
import '../i_cell_editor.dart';

class FlLinkedCellPicker extends StatefulWidget {
  static const PAGE_LOAD = 50;
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
  DalMetaData? _metaData;
  bool _currentlyFiltering = false;

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

    List<Widget> listBottomButtons = [];

    if (widget.editorColumnDefinition?.nullable == true) {
      listBottomButtons.add(
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _onNoValue,
              child: Text(
                FlutterUI.translate("No value"),
              ),
            ),
          ),
        ),
      );
    }

    listBottomButtons.add(
      TextButton(
        child: Text(
          FlutterUI.translate("Cancel"),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
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
            const SizedBox(height: 12),
            FlTextFieldWidget(
              key: widget.key,
              model: FlTextFieldModel(),
              textController: _controller,
              keyboardType: TextInputType.text,
              valueChanged: _startTimerValueChanged,
              endEditing: _startTimerValueChanged,
              focusNode: focusNode,
              inputDecoration: InputDecoration(
                labelText: FlutterUI.translate("Search"),
                labelStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _chunkData != null && _metaData != null
                  ? LayoutBuilder(
                      builder: ((context, constraints) {
                        TableSize tableSize = TableSize.direct(
                          metaData: _metaData!,
                          tableModel: tableModel,
                          dataChunk: _chunkData!,
                          availableWidth: constraints.maxWidth,
                        );
                        tableModel.stickyHeaders =
                            constraints.maxHeight > (2 * tableSize.rowHeight + tableSize.tableHeaderHeight);
                        tableModel.editable = false;

                        return FlTableWidget(
                          metaData: _metaData,
                          chunkData: _chunkData!,
                          onEndScroll: _increasePageLoad,
                          model: tableModel,
                          onTap: _onRowTapped,
                          tableSize: tableSize,
                          showFloatingButton: false,
                        );
                      }),
                    )
                  : Container(),
            ),
            const SizedBox(height: 4),
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
        dataProvider: widget.model.linkReference.referencedDataprovider,
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
    _chunkData = pChunkData;

    _createTableColumnView();

    if (mounted) {
      setState(() {});
    }
  }

  void _createTableColumnView() {
    tableModel.columnNames.clear();
    tableModel.columnLabels.clear();
    for (ColumnDefinition colDef
        in _chunkData!.columnDefinitions.where((element) => _columnNamesToShow().contains(element.name))) {
      tableModel.columnNames.add(colDef.name);
      tableModel.columnLabels.add(colDef.label);
    }
  }

  void _receiveMetaData(DalMetaData pMetaData) {
    _metaData = pMetaData;

    _createTableColumnView();

    if (mounted) {
      setState(() {});
    }
  }

  void _onNoValue() {
    Navigator.of(context).pop(FlLinkedCellPicker.NULL_OBJECT);
  }

  void _onRowTapped(int pIndex, String pColumnName, ICellEditor pCellEditor) {
    if (_currentlyFiltering || pIndex < 0) {
      return;
    }

    selectRecord(pIndex).then((_) {
      List<dynamic>? data = _chunkData!.data[pIndex];
      if (data == null) {
        return;
      }
      if (model.linkReference.columnNames.isEmpty) {
        Navigator.of(context).pop(data[_chunkData!.columnDefinitions
            .indexWhere((element) => element.name == model.linkReference.referencedColumnNames[0])]);
      } else {
        HashMap<String, dynamic> dataMap = HashMap<String, dynamic>();

        for (int i = 0; i < model.linkReference.columnNames.length; i++) {
          String columnName = model.linkReference.columnNames[i];
          String referencedColumnName = model.linkReference.referencedColumnNames[i];

          dataMap[columnName] =
              data[_chunkData!.columnDefinitions.indexWhere((element) => element.name == referencedColumnName)];
        }

        Navigator.of(context).pop(dataMap);
      }
    }).catchError(IUiService().handleAsyncError);
  }

  /// Selects the record.
  Future<void> selectRecord(int pRowIndex) async {
    if (_metaData == null && _chunkData == null) {
      return;
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
        dataProvider: model.linkReference.referencedDataprovider,
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
    _currentlyFiltering = true;

    // Null the filter if the filter is empty.
    if (lastChangedFilter != null && lastChangedFilter!.isEmpty) {
      lastChangedFilter = null;
    }

    if (filterTimer != null) {
      filterTimer!.cancel();
    }
    filterTimer = Timer(const Duration(milliseconds: 300), _onTextFieldValueChanged);

    // Textfield wont update immediately, so we need to force it to update.
    setState(() {});
  }

  void _onTextFieldValueChanged() {
    List<String> filterColumns = [];

    if (model.linkReference.columnNames.isEmpty) {
      filterColumns.add(model.linkReference.referencedColumnNames[0]);
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
            dataProvider: widget.model.linkReference.referencedDataprovider,
            reason: "Filtered the linked cell picker",
          ),
        )
        .then(
          (_) => _currentlyFiltering = false,
        );
  }

  void _increasePageLoad() {
    scrollingPage++;
    _subscribe();
  }

  void _subscribe() {
    IUiService().registerDataSubscription(
      pDataSubscription: DataSubscription(
        subbedObj: this,
        dataProvider: model.linkReference.referencedDataprovider,
        onDataChunk: _receiveData,
        onMetaData: _receiveMetaData,
        onReload: _onDataProviderReload,
        from: 0,
        to: FlLinkedCellPicker.PAGE_LOAD * scrollingPage,
      ),
    );
  }

  int _onDataProviderReload(int pSelectedRow) {
    if (pSelectedRow >= 0) {
      scrollingPage = ((pSelectedRow + 1) / FlLinkedCellPicker.PAGE_LOAD).ceil();
    } else {
      scrollingPage = 1;
    }
    return FlLinkedCellPicker.PAGE_LOAD * scrollingPage;
  }

  List<String> _columnNamesToShow() {
    if (model.displayReferencedColumnName != null) {
      return [model.displayReferencedColumnName!];
    } else if ((model.columnView?.columnCount ?? 0) >= 1) {
      return model.columnView!.columnNames;
    } else if (_metaData?.columnViewTable.isNotEmpty == true) {
      return _metaData!.columnViewTable;
    } else {
      return model.linkReference.referencedColumnNames;
    }
  }
}
