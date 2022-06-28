import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../util/font_awesome_util.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../app_menu.dart';

class AppMenuGridItem extends StatelessWidget with ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Callback for menu item
  final ButtonCallback onClick;

  /// Model of this item
  final MenuItemModel menuItemModel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppMenuGridItem({
    Key? key,
    required this.menuItemModel,
    required this.onClick,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick(componentId: menuItemModel.screenId);
      },
      child: Container(
        color: Theme.of(context).primaryColor.withOpacity(opacityMenu),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              color: Colors.black.withOpacity(0.2),
              padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Center(
                  child: AutoSizeText(
                    menuItemModel.label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    minFontSize: 16,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: _getImage(pContext: context),
              ),
            )
          ],
        ),
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _getImage({required BuildContext pContext}) {
    var iconColor = Theme.of(pContext).cardColor;

    Widget icon = CircleAvatar(
      backgroundColor: Colors.transparent,
      child: FaIcon(
        FontAwesomeIcons.clone,
        size: 72,
        color: iconColor,
      ),
    );

    // Server side images
    String? imageName = menuItemModel.image;
    if (imageName != null) {
      return CircleAvatar(
          backgroundColor: Colors.transparent,
          child: IFontAwesome.getFontAwesomeIcon(
            pText: imageName,
            pIconSize: 72,
            pColor: iconColor,
          ));
    }

    // Custom menu item
    Widget? imageIcon = menuItemModel.icon;
    if (imageIcon != null) {
      return imageIcon;
    }
    return icon;
  }
}
