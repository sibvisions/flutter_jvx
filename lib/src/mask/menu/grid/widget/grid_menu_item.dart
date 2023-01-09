/* 
 * Copyright 2022 SIB Visions GmbH
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

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../model/menu/menu_item_model.dart';
import '../../../../service/config/config_controller.dart';
import '../../menu_page.dart';

class GridMenuItem extends StatelessWidget {
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

  const GridMenuItem({
    super.key,
    required this.menuItemModel,
    required this.onClick,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClick(context, pScreenLongName: menuItemModel.screenLongName),
      child: Ink(
        color: Theme.of(context).primaryColor.withOpacity(ConfigController().getOpacityMenu()),
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
                  context,
                  pMenuItemModel: menuItemModel,
                  pSize: 72,
                  pColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
