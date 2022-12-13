/* Copyright 2022 SIB Visions GmbH
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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../model/component/button/fl_popup_menu_button_model.dart';
import '../../../model/component/button/fl_popup_menu_item_model.dart';
import '../../../model/component/button/fl_popup_menu_model.dart';
import '../../../model/component/button/fl_separator.dart';
import '../../../model/component/component_subscription.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../service/storage/i_storage_service.dart';
import '../../../service/ui/i_ui_service.dart';
import '../fl_button_wrapper.dart';
import 'fl_popup_menu_button_widget.dart';
import 'fl_popup_menu_item_widget.dart';

class FlPopupMenuButtonWrapper extends FlButtonWrapper<FlPopupMenuButtonModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlPopupMenuButtonWrapper({super.key, required super.id});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlPopupMenuButtonWrapperState createState() => FlPopupMenuButtonWrapperState();
}

class FlPopupMenuButtonWrapperState<T extends FlPopupMenuButtonModel> extends FlButtonWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    registerDescendantModels();
  }

  @override
  void modelUpdated() {
    super.modelUpdated();

    registerDescendantModels();
  }

  ///Register descendant models to receive ui updates
  void registerDescendantModels() {
    List<FlComponentModel> descendantModels = IStorageService().getAllComponentsBelowById(pParentId: model.id);
    for (var childModel in descendantModels) {
      IUiService().disposeSubscriptions(pSubscriber: childModel.id);
      ComponentSubscription componentSubscription = ComponentSubscription(
        compId: childModel.id,
        subbedObj: this,
        modelCallback: () => setState(() {}),
      );
      IUiService().registerAsLiveComponent(pComponentSubscription: componentSubscription);
    }
  }

  @override
  void dispose() {
    IUiService().disposeSubscriptions(pSubscriber: this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlPopupMenuButtonWidget popupButtonWidget = FlPopupMenuButtonWidget(
      onFocusGained: sendFocusGainedCommand,
      onFocusLost: sendFocusLostCommand,
      model: model,
      onItemPress: sendButtonPressed,
      popupItems: _createPopupItems(),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: popupButtonWidget);
  }

  List<PopupMenuEntry<String>> _createPopupItems() {
    List<PopupMenuEntry<String>> listOfItems = [];
    if (model.isEnabled) {
      List<FlComponentModel> menuItems = [];

      // Get all children models
      List<FlComponentModel> listOfPopupMenuModels =
          IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false);
      // Remove all non popup menu models
      listOfPopupMenuModels.removeWhere((element) => element is! FlPopupMenuModel);

      for (FlComponentModel popupMenuModel in listOfPopupMenuModels) {
        List<FlComponentModel> listOfPopupMenuItems =
            IStorageService().getAllComponentsBelowById(pParentId: popupMenuModel.id, pRecursively: false);
        // Remove all non popup menu item models
        listOfPopupMenuItems.removeWhere((element) => element is! FlPopupMenuItemModel && element is! FlSeparatorModel);

        menuItems.addAll(listOfPopupMenuItems);
      }

      bool forceIconSlot = menuItems.any((element) => element is FlPopupMenuItemModel && element.icon != null);
      menuItems.sort((a, b) => a.indexOf.compareTo(b.indexOf));
      for (FlComponentModel popupMenuItemModel in menuItems) {
        if (popupMenuItemModel is FlPopupMenuItemModel) {
          listOfItems.add(FlPopupMenuItemWidget.withModel(popupMenuItemModel, forceIconSlot));
        } else {
          listOfItems.add(
            const PopupMenuDivider(
              height: 1,
            ),
          );
        }
      }
    }
    return listOfItems;
  }
}
