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

import 'dart:collection';
import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

import '../../../flutter_jvx.dart';
import '../../model/component/fl_component_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_tree_widget.dart';

class FlTreeWrapper extends BaseCompWrapperWidget<FlTreeModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTreeWrapper({super.key, required super.model});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlTreeWrapperState();
}

class _FlTreeWrapperState extends BaseCompWrapperState<FlTreeModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The controller for the tree view.
  TreeViewController controller = TreeViewController(children: []);

  /// The meta datas.
  HashMap<String, DalMetaData> metaDatas = HashMap<String, DalMetaData>();

  /// The data pages of the databooks.
  HashMap<String, HashMap<String, dynamic>> data = HashMap<String, HashMap<String, dynamic>>();

  /// The selected records.
  /// The key is the data provider and the value is the selected record.
  HashMap<String, DataRecord> selectedRecords = HashMap<String, DataRecord>();

  /// The primary data chunk
  DataChunk? primaryDataChunk;

  /// If the tree has been initialized
  bool initialized = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _FlTreeWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final FlTreeWidget widget = FlTreeWidget(
      model: model,
      controller: controller,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Subscribes to the data service.
  void _subscribe() {
    bool first = true;
    for (String dataProvider in model.dataProviders) {
      DataSubscription dataSubscription = DataSubscription(
        subbedObj: this,
        dataProvider: dataProvider,
        from: first ? 0 : -1,
        onDataChunk: first ? (dataChunk) => _onDataChunk(dataProvider, dataChunk) : null,
        onPage: (pageKey, dataChunk) => _onPage(dataProvider, pageKey, dataChunk),
        onMetaData: (metaData) => _onMetaData(dataProvider, metaData),
        onSelectedRecord: (record) => _onSelectedRecord(dataProvider, record),
      );

      IUiService().registerDataSubscription(
        pDataSubscription: dataSubscription,
        pShouldFetch: false,
      );
      IUiService().sendCommand(
        GetMetaDataCommand(dataProvider: dataProvider, subId: dataSubscription.id, reason: "Get all meta datas"),
      );

      first = false;
    }
  }

  void _onPage(String pDataProvider, String pPageKey, DataChunk pPageChunk) {
    if (!_hasAllMetaData()) {
      return;
    }

    if (metaDatas[pDataProvider]!.isSelfJoined() && _createSelfJoinedFilter().toPageKey() == pPageKey) {
      primaryDataChunk = pPageChunk;
    } else {
      if (data[pDataProvider] == null) {
        data[pDataProvider] = HashMap<String, dynamic>();
      }
      data[pDataProvider]![pPageKey] = pPageChunk;
    }

    if (initialized) {
      _buildTree();
    } else {
      _initTree();
    }
  }

  void _onDataChunk(String pDataProvider, DataChunk pDataChunk) {
    if (!_hasAllMetaData()) {
      return;
    }

    if (!metaDatas[pDataProvider]!.isSelfJoined()) {
      primaryDataChunk = pDataChunk;
    }

    if (initialized) {
      _buildTree();
    } else {
      _initTree();
    }
  }

  _onMetaData(String dataProvider, DalMetaData metaData) {
    metaDatas[dataProvider] = metaData;

    if (initialized) {
      _buildTree();
    } else {
      _initTree();
    }
  }

  _onSelectedRecord(String dataProvider, DataRecord? record) {
    log('onSelectedRecord: $dataProvider');
    if (record != null) {
      selectedRecords[dataProvider] = record;
    } else {
      selectedRecords.remove(dataProvider);
    }
  }

  bool _hasAllMetaData() {
    for (String dataProvider in model.dataProviders) {
      if (metaDatas[dataProvider] == null) {
        return false;
      }
    }

    return true;
  }

  /// Returns the dataprovider of the tree level.
  /// If the dataprovider is self-joined, the dataprovider is returned.
  /// Otherwise an empty string is returned.
  String databookAtLevel(int pLevel) {
    if (pLevel < model.dataProviders.length) {
      return model.dataProviders[pLevel];
    } else {
      return metaDatas[model.dataProviders.last]?.isSelfJoined() == true ? model.dataProviders[pLevel - 1] : '';
    }
  }

  Filter _createSelfJoinedFilter() {
    String firstLvlDataBook = databookAtLevel(0);
    DalMetaData firstLvlMetaData = metaDatas[firstLvlDataBook]!;

    Filter filter = Filter(
      columnNames: firstLvlMetaData.masterReference!.referencedColumnNames,
      values: firstLvlMetaData.masterReference!.referencedColumnNames.map((e) => null).toList(),
    );

    return filter;
  }

  void _fetchSelfJoinedRoot() {
    Filter filter = _createSelfJoinedFilter();

    IUiService().sendCommand(
      FetchCommand(
        fromRow: 0,
        rowCount: -1,
        dataProvider: databookAtLevel(0),
        reason: "Fetching self joined root",
        filter: filter,
        pageKey: filter.toPageKey(),
      ),
    );
  }

  void _initTree() {
    if (!_hasAllMetaData()) {
      return;
    }

    if (metaDatas[databookAtLevel(0)]!.isSelfJoined()) {
      //if the first databook is self-joined fetch the root page else fetch build up the tree as usual
      _fetchSelfJoinedRoot();
      initialized = true;
    } else if (primaryDataChunk == null) {
      /// loops through the data providers and creates a node for the tree
      IUiService().sendCommand(
        FetchCommand(fromRow: 0, rowCount: -1, dataProvider: databookAtLevel(0), reason: "Fetch base databook"),
      );

      initialized = true;
    }
  }

  void _buildTree() {
    if (primaryDataChunk == null) {
      return;
    }

    DalMetaData metaData = metaDatas[databookAtLevel(0)]!;

    List<Node> primaryNodes = [];

    primaryDataChunk!.data.forEach((rowIndex, dataRow) {
      primaryNodes.add(Node(
        parent: true,
        key: _createFilter(metaData, dataRow, primaryDataChunk!.columnDefinitions).toPageKey(),
        label: _createLabel(metaData, dataRow, primaryDataChunk!.columnDefinitions),
      ));
    });
    controller = TreeViewController(children: primaryNodes);
    setState(() {});
  }

  Filter _createFilter(DalMetaData pMetaData, List<dynamic> pDataRow, List<ColumnDefinition> pColumnDefinitions) {
    return Filter(
      columnNames: pMetaData.primaryKeyColumns,
      values: pMetaData.primaryKeyColumns
          .map((columnName) => pDataRow[pColumnDefinitions.indexWhere((colDef) => colDef.name == columnName)])
          .toList(),
    );
  }

  String _createLabel(DalMetaData pMetaData, List<dynamic> pDataRow, List<ColumnDefinition> pColumnDefinitions) {
    return pMetaData.columnViewTable.isNotEmpty
        ? pDataRow[pColumnDefinitions.indexWhere((colDef) => colDef.name == pMetaData.columnViewTable[0])]
        : "No Column view";
  }
}
