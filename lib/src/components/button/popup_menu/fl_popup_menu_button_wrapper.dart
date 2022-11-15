import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../model/component/button/fl_popup_menu_button_model.dart';
import '../../../model/component/button/fl_popup_menu_item_model.dart';
import '../../../model/component/button/fl_popup_menu_model.dart';
import '../../../model/component/button/fl_separator.dart';
import '../../../model/component/component_subscription.dart';
import '../../../model/component/fl_component_model.dart';
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
  void receiveNewModel(T pModel) {
    //Dispose old subscriptions
    List<FlComponentModel> oldModels = IUiService().getDescendantModels(model.id);
    oldModels.forEach((element) => IUiService().disposeSubscriptions(pSubscriber: element));

    super.receiveNewModel(pModel);

    registerDescendantModels();
  }

  ///Register descendant models to receive ui updates
  void registerDescendantModels() {
    List<FlComponentModel> descendantModels = IUiService().getDescendantModels(model.id);
    for (var childModel in descendantModels) {
      ComponentSubscription componentSubscription = ComponentSubscription(
        compId: childModel.id,
        subbedObj: this,
        modelCallback: (_) => setState(() {}),
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
      List<FlComponentModel> listOfPopupMenuModels = IUiService().getChildrenModels(model.id);
      // Remove all non popup menu models
      listOfPopupMenuModels.removeWhere((element) => element is! FlPopupMenuModel);

      for (FlComponentModel popupMenuModel in listOfPopupMenuModels) {
        List<FlComponentModel> listOfPopupMenuItems = IUiService().getChildrenModels(popupMenuModel.id);
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
