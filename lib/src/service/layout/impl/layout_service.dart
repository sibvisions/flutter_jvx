import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import '../../../model/command/base_command.dart';
import '../../../model/command/ui/update_layout_position_command.dart';

import '../../../model/layout/layout_position.dart';

import '../../../model/layout/layout_data.dart';

import '../i_layout_service.dart';

class LayoutStorage implements ILayoutService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The map of all registered components
  final HashMap<String, LayoutData> _layoutDataSet = HashMap<String, LayoutData>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> reportLayout({required LayoutData pLayoutData}) async {
    log("reportLayout: ${pLayoutData.id}");
    pLayoutData.layoutState = LayoutState.VALID;

    // Set object with new data, if component isn't a child its treated as the top most panel
    if(!pLayoutData.isChild){
      LayoutData data = _layoutDataSet[pLayoutData.id]!;
      pLayoutData.layoutPosition = data.layoutPosition;
      pLayoutData.calculatedSize = Size(data.layoutPosition!.width, data.layoutPosition!.height);
    }
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    // Handle possible re-layout
    if(_isLegalState(pParentLayout: pLayoutData)){
      return _performLayout(pParentLayout: pLayoutData);
    }

    return [];
  }

  @override
  Future<List<BaseCommand>> reportPreferredSize({required LayoutData pLayoutData}) async {
    log("Report size: ${pLayoutData.id}, calculated: ${pLayoutData.calculatedSize}");
    pLayoutData.layoutState = LayoutState.VALID;

    // Set object with new data.
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    // Handle possible re-layout
    LayoutData parentData = _layoutDataSet[pLayoutData.parentId]!;
    if(_isLegalState(pParentLayout: parentData)){
      return _performLayout(pParentLayout: parentData);
    }

    return [];
  }

  @override
  Future<List<BaseCommand>> setScreenSize({required String pScreenComponentId, required Size pSize}) async {

    LayoutPosition position = LayoutPosition(
        width: pSize.width,
        height: pSize.height,
        top: 0,
        left: 0,
        isComponentSize: true,
        timeOfCall: DateTime.now()
    );

    LayoutData? existingLayout = _layoutDataSet[pScreenComponentId];
    if(existingLayout != null){
      existingLayout.calculatedSize = pSize;
      existingLayout.layoutPosition = position;

      if(_isLegalState(pParentLayout: existingLayout)){
        return _performLayout(pParentLayout: existingLayout);
      }
    } else {
      _layoutDataSet[pScreenComponentId] = LayoutData(
          id: pScreenComponentId,
          layoutPosition: position,
          calculatedSize: pSize,
          lastCalculatedSize: pSize
      );
    }

    return [];
  }

  @override
  void markLayoutAsDirty({required String pComponentId}) {
    LayoutData? data = _layoutDataSet[pComponentId];

    if(data != null){
     data.layoutState = LayoutState.DIRTY;
    }
  }

  @override
  bool removeLayout({required String pComponentId}) {

    return false;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true if conditions to perform the layout are met.
  bool _isLegalState({required LayoutData pParentLayout}) {
    List<LayoutData>? children = _getChildrenOrNull(pParentLayout: pParentLayout);

    if(pParentLayout.layoutState == LayoutState.VALID && children != null){
      bool areChildrenValid = children.every((element) =>
        ((element.layoutState == LayoutState.VALID) && (element.hasCalculatedSize || element.hasPreferredSize)));
      return areChildrenValid;
    }
    return false;
  }

  /// Performs a layout operation.
  Future<List<BaseCommand>> _performLayout({required LayoutData pParentLayout}) async {
    log("perform Layout: ${pParentLayout.id}");

    List<LayoutData> children = _getChildrenOrNull(pParentLayout: pParentLayout)!;

    pParentLayout.lastCalculatedSize = pParentLayout.calculatedSize;
    pParentLayout.layout!.calculateLayout(pParentLayout, children);

    // No Child because of first panel
    if(pParentLayout.hasNewCalculatedSize && pParentLayout.isChild){
      return reportPreferredSize(pLayoutData: pParentLayout);
    } else {
      List<BaseCommand> commands = [UpdateLayoutPositionCommand(layoutDataList: children, reason: "Layout has finished")];

      for(LayoutData child in children){
        if(child.isParent && _isLegalState(pParentLayout: child)) {
          var childCommands = await _performLayout(pParentLayout: child);
          commands.addAll(childCommands);
        }
      }
      if(!pParentLayout.isChild){
        children.add(pParentLayout);
      }
      return commands;
    }
  }


  List<LayoutData>? _getChildrenOrNull({required LayoutData pParentLayout}){
    List<LayoutData> childrenData = [];

    for (String childId in pParentLayout.children){
      LayoutData? childData = _layoutDataSet[childId];
      if(childData != null){
        childrenData.add(childData);
      } else {
        return null;
      }
    }
    return childrenData;
  }
}
