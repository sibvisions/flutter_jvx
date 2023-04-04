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

import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/menu/menu_group_model.dart';
import '../../../../model/response/device_status_response.dart';
import '../../grid/widget/grid_menu_header.dart';
import '../../menu_page.dart';
import 'list_menu_item.dart';

class ListMenuGroup extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Callback for menu items
  final ButtonCallback onClick;

  /// Model of this group
  final MenuGroupModel menuGroupModel;
  final LayoutMode? layoutMode;

  /// Text style for menu items
  final TextStyle? textStyle;

  /// Text color for header
  final Color? headerColor;

  final bool? decreasedDensity;
  final bool? useAlternativeLabel;

  final bool sticky;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ListMenuGroup({
    super.key,
    required this.onClick,
    required this.menuGroupModel,
    required this.sticky,
    this.layoutMode,
    this.textStyle,
    this.headerColor,
    this.decreasedDensity,
    this.useAlternativeLabel,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> listGroupItems = [];

    for (int i = 0; i < menuGroupModel.items.length; i++) {
      if (i > 0) {
        listGroupItems.add(const Divider(
          height: 1,
        ));
      }

      listGroupItems.add(ListMenuItem(
        menuItemModel: menuGroupModel.items.elementAt(i),
        onClick: onClick,
        textStyle: textStyle,
        decreasedDensity: decreasedDensity,
        useAlternativeLabel: useAlternativeLabel,
      ));
    }

    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPersistentHeader(
          pinned: sticky,
          delegate: GridMenuHeader(
            headerText: FlutterUI.translate(menuGroupModel.name),
            headerColor: headerColor,
            height: (ListTileTheme.of(context).dense ?? false) ? 40 : 48,
            textStyle: textStyle,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            listGroupItems,
          ),
        ),
      ],
    );
  }
}
