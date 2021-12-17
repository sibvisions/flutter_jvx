import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import '../../../model/command/base_command.dart';
import '../../../model/command/ui/update_layout_position_command.dart';

import '../../../model/layout/layout_position.dart';

import '../../../layout/i_layout.dart';

import '../../../model/layout/layout_data.dart';

import '../i_layout_service.dart';

class LayoutService implements ILayoutService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The map of all registered parents (container).
  final HashMap<String, LayoutData> _layoutDataSet = HashMap<String, LayoutData>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> registerAsParent({required LayoutData pLayoutData}) {
    log("Registering layout: ${pLayoutData.id} with ${pLayoutData.preferredSize}, ${pLayoutData.lastCalculatedSize}, ${pLayoutData.calculatedSize}, ${pLayoutData.layoutPosition}");

    LayoutData? ldRegisteredParent = _layoutDataSet[pLayoutData.id];

    if (ldRegisteredParent != null) {
      log("Already exists with ${ldRegisteredParent.layoutState} ${ldRegisteredParent.preferredSize}, ${ldRegisteredParent.lastCalculatedSize}, ${ldRegisteredParent.calculatedSize}, ${ldRegisteredParent.layoutPosition}");
      pLayoutData.calculatedSize ??= ldRegisteredParent.calculatedSize;
      pLayoutData.lastCalculatedSize = ldRegisteredParent.calculatedSize;
      pLayoutData.layoutPosition = ldRegisteredParent.layoutPosition;
    }
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    List<BaseCommand> listToReturn = [];
    if (!pLayoutData.isChild && pLayoutData.hasPosition)
    {
      listToReturn.add(UpdateLayoutPositionCommand(layoutPosition: HashMap.from({pLayoutData.id: pLayoutData}), reason: "Layout has finished"));
    } else if(_isLegalState(componentId: pLayoutData.id)) {
      listToReturn.addAll(_performLayout(pLayoutData.id));
    }

    if (_isLegalState(componentId: pLayoutData.id)) {
      listToReturn.addAll(_performLayout(pLayoutData.id));
    }

    return listToReturn;
  }

  @override
  List<BaseCommand> registerPreferredSize(String pId, LayoutData pLayoutData) {
    log("Registering size: $pId with ${pLayoutData.preferredSize} || ${pLayoutData.lastCalculatedSize} || ${pLayoutData.calculatedSize}");
    _layoutDataSet[pId] = pLayoutData;

    if(pLayoutData.hasNewCalculatedSize || pLayoutData.hasPreferredSize) {
      bool isLegalState = _isLegalState(componentId: pLayoutData.parentId!);
      // log("legal state for ${pLayoutData.parentId} is $isLegalState");
      if (isLegalState) {
        LayoutData parentData = _layoutDataSet[pLayoutData.parentId]!;
        parentData.lastCalculatedSize = parentData.calculatedSize;

        // Special case: uppermost layout does not calculates it's size
        if(!pLayoutData.isChild){
          parentData.calculatedSize = null;
        }
        return _performLayout(parentData.id);
      }
    } else {
      log("${pLayoutData.id} has no new CalculatedSize --------------------------------");
    }

    pLayoutData.lastCalculatedSize = pLayoutData.calculatedSize;

    return [];
  }

  @override
  List<BaseCommand> setComponentSize({required String id, required Size size}) {
    log("Setting component size of $id to $size");

    LayoutData? layoutData = _layoutDataSet[id];
    if (layoutData != null) {
      LayoutPosition? layoutPosition = layoutData.layoutPosition;
      layoutData.calculatedSize = size;
      if (layoutPosition != null) {
        layoutPosition.height = size.height;
        layoutPosition.width = size.width;
      } else {
        layoutData.layoutPosition = LayoutPosition(
            width: size.width, height: size.height, top: 0, left: 0, isComponentSize: true, timeOfCall: DateTime.now());
      }
    } else {
      LayoutPosition layoutPosition = LayoutPosition(
          width: size.width, height: size.height, top: 0, left: 0, isComponentSize: true, timeOfCall: DateTime.now());
      LayoutData layoutData = LayoutData(id: id, layoutPosition: layoutPosition, calculatedSize: size);
      _layoutDataSet[id] = layoutData;
    }

    return [];
  }

  @override
  void markLayoutAsDirty({required String id}) {
    LayoutData? layoutData = _layoutDataSet[id];

    if (layoutData != null) {
      layoutData.layoutState = LayoutState.DIRTY;
    }
  }

  @override
  bool removeAsParent(String pParentId) {
    return _layoutDataSet.remove(pParentId) != null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true if conditions to perform the layout are met.
  bool _isLegalState({required String componentId}) {
    bool legalLayoutState = true;
    LayoutData? parent = _layoutDataSet[componentId];

    if (parent != null && parent.layoutState == LayoutState.VALID) {
      for (int index = 0; legalLayoutState && index < parent.children!.length; index++) {
        LayoutData? child = _layoutDataSet[parent.children![index]];
        if(child != null){
          legalLayoutState = (child.hasCalculatedSize || child.hasPreferredSize) && child.layoutState == LayoutState.VALID;
        } else {
          legalLayoutState = false;
        }
      }
    }
    return legalLayoutState;
  }

  /// Performs a layout operation.
  List<BaseCommand> _performLayout(String pParentId) {
    // Time the start of the layout call.
    DateTime startOfCall = DateTime.now();

    // DeepCopy to make sure data can't be changed by other events while checks and calculation are running
    LayoutData parentSnapShot = _layoutDataSet[pParentId]!.clone();

    log("Calculating layout: ${parentSnapShot.id} with ${parentSnapShot.layout!.toString()}");

    List<LayoutData> children = [];
    for (int index = 0; index < parentSnapShot.children!.length; index++) {
      children.add(_layoutDataSet[parentSnapShot.children![index]]!.clone());
    }

    // Returns a bunch of layout positions.
    HashMap<String, LayoutData> sizes = parentSnapShot.layout!.calculateLayout(parentSnapShot, children);

    LayoutData parent = _layoutDataSet[pParentId]!;
    if (parentSnapShot.hasNewCalculatedSize)
    {
      // log("Layout: ${parentSnapShot.id} has new calc size of ${parentSnapShot.lastCalculatedSize} | ${parentSnapShot.calculatedSize}");
      parent.lastCalculatedSize = parent.calculatedSize;
      parent.calculatedSize = parentSnapShot.calculatedSize;
    }

    // We only register our size (layouts the parent of the parent) if the following:
    // We dont have a position.
    // We have a position but it is old.
    // We have a position but our calc size is different.
    if (parent.hasPosition && (!startOfCall.isBefore(parent.layoutPosition!.timeOfCall!) || !parentSnapShot.hasNewCalculatedSize)) {
      log ("Apply constraints to immediate children: ${parent.children} from $pParentId");
      return _applyLayoutConstraints(pParentId, sizes);
    } else {
      return registerPreferredSize(parent.id, parent);
    }
  }

  List<BaseCommand> _applyLayoutConstraints(String pParentId, HashMap<String, LayoutData> sizes) {

    List<BaseCommand> commands = [UpdateLayoutPositionCommand(layoutPosition: sizes, reason: "Layout has finished")];


    for (var childId in sizes.keys)
    {
      LayoutData child = _layoutDataSet[childId]!;
      child.layoutPosition = sizes[childId]!.layoutPosition;
      child.layoutPosition!.timeOfCall = DateTime.now();

      if (child.isParent)
      {
        commands.addAll(_performLayout(childId));
      }
    }

    return commands;
  }
}
