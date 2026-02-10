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
  Future<List<BaseCommand>> reportLayout({required LayoutData pLayoutData}) async {

    if (FlutterUI.logLayout.cl(Lvl.d)) {
      FlutterUI.logLayout.d("${pLayoutData.name}|${pLayoutData.id} reportLayout: [${pLayoutData.bestSize}]; pos: [${pLayoutData.layoutPosition}]");
    }

    pLayoutData.layoutState = LayoutState.VALID;

    // Set object with new data, if component isn't a child it's treated as the top most panel
    if (!pLayoutData.isChild) {
      applyScreenSize(pLayoutData);
    }

    _layoutDataSet[pLayoutData.id] = pLayoutData;

    // Handle possible re-layout
    if (_isLegalState(pLayoutData: pLayoutData, message: "reportLayout of ${pLayoutData.name}")) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${pLayoutData.name}|${pLayoutData.id} not in legal state --> perform Layout!");
      }

      return _performLayout(pLayoutData: pLayoutData);
    }

    return [];
  }

  @override
  Future<List<BaseCommand>> reportPreferredSize({required LayoutData pLayoutData}) async {
    if (FlutterUI.logLayout.cl(Lvl.d)) {
      FlutterUI.logLayout.d("${pLayoutData.name}|${pLayoutData.id} reportPreferredSize: ${pLayoutData.bestSize}");
    }

    pLayoutData.layoutState = LayoutState.VALID;

    // Set object with new data.
    var oldLayoutData = _layoutDataSet[pLayoutData.id];
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    List<BaseCommand> commands = [];

    // If child lost its position, give it back the old one.
    if (oldLayoutData != null && !pLayoutData.hasPosition && oldLayoutData.hasPosition == true) {
      pLayoutData.layoutPosition = oldLayoutData.layoutPosition;
      commands.add(UpdateLayoutPositionCommand(layoutDataList: [pLayoutData], reason: "Receive old position"));
    }

    if (oldLayoutData != null && pLayoutData.receivedDate == null && oldLayoutData.receivedDate != null) {
      pLayoutData.receivedDate = oldLayoutData.receivedDate;
    }

    // Handle possible re-layout, check if parentId exists -> special case for first panel
    String? parentId = pLayoutData.parentId;
    if (parentId == null) {
      return commands;
    }

    LayoutData? parentData = _layoutDataSet[parentId];
    if (parentData == null) {
      return commands;
    }

    if (!_isLegalState(pLayoutData: parentData, message: "reportPreferredSize of ${pLayoutData.name}")) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${pLayoutData.name}|${pLayoutData.id} not in legal state!");
      }

      return commands;
    }

    if (parentData.hasPosition &&
        //without this check, layouting would fail if e.g. FirstWorkScreen added panel has a preferred size
        //also Popup of SimpleWorkScreen would look empty
        pLayoutData.hasPosition &&
        oldLayoutData?.layoutState == LayoutState.VALID &&
        oldLayoutData?.bestSize == pLayoutData.bestSize) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${pLayoutData.id} size: ${pLayoutData.bestSize} is same as before");
      }

      //this is important for replaced components e.g. Custom contacts of example application
      //because custom component won't receive the layout position - because it's a custom widget
      List<LayoutData> updateChildren = [];
      updateChildren.add(pLayoutData);
      updateChildren.addAll(_getChildren(pParentLayout: pLayoutData));
      updateChildren = updateChildren.where((entry) => (entry.receivedDate == null && !entry.preparedForSubmission &&
                                                        entry.hasPosition && entry.hasNewCalculatedSize)).toList();

      updateChildren.forEach((element) {
        element.preparedForSubmission = true;
      });

      if (updateChildren.isNotEmpty) {
        commands.add(UpdateLayoutPositionCommand(layoutDataList: updateChildren, reason: "Notify additional sub components"));
      }

      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${pLayoutData.name}|${pLayoutData.id} parent already has a position!");
      }

      return commands;
    }

    return _performLayout(pLayoutData: parentData);
  }

  @override
  Future<List<BaseCommand>> setScreenSize({required String pScreenComponentId, required Size pSize}) async {
    if (FlutterUI.logLayout.cl(Lvl.d)) {
      FlutterUI.logLayout.d("setScreenSize: $pScreenComponentId: $pSize");
    }

    screenSizes[pScreenComponentId] = pSize;

    LayoutData? existingLayout = _layoutDataSet[pScreenComponentId];

    if (existingLayout != null && existingLayout.layoutPosition?.toSize() != pSize) {
      applyScreenSize(existingLayout);

      if (_isLegalState(pLayoutData: existingLayout, message: "setScreenSize of $pScreenComponentId")) {
        return _performLayout(pLayoutData: existingLayout);
      }
    }

    return [];
  }

  @override
  Future<bool> markLayoutAsDirty({required String pComponentId}) async {
    LayoutData? data = _layoutDataSet[pComponentId];

    if (data != null) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("$pComponentId marked as DIRTY");
      }
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

  @override
  Future<bool> deleteScreen({required String pComponentId}) async {
    var deleted = _layoutDataSet.remove(pComponentId);
    if (deleted == null) {
      return false;
    }

    List<LayoutData> descendants = _getDescendants(pParentLayout: deleted);
    descendants.forEach((element) {
      _layoutDataSet.remove(element.id);
    });

    return true;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LayoutPosition _getScreenPosition(String pComponentId) {
    Size screenSize = screenSizes[pComponentId] ?? Size.zero;

    return LayoutPosition(
      width: screenSize.width,
      height: screenSize.height,
      top: 0,
      left: 0,
    );
  }

  /// Applies the current screen size to the given [LayoutData]
  void applyScreenSize(LayoutData pLayoutData) {
    pLayoutData.layoutPosition = _getScreenPosition(pLayoutData.id);
    pLayoutData.widthConstrains = {};
    pLayoutData.heightConstrains = {};
  }

  /// Performs a layout operation.
  List<BaseCommand> _performLayout({required LayoutData pLayoutData}) {

    if (FlutterUI.logLayout.cl(Lvl.d)) {
      FlutterUI.logLayout.d(
          "${pLayoutData.name}|${pLayoutData.id} performLayout: [${pLayoutData.bestSize}]; pos: [${pLayoutData.layoutPosition}]");
    }
    _currentlyLayouting.add(pLayoutData.id);

    try {
      // Copy of parent
      LayoutData panel = LayoutData.from(pLayoutData);

      // Copy of children with deleted positions
      List<LayoutData> children = _getChildren(pParentLayout: panel).map((data) => LayoutData.from(data)).toList();

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
              "${pLayoutData.name}|${pLayoutData.id} new calc size ${panel.calculatedSize}; old: ${panel.lastCalculatedSize}");
        }
      }

      // Check if any children have been newly constrained.
      for (LayoutData child in children) {
        _layoutDataSet[child.id] = child;
        if (child.isNewlyConstraint) {
          newlyConstraintChildren.add(child);
          markLayoutAsDirty(pComponentId: child.id);
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
              "${pLayoutData.name}|${pLayoutData.id} has new calc size: ${panel.calculatedSize} -> PreferredSizeCommand");
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
      _currentlyLayouting.remove(pLayoutData.id);
    }
  }

  /// Returns true if conditions to perform the layout are met.
  ///
  /// Checks if [pLayoutData] is valid and all it's children layout data are present and valid as well.
  bool _isLegalState({required LayoutData pLayoutData, String? message}) {
    if (!_isValid) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${pLayoutData.id} not valid, layoutService is not valid");
      }

      return false;
    }

    if (pLayoutData.layoutState != LayoutState.VALID) {
      if (FlutterUI.logLayout.cl(Lvl.d)) {
        FlutterUI.logLayout.d("${pLayoutData.id} not valid, layoutState: ${pLayoutData.layoutState}");
      }

      return false;
    }

    List<LayoutData> children = _getChildren(pParentLayout: pLayoutData);

    if (children.length != pLayoutData.children.length) {
      int diff = pLayoutData.children.length - children.length;
      if (diff > 5) {
        if (FlutterUI.logLayout.cl(Lvl.d)) {
          FlutterUI.logLayout.d("${pLayoutData.id} not valid, missing children count: $diff");
        }
      } else {
        if (FlutterUI.logLayout.cl(Lvl.d)) {
          var listMissing = pLayoutData.children.where((childId) => !children.any((child) => child.id == childId));
          FlutterUI.logLayout.d("${pLayoutData.id} not valid, missing children: $listMissing");
        }
      }
      return false;
    }

    return children.none((child) {
      if (child.layoutState != LayoutState.VALID) {
        if (FlutterUI.logLayout.cl(Lvl.d)) {
          FlutterUI.logLayout.d("${pLayoutData.id} not valid because ${child.id} not valid");
        }

        return true;
      }

      if (!child.hasCalculatedSize && !child.hasNewCalculatedSize) {
        if (FlutterUI.logLayout.cl(Lvl.d)) {
          FlutterUI.logLayout.d("${pLayoutData.id} not valid because ${child.id} has no size");
        }

        return true;
      }

      return false;
    });
  }

  List<LayoutData> _getChildren({required LayoutData pParentLayout}) {
    List<LayoutData> childrenData = [];

    for (String childId in pParentLayout.children) {
      LayoutData? childData = _layoutDataSet[childId];
      if (childData != null) {
        childrenData.add(childData);
      }
    }

    return childrenData;
  }

  List<LayoutData> _getDescendants({required LayoutData pParentLayout}) {
    List<LayoutData> childrenData = [];

    for (String childId in pParentLayout.children) {
      LayoutData? childData = _layoutDataSet[childId];
      if (childData != null) {
        childrenData.add(childData);
        childrenData.addAll(_getDescendants(pParentLayout: childData));
      }
    }

    return childrenData;
  }
}
