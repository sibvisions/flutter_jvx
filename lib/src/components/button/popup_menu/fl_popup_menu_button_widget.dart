import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../components.dart';
import '../../../../util/constants/i_color.dart';

class FlPopupMenuButtonWidget<T extends FlPopupMenuButtonModel> extends FlButtonWidget<T> {
  final Function(String)? onItemPress;

  final List<PopupMenuEntry<String>> popupItems;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlPopupMenuButtonWidget({super.key, required super.model, this.onItemPress, required this.popupItems});

  @override
  Widget createDirectButtonChild(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: super.createDirectButtonChild(context),
        ),
        const VerticalDivider(
          width: 15,
          thickness: 1.0,
          color: IColorConstants.JVX_LIGHTER_BLACK,
        ),
        createPopupIcon(context),
      ],
    );
  }

  Widget createPopupIcon(BuildContext context) {
    return InkWell(
      enableFeedback: model.isEnabled,
      onTap: () => openMenu(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: FaIcon(
          FontAwesomeIcons.caretDown,
          color: model.createTextStyle().color,
        ),
      ),
    );
  }

  void openMenu(BuildContext context) {
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

    if (popupItems.isNotEmpty) {
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
