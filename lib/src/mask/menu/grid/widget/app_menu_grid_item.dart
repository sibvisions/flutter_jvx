import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../../services.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../app_menu.dart';

class AppMenuGridItem extends StatelessWidget {
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

  const AppMenuGridItem({
    Key? key,
    required this.menuItemModel,
    required this.onClick,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClick(pScreenLongName: menuItemModel.screenLongName, pUiService: IUiService(), pContext: context),
      child: Ink(
        color: Theme.of(context).primaryColor.withOpacity(IConfigService().getOpacityMenu()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 25,
              child: Container(
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
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 75,
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: MenuItemModel.getImage(
                  pContext: context,
                  pMenuItemModel: menuItemModel,
                  pSize: 72,
                  pColor: Theme.of(context).cardColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
