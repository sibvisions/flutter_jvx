/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:collection/collection.dart';

import '../../../flutter_ui.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/layout/preferred_size_command.dart';
import '../../../model/command/layout/register_parent_command.dart';
import '../../../model/command/ui/update_layout_position_command.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/layout/layout_position.dart';
import '../../../util/jvx_logger.dart';
import '../../service.dart';
import '../i_layout_service.dart';

// DON'T use other services from this service, because it's an isolate on mobile devices

class LayoutService implements ILayoutService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  /// The map of all registered components
  final HashMap<String, LayoutData> _layoutDataSet = HashMap<String, LayoutData>();

  /// The map of all layout components
  final List<String> _currentlyLayouting = [];

  /// If layouting is currently allowed.
  bool _isValid = true;

  /// Last set screen size.
  HashMap<String, Size> screenSizes = HashMap<String, Size>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LayoutService.create();

  @override
  FutureOr<void> clear(ClearReason reason) {
    _isValid = true;
    _currentlyLayouting.clear();
    _layoutDataSet.clear();
  }

  @override
  Future<List<BaseCommand>> reportLayout({required LayoutData layoutData}) async {
    if (FlutterUI.logLayout.cl(Lvl.d)) {
      FlutterUI.logLayout.d("${layoutData.name}|${layoutData.id} reportLayout: [${layoutData.bestSize}]; pos: [${layoutData.layoutPosition}]");
    }

    layoutData.layoutState = LayoutState.VALID;

    // Set object with new data, if component isn't a child it's treated as the top most panel
    if (!layoutData.isChild) {
      applyScreenSize(layoutData);
    }

    _layoutDataSet[layoutData.id] = layoutData;

    // Handle possible re-layout
    if (_isLegalState(layoutData: layoutData, message: "reportLayout of ${layoutData.name}")) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${layoutData.name}|${layoutData.id} not in legal state --> perform Layout!");
      }

      return _performLayout(layoutData: layoutData);
    }

    return [];
  }

  @override
  Future<List<BaseCommand>> reportPreferredSize({required LayoutData layoutData}) async {
    if (FlutterUI.logLayout.cl(Lvl.d)) {
      FlutterUI.logLayout.d("${layoutData.name}|${layoutData.id} reportPreferredSize: ${layoutData.bestSize}");
    }

    layoutData.layoutState = LayoutState.VALID;

    // Set object with new data.
    var oldLayoutData = _layoutDataSet[layoutData.id];
    _layoutDataSet[layoutData.id] = layoutData;

    List<BaseCommand> commands = [];

    // If child lost its position, give it back the old one.
    if (oldLayoutData != null && !layoutData.hasPosition && oldLayoutData.hasPosition == true) {
      layoutData.layoutPosition = oldLayoutData.layoutPosition;
      commands.add(UpdateLayoutPositionCommand(layoutDataList: [layoutData], reason: "Receive old position"));
    }

    if (oldLayoutData != null && layoutData.receivedDate == null && oldLayoutData.receivedDate != null) {
      layoutData.receivedDate = oldLayoutData.receivedDate;
    }

    // Handle possible re-layout, check if parentId exists -> special case for first panel
    String? parentId = layoutData.parentId;
    if (parentId == null) {
      return commands;
    }

    LayoutData? parentData = _layoutDataSet[parentId];
    if (parentData == null) {
      return commands;
    }

    if (!_isLegalState(layoutData: parentData, message: "reportPreferredSize of ${layoutData.name}")) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${layoutData.name}|${layoutData.id} not in legal state!");
      }
      return commands;
    }

    if (parentData.hasPosition &&
        //without this check, layouting would fail if e.g. FirstWorkScreen added panel has a preferred size
        //also Popup of SimpleWorkScreen would look empty
        layoutData.hasPosition &&
        oldLayoutData?.layoutState == LayoutState.VALID &&
        oldLayoutData?.bestSize == layoutData.bestSize) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${layoutData.id} size: ${layoutData.bestSize} is same as before");
      }

      //this is important for replaced components e.g. Custom contacts of example application
      //because custom component won't receive the layout position - because it's a custom widget
      List<LayoutData> updateChildren = [];
      updateChildren.add(layoutData);
      updateChildren.addAll(_getChildren(parentLayout: layoutData));
      updateChildren = updateChildren.where((entry) => (entry.receivedDate == null && !entry.preparedForSubmission &&
                                                        entry.hasPosition && entry.hasNewCalculatedSize)).toList();

      updateChildren.forEach((element) {
        element.preparedForSubmission = true;
      });

      if (updateChildren.isNotEmpty) {
        commands.add(UpdateLayoutPositionCommand(layoutDataList: updateChildren, reason: "Notify additional sub components"));
      }

      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${layoutData.name}|${layoutData.id} parent already has a position!");
      }

      return commands;
    }

    parentData.layoutState = LayoutState.VALID;

    return _performLayout(layoutData: parentData);
  }

  @override
  Future<List<BaseCommand>> setScreenSize({required String screenComponentId, required Size size}) async {
    if (FlutterUI.logLayout.cl(Lvl.d)) {
      FlutterUI.logLayout.d("setScreenSize: $screenComponentId: $size");
    }

    screenSizes[screenComponentId] = size;

    LayoutData? existingLayout = _layoutDataSet[screenComponentId];

    if (existingLayout != null && existingLayout.layoutPosition?.toSize() != size) {
      applyScreenSize(existingLayout);

      if (_isLegalState(layoutData: existingLayout, message: "setScreenSize of $screenComponentId")) {
        //if legal-state -> everything is fine -> VALID
        existingLayout.layoutState = LayoutState.VALID;

        return _performLayout(layoutData: existingLayout);
      }
    }

    return [];
  }

  @override
  Future<bool> markLayoutAsDirty({required String componentId}) async {
    LayoutData? data = _layoutDataSet[componentId];

    if (data != null) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("$componentId marked as DIRTY");
      }
      data.layoutState = LayoutState.DIRTY;

      return true;
    }
    return false;
  }

  @override
  Future<bool> removeLayout({required String componentId}) async {
    var deleted = _layoutDataSet.remove(componentId);
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

  @override
  Future<bool> deleteScreen({required String componentId}) async {
    var deleted = _layoutDataSet.remove(componentId);
    if (deleted == null) {
      return false;
    }

    List<LayoutData> descendants = _getDescendants(parentLayout: deleted);
    descendants.forEach((element) {
      _layoutDataSet.remove(element.id);
    });

    return true;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LayoutPosition _getScreenPosition(String componentId) {
    Size screenSize = screenSizes[componentId] ?? Size.zero;

    return LayoutPosition(
      width: screenSize.width,
      height: screenSize.height,
      top: 0,
      left: 0,
    );
  }

  /// Applies the current screen size to the given [LayoutData]
  void applyScreenSize(LayoutData layoutData) {
    layoutData.layoutPosition = _getScreenPosition(layoutData.id);
    layoutData.widthConstrains = {};
    layoutData.heightConstrains = {};
  }

  /// Performs a layout operation.
  List<BaseCommand> _performLayout({required LayoutData layoutData}) {
    if (FlutterUI.logLayout.cl(Lvl.d)) {
      FlutterUI.logLayout.d(
          "${layoutData.name}|${layoutData.id} performLayout: [${layoutData.bestSize}]; pos: [${layoutData.layoutPosition}]");
    }
    _currentlyLayouting.add(layoutData.id);

    try {
      // Copy of parent
      LayoutData panel = LayoutData.from(layoutData);

      // Copy of children with deleted positions
      List<LayoutData> children = _getChildren(parentLayout: panel).map((data) => LayoutData.from(data)).toList();

      // All newly constraint children
      List<LayoutData> newlyConstraintChildren = [];

      // Needs to register again if this layout has been newly constraint by its parent.
      panel.lastCalculatedSize = panel.calculatedSize;

      if (panel.layout != null) {
        panel.layout!.calculateLayout(panel, children);
      }

      if (FlutterUI.logLayout.cl(Lvl.d)) {
        if (panel.hasNewCalculatedSize) {
          FlutterUI.logLayout.d(
              "${layoutData.name}|${layoutData.id} new calc size ${panel.calculatedSize}; old: ${panel.lastCalculatedSize}");
        }
      }

      // Check if any children have been newly constrained.
      for (LayoutData child in children) {
        _layoutDataSet[child.id] = child;
        if (child.isNewlyConstraint) {
          newlyConstraintChildren.add(child);
          markLayoutAsDirty(componentId: child.id);
          child.layoutPosition!.isConstraintCalc = true;
        }
      }

      if (newlyConstraintChildren.isNotEmpty) {
        return [UpdateLayoutPositionCommand(layoutDataList: newlyConstraintChildren, reason: "Was constrained")];
      }

      // Nothing has been "newly" constrained meaning now, the panel can tell its parent exactly how big it wants to be.
      // So if my calc size has changed - tell parent, if not, tell children their position.
      var commands = <BaseCommand>[];

      if (panel.isChild && panel.hasNewCalculatedSize) {
        if (FlutterUI.logLayout.cl(Lvl.d)) {
          FlutterUI.logLayout.d(
              "${layoutData.name}|${layoutData.id} has new calc size: ${panel.calculatedSize} -> PreferredSizeCommand");
        }

        return [PreferredSizeCommand(layoutData: panel, reason: "Has new calc size")];
      } else {
        // Only save information AFTER calculations after constrained children.
        _layoutDataSet[panel.id] = panel;
        // Bugfix: Update layout position always has to come first.
        commands.add(UpdateLayoutPositionCommand(layoutDataList: [panel, ...children], reason: "New position"));

        for (LayoutData child in children) {
          if (child.isParent) {
            if (FlutterUI.logLayout.cl(Lvl.d)) {
              FlutterUI.logLayout.d("${child.name}|${child.id} register after parent calc: ${child.layoutPosition}");
            }

            commands.add(RegisterParentCommand(layoutData: child, reason: "New position"));
          }
        }
      }

      return commands;
    } finally {
      _currentlyLayouting.remove(layoutData.id);
    }
  }

  /// Returns true if conditions to perform the layout are met.
  ///
  /// Checks if [layoutData] is valid and all it's children layout data are present and valid as well.
  bool _isLegalState({required LayoutData layoutData, String? message}) {
    if (!_isValid) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${layoutData.id} not valid, layoutService is not valid");
      }

      return false;
    }

    if (layoutData.layoutState != LayoutState.VALID) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${layoutData.id} not valid, layoutState: ${layoutData.layoutState}");
      }

      return false;
    }

    List<LayoutData> children = _getChildren(parentLayout: layoutData);

    if (children.length != layoutData.children.length) {
      int diff = layoutData.children.length - children.length;
      if (diff > 5) {
        if (FlutterUI.logLayout.cl(Lvl.d)) {
          FlutterUI.logLayout.d("${layoutData.id} not valid, missing children count: $diff");
        }
      } else {
        if (FlutterUI.logLayout.cl(Lvl.d)) {
          var listMissing = layoutData.children.where((childId) => !children.any((child) => child.id == childId));
          FlutterUI.logLayout.d("${layoutData.id} not valid, missing children: $listMissing");
        }
      }
      return false;
    }

    return children.none((child) {
      if (child.layoutState != LayoutState.VALID) {
        if (FlutterUI.logLayout.cl(Lvl.d)) {
          FlutterUI.logLayout.d("${layoutData.id} not valid because ${child.id} not valid");
        }

        return true;
      }

      if (!child.hasCalculatedSize && !child.hasNewCalculatedSize) {
        if (FlutterUI.logLayout.cl(Lvl.d)) {
          FlutterUI.logLayout.d("${layoutData.id} not valid because ${child.id} has no size");
        }

        return true;
      }

      return false;
    });
  }

  List<LayoutData> _getChildren({required LayoutData parentLayout}) {
    List<LayoutData> childrenData = [];

    for (String childId in parentLayout.children) {
      LayoutData? childData = _layoutDataSet[childId];
      if (childData != null) {
        childrenData.add(childData);
      }
    }

    return childrenData;
  }

  List<LayoutData> _getDescendants({required LayoutData parentLayout}) {
    List<LayoutData> childrenData = [];

    for (String childId in parentLayout.children) {
      LayoutData? childData = _layoutDataSet[childId];
      if (childData != null) {
        childrenData.add(childData);
        childrenData.addAll(_getDescendants(parentLayout: childData));
      }
    }

    return childrenData;
  }
}
