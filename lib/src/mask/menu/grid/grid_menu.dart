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

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../../model/menu/menu_item_model.dart';
import '../menu.dart';
import 'widget/grid_menu_group.dart';

class GridMenu extends Menu {
  final Color? groupColor;
  final Color? groupBackground;
  final Color? tileColor;
  final Color? tileBackground;
  final Color? tileTitleColor;
  final Color? tileTitleBackground;

  final EdgeInsets? padding;

  final bool grouped;
  final bool sticky;
  final bool groupOnlyOnMultiple;

  final double maxCrossAxisExtent;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double childAspectRatio;
  final double? borderRadius;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const GridMenu({
    super.key,
    required super.menuModel,
    required super.onClick,
    required this.grouped,
    this.sticky = true,
    this.groupOnlyOnMultiple = false,
    this.maxCrossAxisExtent = 210.0,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.borderRadius,
    this.padding,
    this.groupColor,
    this.groupBackground,
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
    return CustomScrollView(
      slivers: grouped && (!groupOnlyOnMultiple || menuModel.menuGroups.length == 1)
          ? menuModel.menuGroups.mapIndexed((index, e) => GridMenuGroup(
              menuGroupModel: e,
              onClick: onClick,
              sticky: sticky,
              maxCrossAxisExtent: maxCrossAxisExtent,
              mainAxisSpacing: mainAxisSpacing ?? 1,
              crossAxisSpacing: crossAxisSpacing ?? 1,
              childAspectRatio: childAspectRatio,
              padding: index == menuModel.menuGroups.length - 1 ? _lastGroupPadding(context) : padding,
              borderRadius: borderRadius,
              groupBackground: groupBackground,
              groupColor: groupColor,
              tileColor: tileColor,
              tileBackground: tileBackground,
              tileTitleColor: tileTitleColor,
              tileTitleBackground: tileTitleBackground
            )).toList()
          : [
              GridMenuGroup.buildGrid(
                context,
                _getAllMenuItems(),
                onClick,
                maxCrossAxisExtent,
                mainAxisSpacing ?? 1,
                crossAxisSpacing ?? 1,
                childAspectRatio,
                padding,
                borderRadius,
                tileColor,
                tileBackground,
                tileTitleColor,
                tileTitleBackground
              )
            ],
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Get all menu items from each group
  List<MenuItemModel> _getAllMenuItems() {
    List<MenuItemModel> menuItems = [];

    for (var e in menuModel.menuGroups) {
      e.items.forEach(((e) => menuItems.add(e)));
    }

    return menuItems;
  }

  EdgeInsets? _lastGroupPadding(BuildContext context) {
    EdgeInsets insView = MediaQuery.of(context).viewPadding;

    if (insView.bottom > 0) {
      if (padding != null) {
        //enough space for safe-area -> don't change padding
        if (padding!.bottom < insView.bottom) {
          return padding!.copyWith(bottom: insView.bottom);
        }
      }
      else {
        return EdgeInsets.only(bottom: insView.bottom);
      }
    }

    return padding;
  }
}
