import 'package:flutter/material.dart';

import '../../../../../util/constants/i_color.dart';
import '../../../../model/response/device_status_response.dart';

class AppMenuGridHeader extends SliverPersistentHeaderDelegate {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Text to be displayed
  final String headerText;

  /// Text color
  final Color? headerColor;

  /// The height of the header
  final double height;

  /// Text style for inner widgets
  final TextStyle? textStyle;

  final LayoutMode? layoutMode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuGridHeader({
    required this.height,
    this.headerColor,
    required this.headerText,
    this.textStyle,
    this.layoutMode,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    Widget child;
    if (layoutMode == LayoutMode.Small) {
      child = Divider(
        color: headerColor ?? ListTileTheme.of(context).iconColor,
        height: 48,
        indent: 15,
        endIndent: 15,
        thickness: 5,
      );
    } else {
      child = ListTile(
        // Triggers https://github.com/flutter/flutter/issues/78748
        // dense: true,
        contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        textColor: headerColor,
        title: Text(
          headerText,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ).merge(textStyle),
        ),
      );
    }

    return Container(
      // Idk why, but tileColor doesn't seem to do the trick, when scrolling.
      color: ListTileTheme.of(context).tileColor != null
          ? IColor.lighten(ListTileTheme.of(context).tileColor!)
          : Theme.of(context).bottomAppBarColor,
      child: child,
    );
  }
}
