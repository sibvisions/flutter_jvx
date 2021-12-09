import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

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
  void registerPreferredSize(String pId, String pParentId, Size pSize, String pConstraints) {
    DateTime startOfCall = DateTime.now();

    LayoutData? parent = _parents[pParentId];
    if (parent != null) {
      LayoutData? child = parent.children!.firstWhereOrNull((element) => element.id == pId);
      if (child != null) {
        // Set PreferredSize and constraints
        child.preferredSize = pSize;
        child.constraints = pConstraints;

        // DeepCopy to make sure data can't be changed by other events while checks and calculation are running
        LayoutData parentSnapShot = parent.clone();

        //
        bool legalLayoutState = parentSnapShot.children!.every((element) => element.preferredSize != null);

        if (legalLayoutState) {
          var sizes = _calculateLayout(parent);

          LayoutPosition? position = parent.layoutPosition;
          if(position != null){
            applyLayoutConstraints(pParentId, sizes, startOfCall);
          } else {
            String? parentId = parent.parentId;
            if(parentId != null){
              LayoutPosition data = sizes[parentId]!;
              registerPreferredSize(parent.id, parentId, Size(data.width, data.height), parent.constraints!);
            }
          }
        }
      }
    }
  }

  @override
  void applyLayoutConstraints(String pParentId, Map<String, LayoutPosition> pPositions, DateTime pStartOfCall) {
    for (LayoutData child in _parents[pParentId]!.children!) {
      if (child.layoutPosition == null || child.layoutPosition!.timeOfCall!.isBefore(pStartOfCall)) {
        LayoutPosition position = pPositions[child.id]!;
        position.timeOfCall = pStartOfCall;
        child.layoutPosition = position;

        // TODO send data to child component.
      }
    }

    // TODO send data to parent component.
  }

  @override
  void setSize({required Size setSize, required String id}){
    LayoutData layoutData = _parents[id]!;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Compute method to calculate the layout async.
  Map<String, LayoutPosition> _calculateLayout(LayoutData pParent) {
    return pParent.layout!.calculateLayout(pParent);
  }
}


