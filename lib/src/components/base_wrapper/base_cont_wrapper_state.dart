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

import 'package:flutter/widgets.dart';

import '../../custom/custom_component.dart';
import '../../model/command/layout/register_parent_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../components_factory.dart';
import 'base_comp_wrapper_state.dart';

/// The base class for all states of FlutterJVx's container wrapper.
///
/// A container is a class which holds one or more children components
/// and has all the information on how to layout them.
///
/// A wrapper is a stateful widget that wraps FlutterJVx widgets and handles all JVx specific implementations and functionality.
/// e.g:
///
/// Model inits/updates; Layout inits/updates; Size calculation; Subscription handling for data widgets.
abstract class BaseContWrapperState<T extends FlPanelModel> extends BaseCompWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// A map of all children widgets
  Map<String, Widget> children = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  BaseContWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  affected() {
    buildChildren();
    registerParent();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Will send a [RegisterParentCommand] to [IUiService] sending its current
  /// layoutData and, if possible, initiates a layout cycle.
  void registerParent() {
    RegisterParentCommand registerParentCommand = RegisterParentCommand(
      layoutData: layoutData.clone(),
      reason: "parent register",
    );
    IUiService().sendCommand(registerParentCommand);
  }

  /// Will contact [IStorageService] to get its children [FlComponentModel], will only call setState if
  /// children were either added or removed.
  bool buildChildren({bool pSetStateOnChange = true}) {
    List<FlComponentModel> models =
        IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false);
    Map<String, Widget> newChildrenList = {};

    bool changeDetected = false;

    // Only new children will be checked
    for (FlComponentModel model in models) {
      if (!children.containsKey(model.id)) {
        // If custom component with name exits create a custom widget instead of a normal one
        CustomComponent? customComp = IUiService().getCustomComponent(pComponentName: model.name);
        if (customComp != null) {
          newChildrenList[model.id] = ComponentsFactory.buildCustomWidget(model.id, customComp);
        } else {
          newChildrenList[model.id] = ComponentsFactory.buildWidget(model);
        }

        changeDetected = true;
      } else {
        newChildrenList[model.id] = children[model.id]!;
      }
    }

    // Check if there are children in the old list not present in the new List
    children.forEach((key, value) {
      if (!models.any((element) => element.id == key)) {
        changeDetected = true;
      }
    });

    // Only re-render if children did change
    if (changeDetected) {
      layoutData.children.clear();
      newChildrenList.forEach((key, value) {
        layoutData.children.add(key);
      });

      children = newChildrenList;
      if (pSetStateOnChange) {
        setState(() {});
      }
    }

    return changeDetected;
  }
}
