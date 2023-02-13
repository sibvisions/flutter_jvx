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

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../../../model/menu/menu_item_model.dart';
import '../../../../routing/locations/work_screen_location.dart';
import '../../menu_page.dart';

class ListMenuItem extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of this menu item
  final MenuItemModel menuItemModel;

  /// Callback to be called when button is pressed
  final ButtonCallback onClick;

  /// Text style for inner widgets
  final TextStyle? textStyle;

  final bool decreasedDensity;
  final bool useAlternativeLabel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ListMenuItem({
    super.key,
    required this.menuItemModel,
    required this.onClick,
    this.textStyle,
    bool? decreasedDensity,
    bool? useAlternativeLabel,
  })  : decreasedDensity = decreasedDensity ?? false,
        useAlternativeLabel = useAlternativeLabel ?? false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    bool selected = _isSelected(context);

    var leading = MenuItemModel.getImage(
      context,
      pMenuItemModel: menuItemModel,
    );

    onTap() => onClick(context, item: menuItemModel);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 50) {
          var tileThemeData = ListTileTheme.of(context);
          return Material(
            color: selected ? tileThemeData.selectedTileColor : tileThemeData.tileColor,
            child: InkWell(
              onTap: onTap,
              child: IconTheme.merge(
                data: IconThemeData(color: selected ? tileThemeData.selectedColor : tileThemeData.iconColor),
                child: leading,
              ),
            ),
          );
        }

        return ListTile(
          selected: selected,
          visualDensity:
              decreasedDensity ? const VisualDensity(horizontal: 0, vertical: VisualDensity.minimumDensity) : null,
          leading: leading,
          title: Text(
            (useAlternativeLabel ? menuItemModel.alternativeLabel : null) ?? menuItemModel.label,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
          onTap: onTap,
        );
      },
    );
  }

  bool _isSelected(BuildContext context) {
    bool? selected;
    var pathSegments = (context.currentBeamLocation.state as BeamState).pathParameters;
    if (pathSegments.containsKey(WorkScreenLocation.workScreenNameKey)) {
      String navigationName = pathSegments[WorkScreenLocation.workScreenNameKey]!;
      selected ??= menuItemModel.navigationName == navigationName;
    }

    return selected ?? false;
  }
}
