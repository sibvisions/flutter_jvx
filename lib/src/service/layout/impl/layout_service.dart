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
  List<BaseCommand> registerAsParent(
      {required String pId,
      required List<String> pChildrenIds,
      required String pLayout,
      String? pLayoutData,
      String? pConstraints}) {
    LayoutData? ldRegisteredParent = _layoutDataSet[pId];

    // If Size has been set do NOT override it, used to set sizes from outside, e.g. First-Screen, Split-Screen.
    if (ldRegisteredParent != null) {
      ldRegisteredParent.layoutState = LayoutState.valid;
      ldRegisteredParent.layout = ILayout.getLayout(pLayout, pLayoutData);
      ldRegisteredParent.children = pChildrenIds;
      ldRegisteredParent.layoutData = pLayoutData;
      ldRegisteredParent.layoutString = pLayout;
    } else {
      _layoutDataSet[pId] = LayoutData(
          id: pId,
          layout: ILayout.getLayout(pLayout, pLayoutData),
          children: pChildrenIds,
          layoutString: pLayout,
          layoutData: pLayoutData);
    }

    // Only initialize children not here yet
    for (String childId in pChildrenIds) {
      LayoutData? childLayout = _layoutDataSet[childId];
      if (childLayout == null) {
        _layoutDataSet[childId] = LayoutData(id: childId, parentId: pId);
      }
    }

    bool legalState = _isLegalState(componentId: pId);

    if (legalState) {
      return _calculateLayout(pId);
    }

    return [];
  }

  @override
  bool removeAsParent(String pParentId) {
    return _layoutDataSet.remove(pParentId) != null;
  }

  @override
  List<BaseCommand> registerPreferredSize(String pId, String pParentId, LayoutData pLayoutData) {
    _layoutDataSet[pId] = pLayoutData;
    pLayoutData.layoutState = LayoutState.valid;

    bool isLegalState = _isLegalState(componentId: pParentId);
    if (isLegalState) {
      return _calculateLayout(pParentId);
    }

    return [];
  }

  @override
  List<BaseCommand> setComponentSize({required String id, required Size size}) {
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
      layoutData.layoutState = LayoutState.dirty;
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _saveLayoutPositions(String pParentId, Map<String, LayoutPosition> pPositions, DateTime pStartOfCall) {
    LayoutData parent = _layoutDataSet[pParentId]!;
    for (int index = 0; index < parent.children!.length; index++) {
      LayoutData child = _layoutDataSet[parent.children![index]]!;
      if (child.layoutPosition == null || child.layoutPosition!.timeOfCall!.isBefore(pStartOfCall)) {
        child.layoutPosition = pPositions[child.id]!;
        child.layoutPosition!.timeOfCall = pStartOfCall;
      }
    }
    if (parent.layoutPosition == null || parent.layoutPosition!.timeOfCall!.isBefore(pStartOfCall)) {
      parent.layoutPosition = pPositions[pParentId];
      parent.layoutPosition!.timeOfCall = pStartOfCall;
    }
  }

  List<BaseCommand> _applyLayoutConstraints(String pParentId) {
    LayoutData parent = _layoutDataSet[pParentId]!;
    Map<String, LayoutPosition> positions = {};

    positions[pParentId] = parent.layoutPosition!;

    for (int index = 0; index < parent.children!.length; index++) {
      LayoutData child = _layoutDataSet[parent.children![index]]!;
      positions[child.id] = child.layoutPosition!;
    }

    UpdateLayoutPositionCommand updateComponentsCommand =
        UpdateLayoutPositionCommand(layoutPosition: positions, reason: "Layout has finished");
    return [updateComponentsCommand];
  }

  List<BaseCommand> _calculateLayout(String pParentId) {
    // Time the start of the layout call.
    DateTime startOfCall = DateTime.now();

    // DeepCopy to make sure data can't be changed by other events while checks and calculation are running
    LayoutData parentSnapShot = _layoutDataSet[pParentId]!.clone();

    List<LayoutData> children = [];
    for (int index = 0; index < parentSnapShot.children!.length; index++) {
      children.add(_layoutDataSet[parentSnapShot.children![index]]!);
    }

    // Returns a bunch of layout positions.
    var sizes = parentSnapShot.layout!.calculateLayout(parentSnapShot, children);

    // Saves all layout positions.
    _saveLayoutPositions(pParentId, sizes, startOfCall);

    // Get real parent object again.
    LayoutData parent = _layoutDataSet[pParentId]!;

    // Does parent already have positions? If yes, means we already have completely layouted everything.
    LayoutData? parentParent = _layoutDataSet[parent.parentId];
    if (parentParent == null ||
        (parentParent.hasPosition && !startOfCall.isBefore(parentParent.layoutPosition!.timeOfCall!))) {
      return _applyLayoutConstraints(pParentId);
    } else {
      registerPreferredSize(parent.id, parent.parentId!, parent);
    }

    return [];
  }

  bool _isLegalState({required String componentId}) {
    bool legalLayoutState = true;
    LayoutData? parent = _layoutDataSet[componentId];

    if (parent != null) {
      for (int index = 0; legalLayoutState && index < parent.children!.length; index++) {
        LayoutData child = _layoutDataSet[parent.children![index]]!;
        legalLayoutState =
            (child.hasCalculatedSize || child.hasPreferredSize) && (child.layoutState != LayoutState.dirty);
      }
    }
    return legalLayoutState;
  }
}
