import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../../../flutter_jvx.dart';
import '../../../../model/menu/menu_group_model.dart';
import '../../../../model/response/device_status_response.dart';
import '../../../drawer/web_menu.dart';
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ListMenuGroup({
    super.key,
    required this.onClick,
    required this.menuGroupModel,
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
          pinned: WebMenu.maybeOf(context) == null || layoutMode != LayoutMode.Small,
          delegate: GridMenuHeader(
            headerText: FlutterJVx.translate(menuGroupModel.name),
            headerColor: headerColor,
            height: 48,
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
