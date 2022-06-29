import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../model/component/button/fl_popup_menu_button_model.dart';
import '../fl_button_widget.dart';

class FlPopupMenuButtonWidget<T extends FlPopupMenuButtonModel> extends FlButtonWidget<T> {
  final Function(String)? onItemPress;

  final List<PopupMenuEntry<String>> popupItems;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  InteractiveInkFeatureFactory? get splashFactory => NoSplash.splashFactory;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlPopupMenuButtonWidget(
      {Key? key,
      required FlPopupMenuButtonModel model,
      required Function() onPress,
      this.onItemPress,
      required this.popupItems})
      : super(key: key, model: model, onPress: onPress);

  @override
  Widget createDirectButtonChild(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: super.createDirectButtonChild(context),
        ),
        createPopupIcon(context),
      ],
    );
  }

  Widget createPopupIcon(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onItemPress,
      itemBuilder: (_) => popupItems,
      padding: const EdgeInsets.only(bottom: 8),
      icon: FaIcon(
        FontAwesomeIcons.sortDown,
        color: themeData.buttonTheme.colorScheme?.onPrimary,
      ),
    );
  }
}
