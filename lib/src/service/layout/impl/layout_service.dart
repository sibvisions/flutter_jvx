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
  final HashMap<String, LayoutData> setLayoutData = HashMap<String, LayoutData>();

  String? topPanelId;

  @override
  Size? screenSize;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  bool registerAsParent(String pId, List<String> pChildrenIds, ILayout pLayout) {
    LayoutData newParentData = LayoutData(id: pId, layout: pLayout, children: pChildrenIds);
    LayoutData? ldRegisteredParent = setLayoutData[pId];

    if(setLayoutData.isEmpty){
      if (screenSize != null)
      {
        newParentData.layoutPosition = LayoutPosition(width: screenSize!.width, height: screenSize!.height, top: 0, left: 0, isComponentSize: true, timeOfCall: DateTime.now());
      }
      else
      {
          throw ArgumentError("Screen size is not set!");
      }
    }
    // TODO find a better way.
    else if (ldRegisteredParent != null && ldRegisteredParent.parentId == null)
    {
      if (screenSize != null)
      {
        newParentData.layoutPosition = LayoutPosition(width: screenSize!.width, height: screenSize!.height, top: 0, left: 0, isComponentSize: true, timeOfCall: DateTime.now());
      }
      else {
        throw ArgumentError("Screen size is not set!");
      }
    }

    setLayoutData[pId] = newParentData;

    pChildrenIds.map((e) => LayoutData(id: e, parentId: pId)).forEach((element) {setLayoutData[element.id] = element;});

    return ldRegisteredParent != null;
  }

  @override
  bool removeAsParent(String pParentId) {
    return setLayoutData.remove(pParentId) != null;
  }

  @override
  List<BaseCommand> registerPreferredSize(String pId, String pParentId, LayoutData pLayoutData) {
    setLayoutData[pId] = pLayoutData;

    LayoutData? parent = setLayoutData[pParentId];
    if (parent != null) {
      bool legalLayoutState = true;
      for (int index = 0; legalLayoutState && index < parent.children!.length; index++) {
        LayoutData child = setLayoutData[parent.children![index]]!;
        legalLayoutState = child.hasCalculatedSize || child.hasPreferredSize;
      }
      if (legalLayoutState) {
        return calculateLayout(pParentId);
      }
    }

    return [];
  }

  @override
  void saveLayoutPositions(String pParentId, Map<String, LayoutPosition> pPositions, DateTime pStartOfCall) {
    LayoutData parent = setLayoutData[pParentId]!;

        //
    for (int index = 0; index < parent.children!.length; index++) {
      LayoutData child = setLayoutData[parent.children![index]]!;
      if (child.layoutPosition == null || child.layoutPosition!.timeOfCall!.isBefore(pStartOfCall) ) {
        child.layoutPosition = pPositions[child.id]!;
        child.layoutPosition!.timeOfCall = pStartOfCall;
      }
    }
      //
    if (parent.layoutPosition == null || parent.layoutPosition!.timeOfCall!.isBefore(pStartOfCall) ) {
      parent.layoutPosition = pPositions[pParentId];
      parent.layoutPosition!.timeOfCall = pStartOfCall;
    }
  }

  @override
  List<BaseCommand> applyLayoutConstraints(String pParentId) {
    // TODO switch to LayoutData

    LayoutData parent = setLayoutData[pParentId]!;
    Map<String, LayoutPosition> positions = {};

    positions[pParentId] = parent.layoutPosition!;

    for (int index = 0; index < parent.children!.length; index++) {
      LayoutData child = setLayoutData[parent.children![index]]!;
      positions[child.id] = child.layoutPosition!;
    }

    UpdateLayoutPositionCommand updateComponentsCommand = UpdateLayoutPositionCommand(layoutPosition: positions, reason: "Layout has finished");
    return [updateComponentsCommand];
  }

  @override
  List<BaseCommand> calculateLayout(String pParentId) {
    // Time the start of the layout call.
    DateTime startOfCall = DateTime.now();

    // DeepCopy to make sure data can't be changed by other events while checks and calculation are running
    LayoutData parentSnapShot = setLayoutData[pParentId]!.clone();

    List<LayoutData> children = [];
    for (int index = 0; index < parentSnapShot.children!.length; index++) {
      children.add(setLayoutData[parentSnapShot.children![index]]!);
    }

    // Returns a bunch of layout positions.
    var sizes = parentSnapShot.layout!.calculateLayout(parentSnapShot, children);

    // Saves all layout positions.
    saveLayoutPositions(pParentId, sizes, startOfCall);

    // Get real parent object again.
    LayoutData parent = setLayoutData[pParentId]!;

    // Does parent already have positions? If yes, means we already have completely layouted everything.
    LayoutData? parentParent = setLayoutData[parent.parentId];
    if (parentParent == null ||
        (parentParent.hasPosition && !startOfCall.isBefore(parentParent.layoutPosition!.timeOfCall!))) {
      return applyLayoutConstraints(pParentId);
    } else {
      registerPreferredSize(parent.id, parent.parentId!, parent);
    }

    return [];
  }
}
