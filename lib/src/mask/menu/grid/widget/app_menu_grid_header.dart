import 'package:flutter/material.dart';

import '../../../../../util/constants/i_color.dart';

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppMenuGridHeader({
    required this.height,
    this.headerColor,
    required this.headerText,
    this.textStyle,
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
    return ListTile(
      // Triggers https://github.com/flutter/flutter/issues/78748
      // dense: true,
      contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      textColor: headerColor,
      tileColor: ListTileTheme.of(context).tileColor != null
          ? IColor.lighten(ListTileTheme.of(context).tileColor!)
          : Theme.of(context).bottomAppBarColor,
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
}
