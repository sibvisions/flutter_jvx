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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../model/component/button/fl_popup_menu_button_model.dart';
import '../fl_button_widget.dart';
import 'fl_popup_menu_item_widget.dart';

/// A popup menu button. Is itself a button that either sends a [PressButtonCommand] or opens a menu.
class FlPopupMenuButtonWidget<T extends FlPopupMenuButtonModel> extends FlButtonWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The function to call if an item has been pressed.
  final Function(String)? onItemPress;

  /// The menu entries for the popup menu.
  final List<PopupMenuEntry<String>> popupItems;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlPopupMenuButtonWidget({
    super.key,
    required super.model,
    this.onItemPress,
    required this.popupItems,
    super.onPress,
    super.onFocusGained,
    super.onFocusLost,
    super.onPressDown,
    super.onPressUp,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Function()? getOnPressed(BuildContext context) {
    if (model.isEnabled) {
      FlPopupMenuItemWidget? popupItem = popupItems
          .whereType<FlPopupMenuItemWidget>()
          .firstWhereOrNull((element) => element.id == model.defaultMenuItem);

      if (popupItem != null) {
        return () => onItemPress?.call(popupItem.value!);
      }
      return () => openMenu(context);
    }
    return null;
  }

  @override
  Widget createDirectButtonChild(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: super.createDirectButtonChild(context),
        ),
        const SizedBox(
          width: 10,
        ),
        createPopupIcon(context),
      ],
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a [FontAwesomeIcons.caretDown] icon which, when pressed, opens a menu showing the [popupItems].
  Widget createPopupIcon(BuildContext context) {
    return InkWell(
      canRequestFocus: false,
      enableFeedback: model.isEnabled,
      onTap: () => openMenu(context),
      child: Container(
        alignment: Alignment.center,
        width: 24,
        child: FaIcon(
          FontAwesomeIcons.caretDown,
          size: 24.0,
          color: model.createTextStyle().color,
        ),
      ),
    );
  }

  /// Opens the menu via [showMenu] with all the [popupItems].
  void openMenu(BuildContext context) {
    if (popupItems.isNotEmpty) {
      // Copied from [PopupMenuButtonState]
      final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
      final RenderBox button = context.findRenderObject()! as RenderBox;
      final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      showMenu<String>(
        context: context,
        items: popupItems,
        position: position,
        shape: popupMenuTheme.shape,
        color: popupMenuTheme.color,
      ).then<void>(
        (String? newValue) {
          if (newValue != null) {
            onItemPress?.call(newValue);
          }
        },
      );
    }
  }
}
