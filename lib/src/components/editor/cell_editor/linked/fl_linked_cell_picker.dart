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
import '../../../../model/command/api/fetch_command.dart';
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
import '../../../../service/data/i_data_service.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/column_list.dart';
import '../../../table/fl_table_widget.dart';
import '../../../table/table_size.dart';
import '../../text_field/fl_text_field_widget.dart';
import '../i_cell_editor.dart';
import 'fl_linked_cell_editor.dart';

class FlLinkedCellPicker extends StatefulWidget {
  static const int PAGE_LOAD = 50;

  static const int MIN_ROWS_FOR_SEARCH = 6;

  static const Object NULL_OBJECT = Object();

  final String name;

  final FlLinkedCellEditorModel model;

  final ColumnDefinition? editorColumnDefinition;

  final FlLinkedCellEditor linkedCellEditor;

  final bool? embeddable;

  final bool showTitle;

  final bool showSearch;

  const FlLinkedCellPicker({
    super.key,
    required this.linkedCellEditor,
    required this.name,
    required this.model,
    this.editorColumnDefinition,
    this.embeddable,
    this.showTitle = true,
    this.showSearch = true
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

  int scrollingPage = 1;

  Timer? filterTimer; // 200-300 Milliseconds

  String? lastChangedFilter;

  DataChunk? _chunkData;

  DataChunk? _chunkDataConcatMask;

  DalMetaData? _metaData;

  bool _currentlyFiltering = false;

  TableSize? tableSize;

  /// The currently selected row. -1 is none selected.
  int selectedRow = -1;

  /// The last selected row. Used to calculate the current scroll position
  /// if the table has not yet been scrolled.
  int lastScrolledToIndex = -1;

  /// If the last scrolled item got scrolled to the top edge or bottom edge.
  bool? scrolledIndexTopAligned;

  /// The known scroll notification.
  ScrollNotification? lastScrollNotification;

  /// The last known table constraints.
  BoxConstraints? lastTableConstraints;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Getters
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlLinkedCellEditor get linkedCellEditor => widget.linkedCellEditor;

  FlLinkedCellEditorModel get model => widget.model;

  bool get isConcatMask => model.displayConcatMask != null;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    tableModel.columnLabels = [];
    tableModel.tableHeaderVisible = model.tableHeaderVisible && !isConcatMask;

    if (model.disabledAlternatingRowColor) {
      tableModel.styles.add(FlTableModel.STYLE_NO_ALTERNATING_ROW_COLOR);
    }

    tableModel.dataProvider = linkedCellEditor.dataProvider;

    _subscribe();
  }

  @override
  void didUpdateWidget(covariant FlLinkedCellPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (linkedCellEditor != oldWidget.linkedCellEditor) {
      tableModel.dataProvider = linkedCellEditor.dataProvider;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listBottomButtons = [];

    if (widget.editorColumnDefinition?.nullable == true && !model.hideClearIcon) {
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
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: TextButton(
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

    ThemeData theme = Theme.of(context);

    bool showSearch = widget.showSearch;

    if (showSearch && _chunkData != null && _chunkData!.isAllFetched && _chunkData!.data.length <= FlLinkedCellPicker.MIN_ROWS_FOR_SEARCH) {
      showSearch = false;
    }

    return _wrapAsDialog(Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showTitle)
              Text(
                FlutterUI.translate("Select value"),
                style: theme.dialogTheme.titleTextStyle ??
                    (theme.useMaterial3 ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall),
              ),
            if (widget.showTitle)
              const SizedBox(height: 20),
            if (showSearch)
              FlTextFieldWidget(
                key: widget.key,
                model: FlTextFieldModel()..placeholder = FlutterUI.translate("Search"),
                textController: _controller,
                keyboardType: TextInputType.text,
                valueChanged: _startTimerValueChanged,
                endEditing: _startTimerValueChanged,
                focusNode: focusNode,
              ),
            if (showSearch)
              const SizedBox(height: 10),
            Expanded(
              child: _chunkData != null && _metaData != null
                  ? LayoutBuilder(
                      builder: ((context, constraints) {
                        lastTableConstraints = constraints;

                        tableSize = TableSize.direct(
                          metaData: _metaData!,
                          tableModel: tableModel,
                          dataChunk: isConcatMask ? _chunkDataConcatMask! : _chunkData!,
                          availableWidth: constraints.maxWidth,
                        );
                        tableModel.stickyHeaders =
                            constraints.maxHeight > (2 * tableSize!.rowHeight + tableSize!.tableHeaderHeight);
                        tableModel.editable = false;

                        return FlTableWidget(
                          selectedRowIndex: selectedRow,
                          metaData: _metaData,
                          chunkData: isConcatMask ? _chunkDataConcatMask! : _chunkData!,
                          onLoadMore: _loadMore,
                          model: tableModel,
                          onTap: _onRowTapped,
                          onRefresh: _refresh,
                          tableSize: tableSize!
                        );
                      }),
                    )
                  : Container(),
            ),
            const SizedBox(height: 12),
            Row(
              children: listBottomButtons,
            ),
          ],
        ),
      ),
    );
  }

  Widget _wrapAsDialog(Widget child) {
    if (widget.embeddable == true) {
      return child;
    }
    else {
      Size screenSize = MediaQuery.sizeOf(context);

      EdgeInsets paddingInsets;

      paddingInsets = EdgeInsets.fromLTRB(
        screenSize.width / 16,
        screenSize.height / 16,
        screenSize.width / 16,
        screenSize.height / 16,
      );

      return Dialog(
          insetPadding: paddingInsets,
          elevation: 10.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: child
      );
    }
  }

