import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/menu/app_menu.dart';
import 'package:flutter_client/src/model/menu/menu_item_model.dart';
import 'package:flutter_client/util/font_awesome_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppMenuListItem extends StatelessWidget {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of this menu item
  final MenuItemModel model;
  /// Callback to be called when button is pressed
  final ButtonCallback onClick;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuListItem({
    Key? key,
    required this.model,
    required this.onClick
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 1, 0, 1),
        height: 76,
        color: Theme.of(context).primaryColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              width: 75,
              color: Colors.black.withOpacity(0.1),
              child: _getImage(pContext: context)
            ),
            Expanded(
                child: Container(
                    color: Colors.black.withOpacity(0.2),
                    padding: const EdgeInsets.fromLTRB(15, 3, 5, 3),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          model.label,
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        )))),
            Container(
                alignment: Alignment.center,
                width: 75,
                color: Colors.black.withOpacity(0.2),
                child: const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: Colors.white,
                )),
          ],
        ),
      ),
      onTap: () {onClick(componentId: model.componentId);},
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _getImage({required BuildContext pContext}){

    Widget icon = CircleAvatar(
      backgroundColor: Colors.transparent,
      child: FaIcon(
        FontAwesomeIcons.clone,
        size: 25,
        color: Theme.of(pContext).cardColor,
      ),
    );

    String? imageName = model.image;

    if(imageName != null) {
      icon = CircleAvatar(
          backgroundColor: Colors.transparent,
          child: IFontAwesome.getFontAwesomeIcon(
              pText: imageName,
              pIconSize: 25,
              pColor: Theme.of(pContext).cardColor
          )
      );
    }
    return icon;
  }
}
