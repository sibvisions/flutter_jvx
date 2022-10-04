import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../model/component/button/fl_popup_menu_button_model.dart';
import '../fl_button_widget.dart';

class FlPopupMenuButtonWidget<T extends FlPopupMenuButtonModel> extends FlButtonWidget<T> {
  final Function(String)? onItemPress;

  final List<PopupMenuEntry<String>> popupItems;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlPopupMenuButtonWidget(
      {super.key, required super.model, super.onPress, this.onItemPress, required this.popupItems});

  @override
  Widget createDirectButtonChild(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: super.createDirectButtonChild(context),
        ),
        const VerticalDivider(
          width: 5,
          color: Colors.transparent,
        ),
        createPopupIcon(context),
      ],
    );
  }

  @override
  Widget? getButtonChild() {
    if (model.labelModel.text.isNotEmpty && image != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: getCrossAxisAlignment(model.labelModel.verticalAlignment),
        textBaseline: TextBaseline.alphabetic,
        textDirection: TextDirection.ltr,
        children: <Widget>[image!, SizedBox(width: model.imageTextGap.toDouble()), Flexible(child: getTextWidget())],
      );
    } else if (model.labelModel.text.isNotEmpty) {
      return getTextWidget();
    } else if (image != null) {
      return image!;
    } else {
      return null;
    }
  }

  Widget createPopupIcon(BuildContext context) {
    return InkWell(
      onTap: () => openMenu(context),
      child: FaIcon(
        FontAwesomeIcons.caretDown,
        color: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
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
}
