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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

  const FlPopupMenuButtonWrapper({super.key, required super.model});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlPopupMenuButtonWrapperState createState() => FlPopupMenuButtonWrapperState();
}

class FlPopupMenuButtonWrapperState<T extends FlPopupMenuButtonModel> extends FlButtonWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<FlComponentModel> _menuItems = [];

  final Map<String, FlPopupMenuButtonModel> _itemModels = {};

  bool forceIconSlot = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    _registerDescendantModels();
  }

  @override
  void modelUpdated() {
    super.modelUpdated();

    _registerDescendantModels();
  }

  @override
  void dispose() {
    IUiService().disposeSubscriptions(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlPopupMenuButtonWidget popupButtonWidget = FlPopupMenuButtonWidget(
      onFocusGained: focus,
      onFocusLost: unfocus,
      model: model,
      loading: isLoading,
      focusNode: buttonFocusNode,
      onItemPress: (value) {
        sendButtonPressed(_itemModels[value]);
      },
      popupItems: _createPopupItems(),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(context, popupButtonWidget);
  }

  /// Register descendant models to receive ui updates
  void _registerDescendantModels() {
    _updateDescendantModels();

    List<FlComponentModel> descendantModels = IStorageService().getAllComponentsBelowById(parentId: model.id);
    for (var childModel in descendantModels) {
      IUiService().disposeSubscriptions(childModel.id);
      ComponentSubscription componentSubscription = ComponentSubscription(
        compId: childModel.id,
        subbedObj: this,
        modelUpdatedCallback: () {
          _updateDescendantModels();

          setState(() {});
        }
      );

      IUiService().registerAsLiveComponent(componentSubscription);
    }
  }

  void _updateDescendantModels() {
    Map<String, FlPopupMenuButtonModel> oldModels = _itemModels;


    _menuItems.clear();
    _itemModels.clear();

    forceIconSlot = false;

    if (model.popupMenu != null) {
      List<FlComponentModel> listOfPopupMenuItems =
      IStorageService().getAllComponentsBelowById(parentId: model.popupMenu!, recursively: false);
      // Remove all non popup menu item models
      listOfPopupMenuItems.removeWhere((element) => element is! FlPopupMenuItemModel && element is! FlSeparatorModel);

      _menuItems.addAll(listOfPopupMenuItems);

      for (FlComponentModel popupMenuItemModel in _menuItems) {
        if (popupMenuItemModel is FlPopupMenuItemModel) {
          //re-use old model or create a "fake" button model just with the id (for pressed event)
          //re-using is important for model-updates in case of press event needs latest model properties
          //(e.g. server-side updates a property in pressed event)
          FlPopupMenuButtonModel modelNew = oldModels[popupMenuItemModel.name] ?? FlPopupMenuButtonModel();
          modelNew.applyFromJson(popupMenuItemModel.jsonMerge);
          modelNew.id = popupMenuItemModel.id;
          //important to have all properties
          modelNew.jsonMerge = popupMenuItemModel.jsonMerge;

          _itemModels[popupMenuItemModel.name] = modelNew;

          //if at least one element has an icon, show icon-space for the whole menu (avoids alignment problem)
          forceIconSlot |= popupMenuItemModel.icon != null;
        }
      }

      _menuItems.sort((a, b) => a.indexOf.compareTo(b.indexOf));
    }
  }

  List<PopupMenuEntry<String>> _createPopupItems() {
    List<PopupMenuEntry<String>> items = [];

    if (model.isEnabled) {
      for (FlComponentModel popupMenuItemModel in _menuItems) {
        if (popupMenuItemModel is FlPopupMenuItemModel) {
          items.add(FlPopupMenuItemWidget.withModel(popupMenuItemModel, forceIconSlot));
        } else {
          items.add(
            const PopupMenuDivider(
              height: 1,
            ),
          );
        }
      }
    }

    return items;
  }
}
