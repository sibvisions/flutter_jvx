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
import '../../../../util/badge_util.dart';
import '../../../../util/jvx_colors.dart';
import '../../../state/app_style.dart';
import '../../menu.dart';

class GridMenuItem extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Callback for menu item
  final MenuItemCallback onClick;

  /// Model of this item
  final MenuItemModel menuItemModel;

  /// The text color of tile
  final Color? tileColor;

  /// The background color of tile
  final Color? tileBackground;

  /// The text color of title
  final Color? tileTitleColor;

  /// The background color of title
  final Color? tileTitleBackground;

  /// Border radius
  final double? borderRadius;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const GridMenuItem({
    super.key,
    required this.menuItemModel,
    required this.onClick,
    this.borderRadius,
    this.tileColor,
    this.tileBackground,
    this.tileTitleColor,
    this.tileTitleBackground
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {

    Widget wItem = Container(
      color: tileBackground ?? Colors.black.withAlpha(Color.getAlphaFromOpacity(0.1)),
      child: MenuItemModel.getImage(
        context,
        pMenuItemModel: menuItemModel,
        pSize: 72,
        pColor: tileColor ?? (JVxColors.isLightTheme(context) ? Colors.white : Colors.white70),
      ),
    );

    BadgeConfig badgeConfig = BadgeConfig.fromApplicationParameter(menuItemModel.className);
    //set defaults if not set
    badgeConfig.alignment ??= Alignment.bottomRight;
    badgeConfig.offset ??= Offset(-20, -20);

    wItem = BadgeUtil.wrapWithBadge(context, wItem, badgeConfig, expand: true);

    ThemeData theme = Theme.of(context);

    Widget w = Material(
      color: tileBackground ?? ((JVxColors.isLight(theme) ? theme.colorScheme.primary : theme.canvasColor)
          .withAlpha(Color.getAlphaFromOpacity(double.parse(AppStyle.directOf(context).style(AppStyle.opacityMenu) ?? "1")))),
      child: InkWell(
        onTap: () => onClick(context, item: menuItemModel),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 25,
              child: Container(
                color: tileTitleBackground ?? Colors.black.withAlpha(Color.getAlphaFromOpacity(0.2)),
                padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: AutoSizeText(
                      menuItemModel.label,
                      style: TextStyle(
                        fontSize: 16,
                        color: tileTitleColor ?? tileColor ?? (JVxColors.isLightTheme(context) ? Colors.white : Colors.white70),
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
              child: wItem
            )
          ],
        ),
      ),
    );

    if (borderRadius != null) {
      w = ClipRRect(borderRadius: BorderRadiusGeometry.all(Radius.circular(borderRadius!)), child: w);
    }

    return w;
  }
}
