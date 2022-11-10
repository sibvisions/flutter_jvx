import 'package:flutter/widgets.dart';

import '../../../model/response/device_status_response.dart';
import '../menu.dart';
import 'widget/app_menu_list_group.dart';

class AppMenuListGrouped extends Menu {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final LayoutMode? layoutMode;

  /// Text style for menu items
  final TextStyle? textStyle;

  /// Text color for menu header
  final Color? headerColor;

  final bool? decreasedDensity;
  final bool? useAlternativeLabel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuListGrouped({
    super.key,
    required super.menuModel,
    required super.onClick,
    this.layoutMode,
    this.textStyle,
    this.headerColor,
    this.decreasedDensity,
    this.useAlternativeLabel,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: menuModel.menuGroups
          .map(
            (e) => AppMenuListGroup(
              menuGroupModel: e,
              onClick: onClick,
              layoutMode: layoutMode,
              textStyle: textStyle,
              headerColor: headerColor,
              decreasedDensity: decreasedDensity,
              useAlternativeLabel: useAlternativeLabel,
            ),
          )
          .toList(),
    );
  }
}
