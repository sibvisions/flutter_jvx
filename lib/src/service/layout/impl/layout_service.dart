import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import '../../../../util/logging/flutter_logger.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/layout/preferred_size_command.dart';
import '../../../model/command/layout/register_parent_command.dart';
import '../../../model/command/ui/update_layout_position_command.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/layout/layout_position.dart';
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
    LOGGER.logD(pType: LOG_TYPE.LAYOUT, pMessage: "${pLayoutData.id} REPORT: ${pLayoutData.layout}");
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
    LOGGER.logD(
        pType: LOG_TYPE.LAYOUT,
        pMessage:
            "Report size: ${pLayoutData.id}, calculated: ${pLayoutData.calculatedSize}, heightConstraints: ${pLayoutData.heightConstrains}, widthConstriants: ${pLayoutData.widthConstrains}");
    pLayoutData.layoutState = LayoutState.VALID;

    // Set object with new data.
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    // Handle possible re-layout, check if parentId exists -> special case for first panel
    String? parentId = pLayoutData.parentId;
    if (parentId != null) {
      LayoutData? parentData = _layoutDataSet[parentId];
      if (parentData != null) {
        if (_isLegalState(pParentLayout: parentData)) {
          return _performLayout(pParentLayout: parentData);
        }
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
      LOGGER.logD(pType: LOG_TYPE.LAYOUT, pMessage: "$pComponentId was marked as DIRTY");
      data.layoutState = LayoutState.DIRTY;

      return true;
    }
    return false;
  }

  @override
  Future<bool> removeLayout({required String pComponentId}) async {
    var deleted = _layoutDataSet.remove(pComponentId);
    return deleted == null ? false : true;
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
    LOGGER.logD(pType: LOG_TYPE.LAYOUT, pMessage: "${pParentLayout.id} PERFORM LAYOUT");
    _currentlyLayouting.add(pParentLayout.id);

    try {
      // Copy of parent
      LayoutData parent = LayoutData.from(pParentLayout);

      // Copy of children with deleted positions
      List<LayoutData> children = _getChildrenOrNull(pParentLayout: parent)!.map((data) {
        LayoutData copy = LayoutData.from(data);
        return copy;
      }).toList();

      // All newly constraint children
      List<LayoutData> newlyConstraintChildren = [];

      // Needs to register again if this layout has been newly constraint by its parent.
      parent.lastCalculatedSize = parent.calculatedSize;
      parent.layout!.calculateLayout(parent, children);

      LOGGER.logD(
          pType: LOG_TYPE.LAYOUT,
          pMessage:
              "${parent.id} CALC SIZE: ${parent.calculatedSize} ; OLD CALC SIZE: ${parent.lastCalculatedSize} ; HAS NEW: ${parent.hasNewCalculatedSize}");

      // Check if any children have been newly constrained.
      for (LayoutData child in children) {
        _layoutDataSet[child.id] = child;
        if (child.isNewlyConstraint && !child.isParent) {
          newlyConstraintChildren.add(child);
          markLayoutAsDirty(pComponentId: child.id);
          child.layoutPosition!.isConstraintCalc = true;
        }
      }

      if (newlyConstraintChildren.isNotEmpty) {
        return [UpdateLayoutPositionCommand(layoutDataList: newlyConstraintChildren, reason: "Was constrained")];
      }

      /// Only save information AFTER calculations after constrained children.
      _layoutDataSet[parent.id] = parent;

      // Nothing has been "newly" constrained meaning now, i can tell my parent exactly how big i want to be.
      // So if my calc size has changed - tell parent, if not, tell children their position.
      var commands = <BaseCommand>[];

      if (parent.isChild && parent.hasNewCalculatedSize) {
        return [PreferredSizeCommand(layoutData: parent, reason: "Has new calc size")];
      } else {
        for (LayoutData child in children) {
          if (child.isParent) {
            commands.add(RegisterParentCommand(layoutData: child, reason: "New position"));
          }
        }

        commands.add(UpdateLayoutPositionCommand(layoutDataList: [parent, ...children], reason: "New position"));
      }

      return commands;
    } finally {
      _currentlyLayouting.remove(pParentLayout.id);
    }
  }

  /// Returns true if conditions to perform the layout are met.
  bool _isLegalState({required LayoutData pParentLayout}) {
    if (!_isValid) {
      LOGGER.logD(pType: LOG_TYPE.LAYOUT, pMessage: "I am not valid. ${pParentLayout.id}");
      return false;
    }

    List<LayoutData>? children = _getChildrenOrNull(pParentLayout: pParentLayout);

    if (pParentLayout.layoutState == LayoutState.VALID && children != null) {
      for (LayoutData child in children) {
        if (!(child.layoutState == LayoutState.VALID && (child.hasCalculatedSize || child.hasPreferredSize))) {
          LOGGER.logD(
              pType: LOG_TYPE.LAYOUT,
              pMessage: "${child.id} is not valid because: ${child.layoutState}, ${child.hasCalculatedSize}, ${child.hasPreferredSize}");
          return false;
        }
      }

      return true;
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
