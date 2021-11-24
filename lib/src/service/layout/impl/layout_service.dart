import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
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
    List<LayoutData>? children;

    LayoutData? ldRegisteredParent = _parents[pId];
    if (ldRegisteredParent != null) {
      // TODO: Add non existing children!
      children = ldRegisteredParent.children?.where((element) => pChildrenIds.contains(element.id)).toList();
    }
    else{
      children = pChildrenIds.map((childId) => LayoutData(id: childId, parentId: pId)).toList();
    }

    //Builds Children with only Id, so the preferred Size can be added later.
    _parents[pId] = LayoutData(id: pId, layout: pLayout, children: children);

    return ldRegisteredParent != null;
  }

  @override
  bool removeAsParent(String pParentId)
  {
    return _parents.remove(pParentId) != null;
  }

  @override
  void registerPreferredSize(String pId, String pParentId, Size pSize, String pConstraints) {
    LayoutData? parent = _parents[pParentId];
    if(parent != null)
    {
      LayoutData? child = parent.children!.firstWhereOrNull((element) => element.id == pId);
      if (child != null)
      {
        // Set PreferredSize and constraints
        child.preferredSize = pSize;
        child.constraints = pConstraints;

        // DeepCopy to make sure data can't be changed by other events while checks and calculation are running
        LayoutData parentSnapShot = parent.clone();

        // If the parent insets are not set (null) we can't layout.
        bool legalLayoutState = parentSnapShot.hasInsets && parentSnapShot.children!.every((element) => element.preferredSize != null);

        if (legalLayoutState) {
          _performCalculation(parentSnapShot);
        }
      }
    }
  }

  @override
  void applyLayoutConstraints(String pParentId, Map<String, LayoutPosition> pPositions) {
    // TODO: implement applyLayoutConstraints
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _performCalculation(LayoutData pParent) {
    // Use compute(new Isolate) to not lock app while layout is calculating
    Future<Map<String, LayoutPosition>>? layoutData = compute(_calculateLayout, pParent);

    // register callback on compute completion
    layoutData.then((layoutPositions) => {applyLayoutConstraints(pParent.id, layoutPositions)});
  }
}

/// Compute method to calculate the layout async.
Map<String, LayoutPosition> _calculateLayout(LayoutData pParent) {
  return pParent.layout!.calculateLayout(pParent);
}