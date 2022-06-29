import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';

class AppMenuGridHeader extends SliverPersistentHeaderDelegate with ConfigServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Text to be displayed
  final String headerText;

  /// The height of the header
  final double height;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppMenuGridHeader({required this.height, required this.headerText});

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
    return Container(
      color: themeData.bottomAppBarColor.withOpacity(opacitySideMenu),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: ListTile(
            title: Text(
              headerText,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: themeData.textTheme.headline5?.color?.withOpacity(opacitySideMenu),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          )),
    );
  }
}