  @override
  void dispose() {
    IUiService().disposeSubscriptions(this);

    ICommandService().sendCommand(
      FilterCommand.none(
        dataProvider: widget.model.linkReference.referencedDataBook,
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

  Future<void> _receiveTableData(DataChunk pChunkData) async {
    _chunkData = pChunkData;

    _createTableColumnView();

    // This is the column index of the column of the linked cell editor in this data chunk.
    // This data chunk is the referenced data book! Not the data book of the linked cell editor!
    int colIndex = linkedCellEditor.effectiveLinkReference.columnNames.indexOf(linkedCellEditor.columnName);
    colIndex = colIndex == -1 ? 0 : colIndex;

    if (isConcatMask && _chunkData != null) {
      Map<int, List<dynamic>> concatMaskData = {};

      for (int i = 0; i < _chunkData!.data.length; i++) {
        dynamic oldValue = _chunkData!.data[i]![colIndex];
        concatMaskData[i] = [linkedCellEditor.formatValue(oldValue)];
      }

      _chunkDataConcatMask = DataChunk(
        columnDefinitions: ColumnList.fromElement(ColumnDefinition.fromJson({"name": "concat", "label": "concat"})),
        data: concatMaskData,
        from: _chunkData!.from,
        isAllFetched: _chunkData!.isAllFetched,
      );
    } else {
      _chunkDataConcatMask = null;
    }

    if (_chunkData != null && _chunkData!.data.isNotEmpty) {
      // loop through the chunk data and find the index of the record for which the value equals the linked cell editor get value
      for (int i = 0; i < _chunkData!.data.length; i++) {
        if (_chunkData!.data[i]![colIndex] == await linkedCellEditor.getValue()) {
          selectedRow = i;
          break;
        }
      }
    } else {
      selectedRow = -1;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _createTableColumnView() {
    tableModel.columnNames.clear();
    tableModel.columnLabels.clear();

    if (_metaData != null) {
      if (isConcatMask) {
        tableModel.columnNames.add("concat");
        tableModel.columnLabels.add("concat");
      } else {
        for (ColumnDefinition colDef
        in _metaData!.columnDefinitions.where((element) => _columnNamesToShow().contains(element.name))) {
          tableModel.columnNames.add(colDef.name);
          tableModel.columnLabels.add(colDef.label);
        }
      }
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

    selectRecord(pIndex).then((success) {
      if (!success) {
        return;
      }

      List<dynamic>? data = _chunkData!.data[pIndex];
      if (data == null) {
        return;
      }

      Map<String, dynamic> dataMap = HashMap<String, dynamic>();

      if (model.additionalClearColumnNames?.isNotEmpty == true) {
        for (String columnName in model.additionalClearColumnNames!) {
          dataMap[columnName] = null;
        }
      }

      if (model.linkReference.columnNames.isEmpty) {
        dataMap[linkedCellEditor.columnName] = data[_chunkData!.columnDefinitions
            .indexWhere((element) => element.name == model.linkReference.referencedColumnNames[0])];
      } else {
        for (int i = 0; i < model.linkReference.columnNames.length; i++) {
          String columnName = model.linkReference.columnNames[i];
          String referencedColumnName = model.linkReference.referencedColumnNames[i];

          dataMap[columnName] =
              data[_chunkData!.columnDefinitions.indexWhere((element) => element.name == referencedColumnName)];
        }
      }

      if (!mounted) return;

      Navigator.of(context).pop(dataMap);
    });
  }

  /// Selects the record.
  Future<bool> selectRecord(int pRowIndex) async {
    if (_metaData == null && _chunkData == null) {
      return false;
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
        dataProvider: model.linkReference.referencedDataBook,
        rowNumber: pRowIndex,
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

    // Text field wont update immediately, so we need to force it to update.
    setState(() {});
  }

  void _onTextFieldValueChanged() {
    ICommandService()
        .sendCommand(
          FilterCommand.byValue(
            editorComponentId: widget.name,
            value: lastChangedFilter,
            columnNames: [linkedCellEditor.columnName],
            dataProvider: widget.model.linkReference.referencedDataBook,
            reason: "Filtered the linked cell picker",
          ),
        )
        .then(
          (success) => _currentlyFiltering = false,
        );
  }

  void _loadMore() {
    if (_chunkData != null && !_chunkData!.isAllFetched) {
      scrollingPage++;
      _subscribe();
    }
  }

  void _subscribe() {
    IUiService().registerDataSubscription(
      pDataSubscription: DataSubscription(
        subbedObj: this,
        dataProvider: model.linkReference.referencedDataBook,
        onDataChunk: _receiveTableData,
        onMetaData: _receiveMetaData,
        onReload: _onDataProviderReload,
        from: 0,
        to: FlLinkedCellPicker.PAGE_LOAD * scrollingPage,
      ),
    );
  }

  /// Refreshes this data provider
  Future<void> _refresh() {
    IUiService().notifySubscriptionsOfReload(model.linkReference.referencedDataBook);

    return ICommandService().sendCommand(
      FetchCommand(
        fromRow: 0,
        reload: true,
        rowCount: IUiService().getSubscriptionRowCount(model.linkReference.referencedDataBook),
        dataProvider: model.linkReference.referencedDataBook,
        reason: "Table refreshed",
      ),
    );
  }

  int _onDataProviderReload() {
    int selectedRow = IDataService().getDataBook(model.linkReference.referencedDataBook)?.selectedRow ?? -1;
    if (selectedRow >= 0) {
      scrollingPage = ((selectedRow + 1) / FlLinkedCellPicker.PAGE_LOAD).ceil();
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
