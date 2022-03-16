import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppMenuGridHeader extends SliverPersistentHeaderDelegate {

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

  AppMenuGridHeader({
    required this.height,
    required this.headerText
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
    return Container(
      color: Theme.of(context).bottomAppBarColor,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: ListTile(
            title: Text(
              headerText,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Theme.of(context).textTheme.headline5?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          )
      ),
    );
  }
}