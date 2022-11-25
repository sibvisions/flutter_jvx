import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../components.dart';

class FlPopupMenuButtonWidget<T extends FlPopupMenuButtonModel> extends FlButtonWidget<T> {
  final Function(String)? onItemPress;

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
}
