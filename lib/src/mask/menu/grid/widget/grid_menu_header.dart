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

import '../../../../util/jvx_colors.dart';

class GridMenuHeader extends SliverPersistentHeaderDelegate {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Text to be displayed
  final String headerText;

  /// Text color
  final Color? headerColor;

  /// The height of the header
  final double height;

  /// The height for the extent
  double _height;

  /// Text style for inner widgets
  final TextStyle? textStyle;

  final bool embedded;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GridMenuHeader({
    required this.height,
    this.headerColor,
    required this.headerText,
    this.textStyle,
    this.embedded = false,
  }) : _height = height;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(builder: (context, constraints) {
      Widget child;

      if (constraints.maxWidth <= 50) {
        _height = 9;

        child = SizedBox(
          height: _height,
          child: Padding(
            padding: EdgeInsets.only(left: embedded ? 15 : 12, right: embedded ? 15 : 12, top: 3, bottom: 3),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: headerColor ?? ListTileTheme.of(context).iconColor,
                borderRadius: BorderRadius.circular(2)
              )
            )
          )
        );
      } else {
        _height = height;

        child = ListTile(
          contentPadding: EdgeInsets.fromLTRB(embedded ? 15 : 12, 0, embedded ? 15 : 12, 0),
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
        // It seems that Sliver provides minHeight=0 as constraints but complains if height < maxHeight, so we force it here.
        // https://github.com/flutter/flutter/issues/78748
        height: _height,
        // Idk why, but tileColor doesn't seem to do the trick, when scrolling.
        color: ListTileTheme.of(context).tileColor != null
            ? JVxColors.lighten(ListTileTheme.of(context).tileColor!)
            : Theme.of(context).colorScheme.surface,
        child: child,
      );
    });
  }
}
