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

import '../../model/command/api/fetch_command.dart';
import '../../model/command/api/select_tree_command.dart';
import '../../model/command/data/get_meta_data_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/request/filter.dart';
import '../../service/data/i_data_service.dart';
import '../../service/ui/i_ui_service.dart';
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
  TreeViewController controller = TreeViewController(children: <Node<List<NodeData>>>[]);

  /// The data pages of the databooks.
  HashMap<String, HashMap<String?, DataChunk>> data = HashMap<String, HashMap<String?, DataChunk>>();

  /// The meta datas.
  HashMap<String, DalMetaData> metaDatas = HashMap<String, DalMetaData>();

  /// The selected records.
  /// The key is the data provider and the value is the selected record.
  HashMap<String, DataRecord> selectedRecords = HashMap<String, DataRecord>();

  /// If the tree has been initialized
  bool initialized = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _FlTreeWrapperState() : super();

  @override
  Widget build(BuildContext context) {
    final FlTreeWidget widget = FlTreeWidget(
      model: model,
      controller: controller,
      onExpansionChanged: _handleExpansionChanged,
      onNodeTap: _handleNodeTap,
      onNodeDoubleTap: _handleNodeDoubleTap,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    _subscribe();
  }

  /// Returns the dataprovider of the tree level.
  /// If the dataprovider is self-joined, the dataprovider is returned.
  /// Otherwise an empty string is returned.
  String? dataProviderAtTreeDepth(int pLevel) {
    if (pLevel < model.dataProviders.length) {
      return model.dataProviders[pLevel];
    } else {
      return metaDatas[model.dataProviders.last]?.isSelfJoined() == true ? model.dataProviders.last : null;
    }
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
        from: 0,
        onDataChunk: first ? _onDataChunk : null,
        onPage: (pageKey, dataChunk) => _onPage(dataProvider, pageKey, dataChunk),
        onMetaData: (metaData) => _onMetaData(dataProvider, metaData),
        onSelectedRecord: (record) => _onSelectedRecord(dataProvider, record),
        onReload: first ? _onReload() : null,
      );
      first = false;

      IUiService().registerDataSubscription(pDataSubscription: dataSubscription, pShouldFetch: false);

      IUiService().sendCommand(
        GetMetaDataCommand(dataProvider: dataProvider, subId: dataSubscription.id, reason: "Get all meta datas"),
      );
    }
  }

  _onMetaData(String dataProvider, DalMetaData metaData) {
    metaDatas[dataProvider] = metaData;

    if (!initialized && _hasAllMetaData()) {
      _initTree();
    }
  }

  _onReload() {
    // if (initialized) {
    //   _initTree();
    // }
  }

  void _onPage(String pDataProvider, String? pPageKey, DataChunk pPageChunk) {
    log('onPage: $pDataProvider, $pPageKey');

    if (data[pDataProvider] == null) {
      data[pDataProvider] = HashMap<String?, DataChunk>();
    }

    data[pDataProvider]![pPageKey] = pPageChunk;

    if (initialized) {
      _addPage(pDataProvider, pPageKey, pPageChunk);
    }
  }

  _onSelectedRecord(String dataProvider, DataRecord? record) {
    log('onSelectedRecord: $dataProvider');
    if (record != null) {
      print(record.treePath);
      print(record.index);
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

  void _initTree() {
    IUiService().sendCommand(
      FetchCommand(
        fromRow: 0,
        rowCount: -1,
        dataProvider: dataProviderAtTreeDepth(0)!,
        filter: Filter(columnNames: [], values: []),
        reason: "Fetch base databook",
        setRootKey: true,
      ),
    );

    initialized = true;
  }

  _handleNodeDoubleTap(String pNodeKey) {
    log('double tap: $pNodeKey');
  }

  _handleNodeTap(String pNodeKey) {
    List<String> dataProviders = [];
    List<Filter> filters = [];

    Node<NodeData>? node = controller.getNode(pNodeKey);
    while (node != null) {
      dataProviders.insert(0, node.data!.dataProvider);
      filters.insert(0, node.data!.rowFilter);

      var parentNode = controller.getParent(node.key) as Node<NodeData>;
      if (node != parentNode) {
        node = parentNode;
      } else {
        node = null;
      }
    }

    while (dataProviders.length < model.dataProviders.length) {
      dataProviders.add(dataProviderAtTreeDepth(dataProviders.length - 1)!);
      filters.add(Filter(columnNames: [], values: []));
    }

    IUiService().sendCommand(
      SelectTreeCommand(
        componentName: model.name,
        dataProviders: dataProviders,
        filters: filters,
        reason: "Select tree",
      ),
    );
  }

  _handleExpansionChanged(String pNodeKey, bool pExpanded) {
    Node<NodeData> node = controller.getNode(pNodeKey)!;

    if (pExpanded) {
      if (node.children.isEmpty) {
        _fetchNodeChildren(node);
      } else {
        for (Node<NodeData> child in List<Node<NodeData>>.from(node.children)) {
          if (child.children.isEmpty && child.isParent) {
            _fetchNodeChildren(child);
          }
        }
      }
    }
  }

  void _fetchNodeChildren(Node<NodeData> node) {
    String dataProvider = dataProviderAtTreeDepth(node.data!.treePath.length - 1)!;
    DalMetaData metaData = metaDatas[dataProvider]!;
    String childDataProvider = dataProviderAtTreeDepth(node.data!.treePath.length)!;
    DalMetaData childMetaData = metaDatas[childDataProvider]!;

    List<dynamic> dataRow = data[dataProvider]![node.data!.pageKey]!.data[node.data!.rowIndex]!;

    Filter childFilter = _createChildFilter(childMetaData, metaData, dataRow, metaData.columnDefinitions);

    IUiService().sendCommand(
      FetchCommand(
        fromRow: 0,
        rowCount: -1,
        dataProvider: childDataProvider,
        reason: "Fetch child tree data",
        filter: childFilter,
      ),
    );
  }

  _onDataChunk(DataChunk dataChunk) {
    if (IDataService().getDataBook(dataProviderAtTreeDepth(0)!)!.rootKey == null) {
      _onPage(dataProviderAtTreeDepth(0)!, null, dataChunk);
    }
  }

  void _addPage(String pDataProvider, String? pPageKey, DataChunk pPageChunk) {
    String baseDataProvider = dataProviderAtTreeDepth(0)!;
    bool baseNodeData =
        baseDataProvider == pDataProvider && IDataService().getDataBook(baseDataProvider)!.rootKey == pPageKey;

    Node<NodeData>? parentNode;

    if (!baseNodeData) {
      DalMetaData metaData = metaDatas[pDataProvider]!;
      // First, add the root reference data provider to the page key and try to find the parent.
      // If the parent is not found, remove the root reference data provider from the page key and try again, but this time
      // with the master reference data provider.
      String parentNodeKey;
      if (metaData.rootReference != null) {
        parentNodeKey = "${metaData.rootReference!.referencedDataBook}_${pPageKey!}";
        parentNode = controller.getNode(parentNodeKey);
      }
      if (parentNode == null && metaData.masterReference != null) {
        parentNodeKey = "${metaData.masterReference!.referencedDataBook}_${pPageKey!}";
        parentNode = controller.getNode(parentNodeKey);
      }
    }

    if (!baseNodeData && parentNode == null) {
      return;
    }

    List<Node<NodeData>> newNodes = [];
    pPageChunk.data.forEach((rowIndex, dataRow) {
      Filter rowFilter = _createPrimaryKeysFilter(metaDatas[pDataProvider]!, dataRow, pPageChunk.columnDefinitions);

      bool isPotentialParent = baseNodeData && dataProviderAtTreeDepth(1) != null;
      // parent node data length is the index of our databook, add 1 to get the level of our children
      isPotentialParent |= parentNode != null && dataProviderAtTreeDepth(parentNode.data!.treePath.length + 1) != null;
      newNodes.add(
        Node<NodeData>(
          key: "${pDataProvider}_${rowFilter.toPageKey()}",
          data: NodeData(pPageKey, [...parentNode?.data!.treePath ?? [], rowIndex], rowIndex, rowFilter, pDataProvider),
          parent: isPotentialParent,
          label: _createLabel(metaDatas[pDataProvider]!, dataRow, pPageChunk.columnDefinitions),
        ),
      );
      if (model.detectEndNode && isPotentialParent && (parentNode == null || parentNode.expanded)) {
        DalMetaData metaData = metaDatas[pDataProvider]!;
        String childDataProvider = dataProviderAtTreeDepth(newNodes.last.data!.treePath.length)!;
        DalMetaData childMetaData = metaDatas[childDataProvider]!;

        Filter childFilter = _createChildFilter(childMetaData, metaData, dataRow, pPageChunk.columnDefinitions);

        IUiService().sendCommand(
          FetchCommand(
            fromRow: 0,
            rowCount: -1,
            dataProvider: childDataProvider,
            reason: "detecting first level end nodes",
            filter: childFilter,
          ),
        );
      }
    });

    for (Node newNode in newNodes) {
      Node? oldNode = controller.getNode(newNode.key);
      if (oldNode != null) {
        newNode = newNode.copyWith(children: oldNode.children, expanded: oldNode.expanded);
      }
    }

    if (baseNodeData) {
      controller = controller.copyWith(children: newNodes);
    } else {
      parentNode = parentNode!.copyWith(children: newNodes, parent: newNodes.isNotEmpty);
      controller = controller.withUpdateNode(parentNode.key, parentNode);
    }

    setState(() {});
  }

  Filter _createPrimaryKeysFilter(
      DalMetaData pMetaData, List<dynamic> pDataRow, List<ColumnDefinition> pColumnDefinitions) {
    return Filter(
      columnNames: pMetaData.primaryKeyColumns,
      values: pMetaData.primaryKeyColumns
          .map((columnName) => pDataRow[pColumnDefinitions.indexWhere((colDef) => colDef.name == columnName)])
          .toList(),
    );
  }

  String _createLabel(DalMetaData pMetaData, List<dynamic> pDataRow, List<ColumnDefinition> pColumnDefinitions) {
    return pMetaData.columnViewTable.isNotEmpty
        ? pDataRow[pColumnDefinitions.indexWhere((colDef) => colDef.name == pMetaData.columnViewTable[0])].toString()
        : "No column view";
  }

  Filter _createChildFilter(DalMetaData pChildMetaData, DalMetaData pParentMetaData, List<dynamic> pParentRow,
      List<ColumnDefinition> pColumnDefinitions) {
    bool isFirstSelfJoined = pChildMetaData.isSelfJoined() && pChildMetaData == pParentMetaData;
    ReferenceDefinition? referenceDefinition;
    if (isFirstSelfJoined) {
      referenceDefinition = pChildMetaData.rootReference;
    }
    referenceDefinition ??= pChildMetaData.masterReference;

    return Filter(
      columnNames: pParentMetaData.primaryKeyColumns
          .map((primaryKey) =>
              referenceDefinition!.columnNames[referenceDefinition.referencedColumnNames.indexOf(primaryKey)])
          .toList(),
      values: pParentMetaData.primaryKeyColumns
          .map((columnName) => pParentRow[pColumnDefinitions.indexWhere((colDef) => colDef.name == columnName)])
          .toList(),
    );
  }
}

class NodeData {
  final String? pageKey;
  final List<int> treePath;
  final int rowIndex;
  final Filter rowFilter;
  final String dataProvider;

  NodeData(this.pageKey, this.treePath, this.rowIndex, this.rowFilter, this.dataProvider);
}
