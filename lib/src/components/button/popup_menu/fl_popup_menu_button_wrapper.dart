import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../model/component/button/fl_popup_menu_button_model.dart';
import '../../../model/component/button/fl_popup_menu_items_model.dart';
import '../../../model/component/button/fl_popup_menu_model.dart';
import '../../../model/component/button/fl_seperator.dart';
import '../../../model/component/fl_component_model.dart';
import '../fl_button_wrapper.dart';
import 'fl_popup_menu_button_widget.dart';
import 'fl_popup_menu_item_widget.dart';

class FlPopupMenuButtonWrapper extends FlButtonWrapper<FlPopupMenuButtonModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlPopupMenuButtonWrapper({Key? key, required String id}) : super(key: key, id: id);

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
  Widget build(BuildContext context) {
    FlPopupMenuButtonWidget popupButtonWidget = FlPopupMenuButtonWidget(
      model: model,
      onPress: onPress,
      onItemPress: sendButtonPressed,
      popupItems: _createPopupItems(),
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: popupButtonWidget);
  }

  List<PopupMenuEntry<String>> _createPopupItems() {
    List<PopupMenuEntry<String>> listOfItems = [];
    if (model.isEnabled) {
      List<FlComponentModel> menuItems = [];

      // Get all children models
      List<FlComponentModel> listOfPopupMenuModels = uiService.getChildrenModels(model.id);
      // Remove all non popup menu models
      listOfPopupMenuModels.removeWhere((element) => element is! FlPopupMenuModel);

      for (FlComponentModel popupMenuModel in listOfPopupMenuModels) {
        List<FlComponentModel> listOfPopupMenuItems = uiService.getChildrenModels(popupMenuModel.id);
        // Remove all non popup menu item models
        listOfPopupMenuItems.removeWhere((element) => element is! FlPopupMenuItemModel && element is! FlSeperatorModel);

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
