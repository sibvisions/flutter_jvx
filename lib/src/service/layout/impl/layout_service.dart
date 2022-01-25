import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import '../../../model/command/layout/preferred_size_command.dart';
import '../../../model/command/layout/register_parent_command.dart';

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

  /// The map of all layouting components
  final List<String> _currentlyLayouting = [];

  /// If layouting is currently allowed.
  bool _isValid = true;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> reportLayout({required LayoutData pLayoutData}) async {
    log("reportLayout: ${pLayoutData.id} with ${pLayoutData.layout}");
    pLayoutData.layoutState = LayoutState.VALID;

    // Set object with new data, if component isn't a child its treated as the top most panel
    if (!pLayoutData.isChild) {
      LayoutData data = _layoutDataSet[pLayoutData.id]!;
      pLayoutData.layoutPosition = data.layoutPosition;
      pLayoutData.calculatedSize = Size(data.layoutPosition!.width, data.layoutPosition!.height);
    }
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    // Handle possible re-layout
    if (_isLegalState(pParentLayout: pLayoutData)) {
      return _performLayout(pParentLayout: pLayoutData);
    }

    return [];
  }

  @override
  Future<List<BaseCommand>> reportPreferredSize({required LayoutData pLayoutData}) async {
    log("Report size: ${pLayoutData.id}, calculated: ${pLayoutData.calculatedSize}, heightConstraints: ${pLayoutData.heightConstrains}, widthConstriants: ${pLayoutData.widthConstrains}");
    pLayoutData.layoutState = LayoutState.VALID;

    if (pLayoutData.hasNewCalculatedSize) {
      pLayoutData.widthConstrains = {};
      pLayoutData.heightConstrains = {};
      pLayoutData.lastCalculatedSize = pLayoutData.calculatedSize;
    }

    // Set object with new data.
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    // Handle possible re-layout, check if parentId exists -> special case for first panel
    String? parentId = pLayoutData.parentId;
    if (parentId != null) {
      LayoutData parentData = _layoutDataSet[parentId]!;
      if (_isLegalState(pParentLayout: parentData)) {
        return _performLayout(pParentLayout: parentData);
      }
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

    List<BaseCommand> commands = [];

    LayoutData? existingLayout = _layoutDataSet[pScreenComponentId];
    if (existingLayout != null) {
      existingLayout.calculatedSize = pSize;
      existingLayout.layoutPosition = position;

      existingLayout.widthConstrains = {};
      existingLayout.heightConstrains = {};

      if (_isLegalState(pParentLayout: existingLayout)) {
        commands.addAll(await _performLayout(pParentLayout: existingLayout));
      }
    } else {
      existingLayout = _layoutDataSet[pScreenComponentId] = LayoutData(
          id: pScreenComponentId,
          layoutPosition: position,
          calculatedSize: pSize,
          lastCalculatedSize: pSize,
          widthConstrains: {},
          heightConstrains: {});
    }

    commands.add(UpdateLayoutPositionCommand(layoutDataList: [existingLayout], reason: "ScreenSize"));

    return commands;
  }

  @override
  Future<bool> markLayoutAsDirty({required String pComponentId}) async {
    LayoutData? data = _layoutDataSet[pComponentId];

    if (data != null) {
      log("$pComponentId was marked as DIRTY");
      data.layoutState = LayoutState.DIRTY;
      return true;
    }
    return false;
  }

  @override
  bool removeLayout({required String pComponentId}) {
    return false;
  }

  @override
  Future<bool> layoutInProcess() async {
    return _currentlyLayouting.isNotEmpty;
  }

  @override
  Future<bool> isValid() async {
    return _isValid;
  }

  @override
  Future<bool> setValid({required bool isValid}) async {
    _isValid = isValid;

    return _isValid;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Performs a layout operation.
  Future<List<BaseCommand>> _performLayout({required LayoutData pParentLayout}) async {
    log("perform Layout ${pParentLayout.id}");

    // Copy of parent
    LayoutData parent = LayoutData.from(pParentLayout);

    // Copy of children with deleted positions
    List<LayoutData> children = _getChildrenOrNull(pParentLayout: parent)!.map((data) {
      LayoutData copy = LayoutData.from(data);
      copy.layoutPosition = null;
      return copy;
    }).toList();

    List<BaseCommand> commands = [];

    // True if this parent needs to register itself again.
    bool needsToRegister = false;

    // True if there are any constrained Children
    bool needsRebuild = false;

    // All newly constraint children
    List<LayoutData> newlyConstraintChildren = [];

    // Needs to register again if this layout has been newly constraint by its parent.
    if (parent.isNewlyConstraint || !parent.hasPosition) {
      needsToRegister = true;
    }

    parent.layout!.calculateLayout(parent, children);

    // Check if any children have been constrained.
    for (LayoutData child in children) {
      if (child.isNewlyConstraint) {
        newlyConstraintChildren.add(child);
        needsRebuild = true;
        markLayoutAsDirty(pComponentId: child.id);
      } else if (child.isConstrained) {
        needsRebuild = true;
      }
    }

    if (needsRebuild && newlyConstraintChildren.isEmpty) {
      parent.layout!.calculateLayout(parent, children);
    } else if (newlyConstraintChildren.isNotEmpty) {
      for (LayoutData child in newlyConstraintChildren) {
        if (child.isParent) {
          commands.add(RegisterParentCommand(layoutData: child, reason: "Was constrained"));
        }
      }
      commands.add(UpdateLayoutPositionCommand(layoutDataList: newlyConstraintChildren, reason: "Was constrained"));
      return commands;
    }

    if (needsToRegister) {
      commands.add(PreferredSizeCommand(layoutData: parent, reason: "Finished Constrained calc"));
      for (LayoutData child in children) {
        _layoutDataSet[child.id] = child;
      }
    } else {
      for (LayoutData child in children) {
        _layoutDataSet[child.id] = child;
        if (child.isParent) {
          commands.add(RegisterParentCommand(layoutData: child, reason: "Has finished"));
        }
      }
      commands.add(UpdateLayoutPositionCommand(layoutDataList: children, reason: "Has finished"));
    }
    return commands;

    // if(needsRebuild && newlyConstraintChildren.isEmpty){
    //   parent.layout!.calculateLayout(parent, children);
    //
    //   if(needsToRegister) {
    //     commands.add(PreferredSizeCommand(layoutData: parent, reason: "Has finished Constrain calculation"));
    //   } else {
    //     commands.add(UpdateLayoutPositionCommand(layoutDataList: children, reason: "Layout run has finished"));
    //     _layoutDataSet[parent.id] = parent;
    //     for(LayoutData child in children) {
    //       if(child.isParent){
    //         commands.add(RegisterParentCommand(layoutData: child, reason: "Parent has finished calculating your position"));
    //       } else {
    //         _layoutDataSet[child.id] = child;
    //       }
    //     }
    //   }
    // }
    // else if(newlyConstraintChildren.isNotEmpty){
    //   List<LayoutData> constraintChildren = [];
    //
    //   // Separate commands components and parents
    //   for(LayoutData child in newlyConstraintChildren){
    //     if(child.isParent){
    //       commands.add(RegisterParentCommand(layoutData: child, reason: "Constraint Check from ${parent.id}"));
    //     } else {
    //       constraintChildren.add(child);
    //     }
    //   }
    //   commands.add(UpdateLayoutPositionCommand(layoutDataList: constraintChildren, reason: "ConstraintCheck from ${parent.id}"));
    // }
    // else if(needsToRegister) {
    //   commands.add(PreferredSizeCommand(layoutData: parent, reason: "Has finished Constrain calculation"));
    // }
    // else {
    //   commands.add(UpdateLayoutPositionCommand(layoutDataList: children, reason: "Layout run has finished"));
    //   _layoutDataSet[parent.id] = parent;
    //   for(LayoutData child in children) {
    //     if(child.isParent){
    //       commands.add(RegisterParentCommand(layoutData: child, reason: "Parent has finished calculating your position"));
    //     } else {
    //       _layoutDataSet[child.id] = child;
    //     }
    //   }
    // }
  }

  /// Returns true if conditions to perform the layout are met.
  bool _isLegalState({required LayoutData pParentLayout}) {
    if (!_isValid) {
      log("I am not valid. ${pParentLayout.id}");
      return false;
    }

    List<LayoutData>? children = _getChildrenOrNull(pParentLayout: pParentLayout);

    if (pParentLayout.layoutState == LayoutState.VALID && children != null) {
      bool areChildrenValid =
          children.every((element) => ((element.layoutState == LayoutState.VALID) && element.hasCalculatedSize));
      return areChildrenValid;
    }
    return false;
  }

  List<LayoutData>? _getChildrenOrNull({required LayoutData pParentLayout}) {
    List<LayoutData> childrenData = [];

    for (String childId in pParentLayout.children) {
      LayoutData? childData = _layoutDataSet[childId];
      if (childData != null) {
        childrenData.add(childData);
      } else {
        return null;
      }
    }
    return childrenData;
  }
}
