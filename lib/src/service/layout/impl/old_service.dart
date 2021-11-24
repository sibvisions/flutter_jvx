import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';
import 'package:flutter_client/util/extensions/list_extensions.dart';

/// [RenderEventService] handles the layouts of the containers
/// and evaluates if certain states of the component widgets have to be changed.
// Author: Toni Heiss
class RenderEventService {
  /// The map of all registered parents (container).
  final HashMap<String, LayoutData> parents = HashMap<String, LayoutData>();

  /// Registers a parent for receiving child constraint changes.
  ///
  /// Returns `true` if registered as a new parent and `false` if it was replaced.
  bool registerAsParent(dynamic pEvent) {
    List<LayoutData>? children;

    LayoutData? ldRegisteredParent = parents[pEvent.id];
    if (ldRegisteredParent != null) {
      children = ldRegisteredParent.children?.where((element) => pEvent.childrenIds.contains(element.id)).toList();
    }
    else{
      children = pEvent.childrenIds.map((childId) => LayoutData(id: childId, parentId: pEvent.id)).toList();
    }

    //Builds Children with only Id, so the preferred Size can be added later.
    parents[pEvent.id] = LayoutData(id: pEvent.id, layout: pEvent.layout, children: children);

    return ldRegisteredParent != null;
  }

  /// Removes a parent.
  ///
  /// Returns `true` if removed and `false` if nothing was removed.
  bool removeAsParent(String pParentId)
  {
    return parents.remove(pParentId) != null;
  }

  /// Registers a preferred size for a child element.
  void registerPreferredSizeEvent(dynamic pEvent) {
    LayoutData? parent = parents[pEvent.parent];
    if(parent != null)
    {
      LayoutData? child = parent.children!.firstWhereOrNull((element) => element.id == pEvent.id);
      if (child != null)
      {
        // Set PreferredSize and constraints
        child.preferredSize = pEvent.size;
        child.constraints = pEvent.constraints;

        // DeepCopy to make sure data can't be changed by other events while checks and calculation are running
        LayoutData parentSnapShot = parent.clone();

        bool legalLayoutState = parentSnapShot.children!.every((element) => element.preferredSize != null);

        if (legalLayoutState) {
          _performCalculation(parentSnapShot);
        }
      }
    }
  }

  _performCalculation(LayoutData pParent) {
    // Use compute(new Isolate) to not lock app while layout is calculating
    Future? layoutData = compute(_calculateLayout, pParent);

    // register callback on compute completion
    layoutData.then((value) => {log(value.toString())});
  }
}

/// Compute method to calculate the layout async.
List<LayoutPosition> _calculateLayout(LayoutData pParent) {
  return pParent.layout!.calculateLayout(pParent);
}
