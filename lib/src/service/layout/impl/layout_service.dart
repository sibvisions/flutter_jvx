import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter_client/src/mixin/command_service_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/update_components_command.dart';
import 'package:flutter_client/src/model/command/ui/update_layout_position_command.dart';

import '../../../model/layout/layout_position.dart';

import '../../../layout/i_layout.dart';
import '../../../../util/extensions/list_extensions.dart';

import '../../../model/layout/layout_data.dart';

import '../i_layout_service.dart';

class LayoutService implements ILayoutService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The map of all registered parents (container).
  final HashMap<String, LayoutData> _parents = HashMap<String, LayoutData>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  bool registerAsParent(String pId, List<String> pChildrenIds, ILayout pLayout) {
    List<LayoutData>? children = pChildrenIds.map((childId) => LayoutData(id: childId, parentId: pId)).toList();

    LayoutData? ldRegisteredParent = _parents[pId];
    if (ldRegisteredParent != null) {
      for (LayoutData oldChild in ldRegisteredParent.children!) {
        // LayoutData implements == and Hashcode therefore we can remove an 'old'
        // child by id even though theoretically it does not exist in that list.
        if (children.remove(oldChild)) {
          children.add(oldChild);
        }
      }
    }

    //Builds Children with only Id, so the preferred Size can be added later.
    _parents[pId] = LayoutData(id: pId, layout: pLayout, children: children);

    return ldRegisteredParent != null;
  }

  @override
  bool removeAsParent(String pParentId) {
    return _parents.remove(pParentId) != null;
  }

  @override
  List<BaseCommand> registerPreferredSize(String pId, String pParentId, LayoutData pLayoutData) {
    LayoutData? itselfAsParent = _parents[pId];
    if (itselfAsParent != null) {
      var children = itselfAsParent.children;
      pLayoutData.children = children;
      _parents[pId] = pLayoutData;
    }

    LayoutData? parent = _parents[pParentId];
    if (parent != null) {
      LayoutData? child = parent.children!.firstWhereOrNull((element) => element.id == pId);
      if (child != null) {
        // Set PreferredSize and constraints
        parent.children!.remove(child);
        parent.children!.add(pLayoutData);

        bool legalLayoutState =
            parent.children!.every((element) => element.hasCalculatedSize || element.hasPreferredSize);
        if (legalLayoutState) {
          return calculateLayout(pParentId);
        }
      }
    }

    return [];
  }

  @override
  void saveLayoutPositions(String pParentId, Map<String, LayoutPosition> pPositions, DateTime pStartOfCall) {
    for (LayoutData child in _parents[pParentId]!.children!) {
      if (child.layoutPosition == null || child.layoutPosition!.timeOfCall!.isBefore(pStartOfCall)) {
        child.layoutPosition = pPositions[child.id]!;
        child.layoutPosition!.timeOfCall = pStartOfCall;
      }
    }

    LayoutData parent = _parents[pParentId]!;
    if (parent.layoutPosition == null || parent.layoutPosition!.timeOfCall!.isBefore(pStartOfCall)) {
      parent.layoutPosition = pPositions[pParentId];
      parent.layoutPosition!.timeOfCall = pStartOfCall;
    }
  }

  @override
  List<BaseCommand> applyLayoutConstraints(String pParentId) {
    Map<String, LayoutPosition> positions = {};
    for (LayoutData data in _parents[pParentId]!.children!) {
      positions[data.id] = data.layoutPosition!;
    }
    positions[pParentId] = _parents[pParentId]!.layoutPosition!;

    UpdateLayoutPositionCommand updateComponentsCommand =
        UpdateLayoutPositionCommand(layoutPosition: positions, reason: "Layout has finished");
    return [updateComponentsCommand];
  }

  @override
  List<BaseCommand> calculateLayout(String pParentId) {
    // Time the start of the layout call.
    DateTime startOfCall = DateTime.now();

    // DeepCopy to make sure data can't be changed by other events while checks and calculation are running
    LayoutData parentSnapShot = _parents[pParentId]!.clone();

    // Returns a bunch of layout positions.
    var sizes = parentSnapShot.layout!.calculateLayout(parentSnapShot);

    // Saves all layout positions.
    saveLayoutPositions(pParentId, sizes, startOfCall);

    // Get real parent object again.
    LayoutData parent = _parents[pParentId]!;

    // Does parent already have positions? If yes, means we already have completely layouted everything.
    LayoutData? parentParent = _parents[parent.parentId];
    if (parentParent == null ||
        (parentParent.hasPosition && !startOfCall.isBefore(parentParent.layoutPosition!.timeOfCall!))) {
      return applyLayoutConstraints(pParentId);
    } else {
      registerPreferredSize(parent.id, parent.parentId!, parent);
    }

    return [];
  }
}
