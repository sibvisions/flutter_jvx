import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/mask/menu/app_menu.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/menu/menu_item_model.dart';
import 'package:flutter_client/util/font_awesome_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppMenuListItem extends StatelessWidget with ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of this menu item
  final MenuItemModel model;

  /// Callback to be called when button is pressed
  final ButtonCallback onClick;

  /// Background override color.
  final Color? backgroundOverride;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppMenuListItem({Key? key, required this.model, required this.onClick, this.backgroundOverride}) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.zero,
        height: 50,
        color: backgroundOverride ?? Theme.of(context).backgroundColor.withOpacity(opacitySideMenu),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(width: 75, child: _getImage(pContext: context)),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  model.label,
                  style: TextStyle(
                      fontSize: 16, color: Theme.of(context).colorScheme.onPrimary.withOpacity(opacitySideMenu)),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        onClick(componentId: model.screenId);
      },
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _getImage({required BuildContext pContext}) {
    Widget icon = CircleAvatar(
      backgroundColor: Colors.transparent,
      child: FaIcon(
        FontAwesomeIcons.clone,
        size: 25,
        color: Theme.of(pContext).primaryColor,
      ),
    );

    String? imageName = model.image;

    if (imageName != null) {
      icon = CircleAvatar(
        backgroundColor: Colors.transparent,
        child: IFontAwesome.getFontAwesomeIcon(
          pText: imageName,
          pIconSize: 25,
          pColor: Theme.of(pContext).primaryColor.withOpacity(opacitySideMenu),
        ),
      );
    }
    return icon;
  }
}
