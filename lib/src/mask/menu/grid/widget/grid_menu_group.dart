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

import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/menu/menu_group_model.dart';
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

  final bool sticky;

  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const GridMenuGroup({
    super.key,
    required this.menuGroupModel,
    required this.onClick,
    required this.sticky,
    this.maxCrossAxisExtent = 210.0,
    this.mainAxisSpacing = 1.0,
    this.crossAxisSpacing = 1.0,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPersistentHeader(
            pinned: sticky,
            delegate: GridMenuHeader(
              headerText: FlutterUI.translate(menuGroupModel.name),
              height: 48,
            )),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          delegate: SliverChildListDelegate.fixed(
            menuGroupModel.items.map((e) => GridMenuItem(menuItemModel: e, onClick: onClick)).toList(),
          ),
        ),
      ],
    );
  }
}
