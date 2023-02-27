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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
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

  /// The data pages of the databooks. First key is the dataprovider, second key is the page.
  HashMap<String, HashMap<String?, DataChunk>> data = HashMap<String, HashMap<String?, DataChunk>>();

  /// First key is the dataprovider, second key is the page. The value is a list of nodes which are receiving the page.
  HashMap<String, HashMap<String?, List<String>>> nodesReceivingPage =
      HashMap<String, HashMap<String?, List<String>>>();

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
      onRefresh: _refresh,
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

  void _onPage(String pDataProvider, String? pPageKey, DataChunk pPageChunk) {
    if (data[pDataProvider] == null) {
      data[pDataProvider] = HashMap<String?, DataChunk>();
    }

    data[pDataProvider]![pPageKey] = pPageChunk;

    if (initialized) {
      _addPage(pDataProvider, pPageKey, pPageChunk);
    }
  }

  _onSelectedRecord(String dataProvider, DataRecord? record) {
    if (record != null) {
      selectedRecords[dataProvider] = record;
    } else {
      selectedRecords.remove(dataProvider);
    }

    if (initialized && _hasAllMetaData()) {
      _updateSelection();
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
    // Do nothing
  }

  _handleNodeTap(String pNodeKey) {
    List<String> dataProviders = [];
    List<Filter?> filters = [];

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
      dataProviders.add(dataProviderAtTreeDepth(dataProviders.length)!);
      filters.add(null);
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
    node = node.copyWith(expanded: pExpanded);
    controller = controller.withUpdateNode(node.key, node);

    if (pExpanded) {
      if (node.children.isEmpty) {
        _fetchNodeChildren(node);
      } else {
        for (Node<NodeData> child in List<Node<NodeData>>.from(node.children)) {
          if (child.children.isEmpty && child.parent) {
            _fetchNodeChildren(child);
          }
        }
      }
    }
    setState(() {});
  }

  void _fetchNodeChildren(Node<NodeData> node) {
    String dataProvider = dataProviderAtTreeDepth(node.data!.treePath.length - 1)!;
    DalMetaData metaData = metaDatas[dataProvider]!;
    String childDataProvider = dataProviderAtTreeDepth(node.data!.treePath.length)!;
    DalMetaData childMetaData = metaDatas[childDataProvider]!;

    List<dynamic> dataRow = data[dataProvider]![node.data!.pageKey]!.data[node.data!.rowIndex]!;

    Filter childFilter = _createChildFilter(childMetaData, metaData, dataRow);

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
    // Check if this data that is coming in is the first level of the tree.
    String baseDataProvider = dataProviderAtTreeDepth(0)!;
    bool isLevelZeroData =
        baseDataProvider == pDataProvider && IDataService().getDataBook(baseDataProvider)!.rootKey == pPageKey;

    // Get all the nodes that are receiving this page.
    List<Node<NodeData>> parentNodes = nodesReceivingPage[pDataProvider]?[pPageKey]
            ?.map((nodeKey) => controller.getNode<NodeData>(nodeKey)!)
            .toList() ??
        [];

    if (!isLevelZeroData && parentNodes.isEmpty) {
      // This page is not for us, so we can ignore it.
      return;
    }

    int treeDepth = isLevelZeroData ? 0 : parentNodes.first.data!.treePath.length;
    String? childDataBook = dataProviderAtTreeDepth(treeDepth + 1);

    if (childDataBook != null) {
      List<Node<NodeData>> childrenToUnsub = [];
      if (parentNodes.isNotEmpty) {
        // Remove all children nodes of these parent from receiving the child pages they haven been added to.
        for (Node<NodeData> parentNode in parentNodes) {
          for (Node child in parentNode.children) {
            childrenToUnsub.add(child as Node<NodeData>);
          }
        }
      } else {
        for (Node child in controller.children) {
          childrenToUnsub.add(child as Node<NodeData>);
        }
      }
      for (Node<NodeData> child in childrenToUnsub) {
        nodesReceivingPage[childDataBook]?[child.data!.subPageKey]?.remove(child.key);
      }
    }

    // All nodes that were build for each parent node.
    HashMap<String?, List<Node<NodeData>>> newNodesPerParent = HashMap();

    pPageChunk.data.forEach((rowIndex, dataRow) {
      // Filter to identify this row in the child nodes of our parent nodes.
      // The tree path is no indication as just the sorting could be switched between fetches. Need to use the
      // primary keys!
      Filter rowFilter = _createPrimaryKeysFilter(metaDatas[pDataProvider]!, dataRow, pPageChunk.columnDefinitions);

      // If there is another databook that is a child of this one, then we need to create a potential parent node.

      String nodeLabel = _createLabel(metaDatas[pDataProvider]!, dataRow, pPageChunk.columnDefinitions);

      int parentIndex = 0;

      // Loop through every parent but at least do it once, as we could have no parents and are base nodes.
      do {
        Node<NodeData>? parentNode = isLevelZeroData ? null : parentNodes[parentIndex];

        // Create the node key.
        List<int> treePath = [...parentNode?.data!.treePath ?? [], rowIndex];
        String nodeKey = treePath.toString();

        Filter? childFilter;
        if (childDataBook != null) {
          DalMetaData childMetaData = metaDatas[childDataBook]!;
          childFilter = _createChildFilter(childMetaData, metaDatas[pDataProvider]!, dataRow);

          // Add this node to the list of the page they are receiving.
          nodesReceivingPage
              .putIfAbsent(childDataBook, () => HashMap())
              .putIfAbsent(childFilter.toPageKey(), () => [])
              .add(nodeKey);
        }

        bool isPotentialParent = childDataBook != null;

        List<Node> oldNodes = isLevelZeroData ? controller.children : parentNode?.children ?? [];
        Node? oldNode = oldNodes.firstWhereOrNull(
            (element) => (element as Node<NodeData>).data!.rowFilter.toPageKey() == rowFilter.toPageKey());
        if (oldNode != null && !oldNode.parent) {
          isPotentialParent = false;
        }

        Node<NodeData> newNode = Node<NodeData>(
          key: nodeKey,
          children: oldNode?.children ?? [],
          expanded: oldNode?.expanded ?? false,
          data: NodeData(pPageKey, [...parentNode?.data!.treePath ?? [], rowIndex], rowIndex, rowFilter, pDataProvider,
              childFilter?.toPageKey()),
          parent: isPotentialParent,
          label: nodeLabel,
        );

        // Add the node to the list of new nodes for this parent.
        newNodesPerParent.putIfAbsent(parentNode?.key, () => []).add(newNode);

        // Fetch potential children for this node.
        if (model.detectEndNode &&
            newNode.children.isEmpty &&
            isPotentialParent &&
            (isLevelZeroData || (parentNode?.expanded == true))) {
          // Create the filter for the child nodes.

          IUiService().sendCommand(
            FetchCommand(
              fromRow: 0,
              rowCount: -1,
              dataProvider: childDataBook!,
              reason: "detecting first level end nodes",
              filter: childFilter,
            ),
          );
        }

        parentIndex++;
      } while (parentIndex < parentNodes.length);
    });

    if (isLevelZeroData) {
      controller = controller.copyWith(children: newNodesPerParent.values.first);
    } else {
      for (Node<NodeData> parentNode in parentNodes) {
        List<Node<NodeData>> children = newNodesPerParent[parentNode.key] ?? [];
        // Add the new nodes to the parent node.
        parentNode = parentNode.copyWith(
          children: children,
          parent: children.isNotEmpty,
        );

        // Update the parent node (and all its parents
        controller = controller.withUpdateNode(parentNode.key, parentNode);
      }
    }

    _updateSelection();
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
    if (pMetaData.columnViewTree.isNotEmpty) {
      String label = "";
      for (String column in pMetaData.columnViewTree) {
        if (label.isNotEmpty) {
          label += " ";
        }
        label += "${pDataRow[pColumnDefinitions.indexWhere((colDef) => colDef.name == column)]}";
      }
      return label;
    } else if (pMetaData.columnViewTable.isNotEmpty) {
      return pDataRow[pColumnDefinitions.indexWhere((colDef) => colDef.name == pMetaData.columnViewTable[0])]
          .toString();
    } else {
      return "No column view";
    }
  }

  Filter _createChildFilter(DalMetaData pChildMetaData, DalMetaData pParentMetaData, List<dynamic> pParentRow) {
    ReferenceDefinition? reference = pChildMetaData.masterReference;
    if (pChildMetaData.isSelfJoined() && pParentMetaData.dataProvider != pChildMetaData.dataProvider) {
      reference = pChildMetaData.rootReference ?? reference;
    }

    return Filter(
      columnNames: pChildMetaData.masterReference!.columnNames,
      values: pChildMetaData.masterReference!.columnNames.map((referencedColumn) {
        // Is there a reference to the parent table?
        if (!reference!.columnNames.contains(referencedColumn)) {
          return null;
        }

        // Get the name of the column in the parent table.
        String parentColumn = reference.referencedColumnNames[reference.columnNames.indexOf(referencedColumn)];

        // Get the index of the column in the parent table.
        int parentColumnIndex = pParentMetaData.columnDefinitions.indexWhere((colDef) => colDef.name == parentColumn);

        // Get the value of the column in the parent table.
        if (parentColumnIndex >= 0 && parentColumnIndex < pParentRow.length) {
          return pParentRow[parentColumnIndex];
        } else {
          return null;
        }
      }).toList(),
    );
  }

  void _updateSelection() {
    // Checks which data providers have selected rows.
    // Then checks which of these data providers has the highest tree depth.
    // The one with the highes tree depth is the one that is used to determine the selection.

    List<int> selectedTreePath = [];

    for (String dataProvider in model.dataProviders) {
      DataRecord? dataRecord = selectedRecords[dataProvider];
      if (dataRecord != null && (dataRecord.treePath?.isNotEmpty == true || dataRecord.index >= 0)) {
        if (dataRecord.treePath?.isNotEmpty == true) {
          selectedTreePath.addAll(dataRecord.treePath!);
        }
        if (dataRecord.index >= 0) {
          selectedTreePath.add(dataRecord.index);
        }
      } else {
        break;
      }
    }

    if (selectedTreePath.isEmpty) {
      controller = controller.copyWith(selectedKey: "");
    } else {
      Node? selectedNode = getNodeFromTreePath(selectedTreePath);
      if (selectedNode != null) {
        controller = controller.copyWith(selectedKey: selectedNode.key);
      } else {
        controller = controller.copyWith(selectedKey: "");
      }
    }

    setState(() {});
  }

  Node? getNodeFromTreePath(List<int> pTreePath, [Node? parentNode]) {
    Iterator iter = (parentNode?.children ?? controller.children).iterator;
    while (iter.moveNext()) {
      Node<NodeData> child = iter.current;
      if (listEquals(child.data!.treePath, pTreePath)) {
        return child;
      } else if (child.isParent &&
          child.data!.treePath.length < pTreePath.length &&
          listEquals(child.data!.treePath, pTreePath.sublist(0, child.data!.treePath.length))) {
        return getNodeFromTreePath(pTreePath, child);
      }
    }
    return null;
  }

  Future<void> _refresh() async {
    if (initialized && _hasAllMetaData()) {
      controller = TreeViewController(children: <Node<List<NodeData>>>[]);
      data.clear();
      selectedRecords.clear();
      nodesReceivingPage.clear();
      initialized = false;
      _initTree();
    }
  }
}

class NodeData {
  // The page key in which this node has been added with.
  final String? pageKey;

  // The tree path of the node.
  final List<int> treePath;

  // The row index of the corresponding data row in the data page it is in.
  final int rowIndex;

  // The primary key filter of the corresponding data row. Used to select the node in the request.
  final Filter rowFilter;

  // The data provider of the corresponding data row.
  final String dataProvider;

  // The page key from which i get my children.
  final String? subPageKey;

  NodeData(this.pageKey, this.treePath, this.rowIndex, this.rowFilter, this.dataProvider, this.subPageKey);
}
