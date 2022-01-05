import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import '../../../model/command/base_command.dart';
import '../../../model/command/ui/update_layout_position_command.dart';

import '../../../model/layout/layout_position.dart';

import '../../../model/layout/layout_data.dart';

import '../i_layout_service.dart';

class LayoutService implements ILayoutService {
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
    log("Report size: ${pLayoutData.id}, calculated: ${pLayoutData.calculatedSize}, heightConstraints: ${pLayoutData.heightConstrains}, widthConstriants: ${pLayoutData.widthConstrains}");
    pLayoutData.layoutState = LayoutState.VALID;

    if(pLayoutData.hasNewCalculatedSize){
      pLayoutData.widthConstrains = {};
      pLayoutData.heightConstrains = {};
      pLayoutData.lastCalculatedSize = pLayoutData.calculatedSize;
    }

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
        lastCalculatedSize: pSize,
        widthConstrains: {},
        heightConstrains: {}
      );
    }

    return [];
  }

  @override
  Future<bool> markLayoutAsDirty({required String pComponentId}) async {
    LayoutData? data = _layoutDataSet[pComponentId];

    if(data != null){
     data.layoutState = LayoutState.DIRTY;
     return true;
    }
    return false;
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

    // Copy of parent
    LayoutData parent = LayoutData.from(pParentLayout);

    // Copy of children with deleted positions
    List<LayoutData> children = _getChildrenOrNull(pParentLayout: parent)!.map((data) {
      LayoutData copy = LayoutData.from(data);
      copy.layoutPosition = null;
      return copy;
    }).toList();

    parent.lastCalculatedSize = parent.calculatedSize;
    parent.layout!.calculateLayout(parent, children);

    List<BaseCommand> commands = [UpdateLayoutPositionCommand(layoutDataList: children, reason: "Layout has finished")];


    if(parent.hasNewCalculatedSize && parent.isChild){
      return reportPreferredSize(pLayoutData: parent);
    } else {
      bool needsRebuild = false;
      bool rebuildReady = true;

      List<LayoutData> toBeConstrained = [];

      for(LayoutData child in children){
        _layoutDataSet[child.id] = child;

        // Handle constrained components. Components are constrained if their position is smaller than their calculated size
        if(!child.hasPreferredSize && child.hasCalculatedSize){
          double calcWidth = child.calculatedSize!.width;
          double calcHeight = child.calculatedSize!.height;

          double positionWidth = child.layoutPosition!.width;
          double positionHeight = child.layoutPosition!.height;

          // Check if component was once already constrained and has recalculated itself with constrained size.
          if(calcWidth > positionWidth || calcHeight > positionHeight){
            log("${child.id} was constrained, calculated: ${child.calculatedSize}, position: ${child.layoutPosition}" );
            needsRebuild = true;

            if((calcWidth > positionWidth && !child.widthConstrains.containsKey(positionWidth)) ||
                (calcHeight > positionHeight && !child.heightConstrains.containsKey(positionHeight)))
            {
              rebuildReady = false;
              if(!child.isParent){
                toBeConstrained.add(child);
                child.layoutState = LayoutState.DIRTY;
              }
            }
          }
        }
      }

      if(toBeConstrained.isNotEmpty){
        return [UpdateLayoutPositionCommand(layoutDataList: toBeConstrained, reason: "ConstraintCheck")];
      }

      if(needsRebuild && rebuildReady) {
        parent.layout!.calculateLayout(parent, children);
      }

      for(LayoutData child in children){
        if(child.isParent && _isLegalState(pParentLayout: child)) {
          var childCommands = await _performLayout(pParentLayout: child);
          commands.addAll(childCommands);
        }
      }

      // Special case for top most panel
      if(!parent.isChild){
        _layoutDataSet[parent.id] = parent;
        children.add(parent);
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
