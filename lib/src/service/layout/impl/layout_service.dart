import 'dart:collection';
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
    LayoutData? ldRegisteredParent = _layoutDataSet[pLayoutData.id];

    // If Size has been set do NOT override it, used to set sizes from outside, e.g. First-Screen, Split-Screen.
    if (ldRegisteredParent != null) {
      pLayoutData.calculatedSize ??= ldRegisteredParent.calculatedSize;
      pLayoutData.lastCalculatedSize = ldRegisteredParent.calculatedSize;
      pLayoutData.layoutPosition = ldRegisteredParent.layoutPosition;
    }
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    // Only initialize children not here yet
    for (String childId in pLayoutData.children!) {
      LayoutData? childLayout = _layoutDataSet[childId];
      if (childLayout == null) {
        _layoutDataSet[childId] = LayoutData(id: childId, parentId: pLayoutData.id);
      }
    }

    bool legalState = _isLegalState(componentId: pLayoutData.id);

    if (legalState) {
      return _performLayout(pLayoutData.id);
    }

    return [];
  }

  @override
  bool removeAsParent(String pParentId) {
    return _layoutDataSet.remove(pParentId) != null;
  }

  @override
  List<BaseCommand> registerPreferredSize(String pId, LayoutData pLayoutData) {
    _layoutDataSet[pId] = pLayoutData;
    pLayoutData.layoutState = LayoutState.VALID;


    if(pLayoutData.hasNewCalculatedSize) {
      if (pLayoutData.parentId != null) {
        bool isLegalState = _isLegalState(componentId: pLayoutData.parentId!);
        if (isLegalState) {
          return _performLayout(pLayoutData.parentId!);
        }
      }
    }

    pLayoutData.lastCalculatedSize = pLayoutData.calculatedSize;



    return [];
  }

  @override
  List<BaseCommand> setComponentSize({required String id, required Size size}) {

    _layoutDataSet.forEach((key, value) {value.layoutPosition = null;});

    LayoutData? layoutData = _layoutDataSet[id];
    if (layoutData != null) {
      LayoutPosition? layoutPosition = layoutData.layoutPosition;
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
      LayoutData layoutData = LayoutData(id: id, layoutPosition: layoutPosition);
      _layoutDataSet[id] = layoutData;
    }

    //Todo, check for legal state

    return [];
  }

  @override
  void markLayoutAsDirty({required String id}) {
    LayoutData? layoutData = _layoutDataSet[id];

    if (layoutData != null) {
      layoutData.layoutState = LayoutState.DIRTY;
    }
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
        LayoutData child = _layoutDataSet[parent.children![index]]!;
        legalLayoutState =
            (child.hasCalculatedSize || child.hasPreferredSize) && child.layoutState == LayoutState.VALID;
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

    List<LayoutData> children = [];
    for (int index = 0; index < parentSnapShot.children!.length; index++) {
      children.add(_layoutDataSet[parentSnapShot.children![index]]!.clone());
    }

    // Returns a bunch of layout positions.
    HashMap<String, LayoutData> sizes = parentSnapShot.layout!.calculateLayout(parentSnapShot, children);

    // Saves all layout positions.
    _saveLayoutPositions(pParentId, sizes, startOfCall);

    // Get real parent object again.
    LayoutData parent = _layoutDataSet[pParentId]!;

    // We only register our size (layouts the parent of the parent) if the following:
    // We dont have a position.
    // We have a position but it is old.
    // We have a position but our calc size is different.
    if (parent.hasPosition && (!startOfCall.isBefore(parent.layoutPosition!.timeOfCall!) || !parent.hasNewCalculatedSize)) {
      return _applyLayoutConstraints(pParentId);
    } else {
      registerPreferredSize(parent.id, parent);
    }

    return [];
  }

  void _saveLayoutPositions(String pParentId, HashMap<String, LayoutData> pNewData, DateTime pStartOfCall) {
    LayoutData parent = _layoutDataSet[pParentId]!;

    for (int index = 0; index < parent.children!.length; index++) {
      LayoutData child = _layoutDataSet[parent.children![index]]!;

      if (child.layoutPosition == null || child.layoutPosition!.timeOfCall!.isBefore(pStartOfCall)) {
        LayoutData? newChildData = pNewData[child.id];
        if (newChildData != null) {
          child.layoutPosition = newChildData.layoutPosition;
          child.layoutPosition!.timeOfCall = pStartOfCall;
          child.calculatedSize = newChildData.calculatedSize;
        }
      }
    }
  }

  List<BaseCommand> _applyLayoutConstraints(String pParentId) {
    LayoutData parent = _layoutDataSet[pParentId]!;
    HashMap<String, LayoutData> dataToUpdate = HashMap<String, LayoutData>();

    dataToUpdate[pParentId] = parent;

    for (int index = 0; index < parent.children!.length; index++) {
      LayoutData child = _layoutDataSet[parent.children![index]]!;
      dataToUpdate[child.id] = child;
    }

    UpdateLayoutPositionCommand updateComponentsCommand =
        UpdateLayoutPositionCommand(layoutPosition: dataToUpdate, reason: "Layout has finished");
    return [updateComponentsCommand];
  }
}
