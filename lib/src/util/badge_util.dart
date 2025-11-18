/*
 * Copyright 2025 SIB Visions GmbH
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
import 'package:badges/badges.dart' as badges;

import '../service/ui/i_ui_service.dart';
import 'extensions/string_extensions.dart';
import 'parse_util.dart';

abstract class BadgeUtil {

  /// Wraps given [child] widgets with a badge if [config] is available. At least the text/label must be set.
  static Widget wrapWithBadge(BuildContext context, Widget child, BadgeConfig? config, {bool? expand = false, EdgeInsets? padding}) {

    if (config == null || config.text == null) {
      return child;
    }

    AlignmentGeometry badgeAlign = config.alignment ?? AlignmentGeometry.topRight;
    badges.BadgePosition? badgePosition;

    Offset? offset;

    double top = (padding?.top ?? 0) / 2;
    double bottom = (padding?.bottom ?? 0) / 2;
    double left = (padding?.left ?? 0) / 2;
    double right = (padding?.right ?? 0) / 2;

    if (config.offset != null) {
      top += config.offset!.dy;
      bottom -= config.offset!.dy;

      left -= config.offset!.dx;
      right += config.offset!.dx;
    }

    double borderSize = config.borderSize ?? 0;

    switch (badgeAlign) {
      case AlignmentGeometry.topRight:
        offset = Offset(5 + right, -7 - top);
        badgePosition = badges.BadgePosition.topEnd(top: offset.dy - 4 - borderSize, end: -offset.dx -2 - borderSize);
        break;
      case AlignmentGeometry.centerRight:
        offset = Offset(5 + right, -7);
        break;
      case AlignmentGeometry.topCenter:
        offset = Offset(0, -7- top);
        break;
      case AlignmentGeometry.center:
        offset = Offset(0, -7);
        badgePosition = badges.BadgePosition.center();
        break;
      case AlignmentGeometry.topLeft:
        offset = Offset(-8 - left, -7 - top);
        badgePosition = badges.BadgePosition.topStart(top: offset.dy - 4 - borderSize, start: offset.dx - borderSize);
        break;
      case AlignmentGeometry.centerLeft:
        offset = Offset(-8 - left, -7);
        break;
      case AlignmentGeometry.bottomLeft:
        offset = Offset(-8 - left, -9 + bottom);
        badgePosition = badges.BadgePosition.bottomStart(bottom: -11 - bottom - borderSize, start: offset.dx - borderSize);
        break;
      case AlignmentGeometry.bottomCenter:
        offset = Offset(0, -9 + bottom);
        break;
      case AlignmentGeometry.bottomRight:
        offset = Offset(5 + right, -9 + bottom);
        badgePosition = badges.BadgePosition.bottomEnd(bottom: offset.dy - 2 - borderSize, end: -offset.dx - 2 - borderSize);
        break;
    }

    Widget w = child;

    if (expand == true) {
      w = Stack(fit: StackFit.expand, children: [w]);
    }

    String badgeLabel = config.text!;

    int? count = int.tryParse(badgeLabel);

    if (count != null) {
      if (count > 999) {
        badgeLabel = "999+";
      }
    }

    BadgeThemeData theme = BadgeTheme.of(context);
    ThemeData themeDefault = Theme.of(context);

    badges.BadgeShape badgeShape;
    if (badgeLabel.length > 2) {
      badgeShape = badges.BadgeShape.square;
    }
    else {
      badgeShape = badges.BadgeShape.circle;
    }

    BorderSide borderSide;

    if (config.borderSize != null && config.borderColor != null) {
      borderSide = BorderSide(color: config.borderColor!, width: config.borderSize!);
    }
    else {
      borderSide = BorderSide.none;
    }

    w = badges.Badge(
      badgeContent: Text(badgeLabel,
        style: (theme.textStyle ?? themeDefault.textTheme.labelSmall ?? TextStyle()).copyWith(
          color: config.textColor ?? theme.textColor ?? themeDefault.colorScheme.onError,
          fontSize: config.fontSize ?? theme.smallSize ?? themeDefault.textTheme.labelSmall?.fontSize
        )
      ),
      position: badgePosition,
      showBadge: true,
      badgeAnimation: badges.BadgeAnimation.scale(),
      badgeStyle: badges.BadgeStyle(
        shape: badgeShape,
        borderRadius: BorderRadius.circular(12),
        borderSide: borderSide,
        badgeColor: config.color ?? theme.backgroundColor ?? themeDefault.colorScheme.error,
        padding: EdgeInsetsGeometry.all((config.paddingGap ?? 6) + borderSize)
      ),
      child: w);

    if (expand != true) {
      if (child is Image) {
        w = Align(child: w);
      }
    }

    return w;
  }

}

class BadgeConfig {

  /// This style defines the badge label
  static const String STYLE_BADGE_TEXT = "f_badge_text_";
  /// This style configures the badge border (size_color)
  static const String STYLE_BADGE_BORDER = "f_badge_border_";
  /// This style configures the badge color
  static const String STYLE_BADGE_COLOR = "f_badge_color_";
  /// This style configures the text color
  static const String STYLE_BADGE_TEXTCOLOR = "f_badge_textcolor_";
  /// This style configures the badge alignment
  static const String STYLE_BADGE_ALIGN = "f_badge_align_";
  /// This style configures the badge offset (x_y)
  static const String STYLE_BADGE_OFFSET = "f_badge_offset_";

  /// the badge text if not numeric
  String? text;

  /// the badge alignment
  AlignmentGeometry? alignment;

  /// The color of the badge
  Color? color;

  /// The text color of the badge
  Color? textColor;

  /// The color of the badge border
  Color? borderColor;

  /// The badge offset
  Offset? offset;

  /// The size of the badge border
  double? borderSize;

  /// The size of the font
  double? fontSize;

  /// The default padding gap
  int? paddingGap;

  /// Creates a new config from styles
  BadgeConfig._(Set<String> pStyles) {
    if (pStyles.isNotEmpty) {
      String? styleDef;

      for (int i = 0; i < pStyles.length; i++) {
        styleDef = pStyles.elementAt(i);

        if (styleDef.startsWith(STYLE_BADGE_TEXT)) {
          styleDef = styleDef.substring(STYLE_BADGE_TEXT.length);

          text = styleDef;
        }
        else if (styleDef.startsWith(STYLE_BADGE_ALIGN)) {
          styleDef = styleDef.substring(STYLE_BADGE_ALIGN.length);

          alignment = styleDef.toAlignment();
        }
        else if (styleDef.startsWith(STYLE_BADGE_COLOR)) {
          styleDef = styleDef.substring(STYLE_BADGE_COLOR.length);

          color = ParseUtil.parseColor(styleDef);
        }
        else if (styleDef.startsWith(STYLE_BADGE_TEXTCOLOR)) {
          styleDef = styleDef.substring(STYLE_BADGE_TEXTCOLOR.length);

          textColor = ParseUtil.parseColor(styleDef);
        }
        else if (styleDef.startsWith(STYLE_BADGE_OFFSET)) {
          styleDef = styleDef.substring(STYLE_BADGE_OFFSET.length);

          List<String> parts = styleDef.split("_");

          double? x;
          double? y;

          if (parts.isNotEmpty) {
            x = double.tryParse(parts[0]);

            if (parts.length > 1) {
              y = double.tryParse(parts[1]);
            }
          }

          if (x != null || y != null) {
            offset = Offset(x ?? 0, y ?? 0);
          }
        }
        else if (styleDef.startsWith(STYLE_BADGE_BORDER)) {
          styleDef = styleDef.substring(STYLE_BADGE_BORDER.length);

          List<String> parts = styleDef.split("_");

          if (parts.length == 2) {
            borderSize = double.tryParse(parts[0]);
            borderColor = ParseUtil.parseColor(parts[1]);
          }
        }
      }
    }
  }

  /// Creates the configuration with the definition of an application parameter. The [className] should be the classname
  /// of a screen.
  factory BadgeConfig.fromApplicationParameter(String? className) {
    String? definition;

    if (className != null) {
      definition = IUiService().applicationParameters.value.parameters["screenbadge.$className"];
    }

    return BadgeConfig.fromText(definition);
  }

  /// Creates the configuration from a string.
  factory BadgeConfig.fromText(String? text) {
    Set<String> set = Set.of(text?.split(",") ?? []);

    //if there's only text and no valid style definition, use the text
    if (set.length == 1 && !set.first.startsWith("f_")) {
      set.clear();
      set.add("${BadgeConfig.STYLE_BADGE_TEXT}${text!}");
    }

    return BadgeConfig._(set);
  }

  /// Creates the configuration with [style] definitions.
  factory BadgeConfig.fromStyle(Set<String> style) {
    return BadgeConfig._(style);
  }

}
