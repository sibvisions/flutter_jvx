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

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../model/menu/menu_group_model.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../menu.dart';
import 'grid_menu_header.dart';
import 'grid_menu_item.dart';

class GridMenuGroup extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Callback for menu items
  final MenuItemCallback onClick;

  /// Model of this group
  final MenuGroupModel menuGroupModel;

  final EdgeInsets? padding;

  final Color? groupColor;
  final Color? groupBackground;
  final Color? tileColor;
  final Color? tileBackground;
  final Color? tileTitleColor;
  final Color? tileTitleBackground;

  final bool sticky;

  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? borderRadius;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const GridMenuGroup({
    super.key,
    required this.menuGroupModel,
    required this.onClick,
    required this.sticky,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    this.maxCrossAxisExtent = 210.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.borderRadius,
    this.groupColor,
    this.groupBackground,
    this.tileColor,
    this.tileBackground,
    this.tileTitleColor,
    this.tileTitleBackground
  });

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPersistentHeader(
          pinned: sticky,
          delegate: GridMenuHeader(
            headerText: menuGroupModel.name,
            height: 48,
            color: groupColor,
            background: groupBackground
          )),
        buildGrid(
          context,
          menuGroupModel.items,
          onClick,
          maxCrossAxisExtent,
          mainAxisSpacing,
          crossAxisSpacing,
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

  static Widget buildGrid(
    BuildContext context,
    List<MenuItemModel> items,
    MenuItemCallback onClick,
    double maxCrossAxisExtent,
    double mainAxisSpacing,
    double crossAxisSpacing,
    double childAspectRatio,
    EdgeInsets? padding,
    double? borderRadius,
    Color? tileColor,
    Color? tileBackground,
    Color? tileTitleColor,
    Color? tileTitleBackground
  ) {
    double? spacing;

    if (padding != null) {
      spacing = max(padding.left, padding.right);
    }

    Widget w = SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: spacing ?? mainAxisSpacing,
        crossAxisSpacing: spacing ?? crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildListDelegate.fixed(
        items.map((e) => GridMenuItem(
          menuItemModel: e,
          onClick: onClick,
          borderRadius: borderRadius,
          tileColor: tileColor,
          tileBackground: tileBackground,
          tileTitleColor: tileTitleColor,
          tileTitleBackground: tileTitleBackground,
        )).toList(),
      ),
    );

    if (padding != null) {
      w = SliverPadding(
        padding: EdgeInsetsGeometry.fromLTRB(
          spacing ?? 0,
          padding.top,
          spacing ?? 0,
          padding.bottom
        ),
        sliver: w
      );
    }

    return w;
  }
}
