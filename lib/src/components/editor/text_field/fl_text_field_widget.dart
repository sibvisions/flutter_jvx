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

import 'dart:math' hide log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../flutter_jvx.dart';
import '../../../mask/frame/frame.dart';
import '../../../model/layout/alignments.dart';

enum FlTextBorderType {
  border,
  errorBorder,
  enabledBorder,
  focusedBorder,
  disabledBorder,
  focusedErrorBorder,
}

class FlTextFieldWidget<T extends FlTextFieldModel> extends FlStatelessDataWidget<T, String> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The height of a text field.
  // ignore: non_constant_identifier_names
  static double get TEXT_FIELD_HEIGHT => JVxColors.componentHeight;

  /// The height of a text.
  // ignore: non_constant_identifier_names
  static double TEXT_HEIGHT(TextStyle pStyle) => ParseUtil.getTextHeight(text: "a", style: pStyle);

  /// The padding of a text field.
  // ignore: non_constant_identifier_names
  static EdgeInsets TEXT_FIELD_PADDING(TextStyle pStyle) {
    double verticalPadding = max(0, (TEXT_FIELD_HEIGHT - ParseUtil.getTextHeight(text: "a", style: pStyle)) / 2);

    return EdgeInsets.fromLTRB(10, verticalPadding, 0, verticalPadding);
  }

  /// How much space an icon should take up in the text field.
  static const double iconAreaSize = 26;

  /// How much space the icon is itself
  static const double iconSize = 16;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextInputType keyboardType;

  final FocusNode focusNode;

  final TextEditingController textController;

  final bool isMandatory;

  final List<TextInputFormatter>? inputFormatters;

  final bool hideClearIcon;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  EdgeInsets get contentPadding {
    EdgeInsets padding = TEXT_FIELD_PADDING(model.createTextStyle());

    if (kIsWeb) {
      padding = padding + const EdgeInsets.only(top: 4, bottom: 4);
    }

    return padding;
  }

  EdgeInsets get iconsPadding {
    double verticalPadding = max(0, (TEXT_FIELD_HEIGHT - iconAreaSize) / 2);

    return EdgeInsets.fromLTRB(5, verticalPadding, 5, verticalPadding);
  }

  int? get minLines => null;

  int? get maxLines => 1;

  bool get isExpanded => false;

  bool get obscureText => false;

  String get obscuringCharacter => "•";

  bool get isMultiLine => keyboardType == TextInputType.multiline;

  CrossAxisAlignment get iconCrossAxisAlignment => CrossAxisAlignment.center;

  // The whitespace every icon has around it
  double get iconInnatePadding => ((iconAreaSize - TEXT_HEIGHT(model.createTextStyle())) / 2);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextFieldWidget({
    super.key,
    required super.model,
    required super.valueChanged,
    required super.endEditing,
    required this.focusNode,
    required this.textController,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.isMandatory = false,
    this.hideClearIcon = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Color? fillColor = model.background;

    if (fillColor == null && isMandatory) {
      ApplicationSettingsResponse applicationSettings = AppStyle.of(context).applicationSettings;
      if (JVxColors.isLightTheme(context)) {
        fillColor = applicationSettings.colors?.mandatoryBackground;
      } else {
        fillColor = applicationSettings.darkColors?.mandatoryBackground;
      }
    }

    fillColor ??= defaultBackground(context);

    if (fillColor != null && !model.isEditable) {
      fillColor = fillColor.withAlpha(Color.getAlphaFromOpacity(0.3));
    }

    focusNode.canRequestFocus = model.isFocusable;

    return TextField(
      controller: textController,
      decoration: InputDecoration(
        enabled: model.isEnabled,
        hintText: model.isBorderVisible ? null : model.placeholder,
        labelText: model.isBorderVisible ? model.placeholder : null,
        labelStyle: model.createTextStyle(
          pForeground: textController.text.isEmpty ? JVxColors.TEXT_HINT_LABEL_COLOR : null,
        ),
        hintStyle: model.createTextStyle(
          pForeground: textController.text.isEmpty ? JVxColors.TEXT_HINT_LABEL_COLOR : null,
        ),
        contentPadding: contentPadding,
        border: createBorder(FlTextBorderType.border),
        errorBorder: createBorder(FlTextBorderType.errorBorder),
        enabledBorder: createBorder(FlTextBorderType.enabledBorder),
        focusedBorder: createBorder(FlTextBorderType.focusedBorder),
        disabledBorder: createBorder(FlTextBorderType.disabledBorder),
        focusedErrorBorder: createBorder(FlTextBorderType.focusedBorder),
        suffixIcon: createSuffixIcon(context),
        suffixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 0),
        prefixIcon: createPrefixIcon(context),
        prefixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 0),
        fillColor: fillColor,
        filled: true,
        isDense: true,
      ),
      textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
      textAlignVertical: VerticalAlignmentE.toTextAlign(model.verticalAlignment),
      readOnly: model.isReadOnly,
      style: model.createTextStyle(),
      onChanged: valueChanged,
      onEditingComplete: focusNode.unfocus,
      expands: isExpanded,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      obscuringCharacter: obscuringCharacter,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The default background color of a text field.
  static Color? defaultBackground(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return themeData.inputDecorationTheme.fillColor ?? themeData.colorScheme.surface;
  }

  /// Creates the clear icon at the end of a Text field.
  Widget? createClearIcon([BuildContext? context, bool force = false]) {
    if ((textController.text.isEmpty ||
            hideClearIcon ||
            !model.isEditable ||
            !model.isEnabled ||
            model.hideClearIcon) &&
        !force) {
      return null;
    }

    return InkWell(
      canRequestFocus: false,
      onTap: () {
        if (!model.isReadOnly) {
          if (focusNode.hasFocus) {
            valueChanged("");
            textController.clear();
          } else {
            endEditing("");
          }
        }
      },
      child: createEmbeddableIcon(context, Icons.clear),
    );
  }

  Widget createIcon(BuildContext? context, String imageDefinition, [Color? color, Color? colorDarkMode]) {
    Color color_ = color ?? JVxColors.COMPONENT_DISABLED;
    Color colorDarkMode_ = colorDarkMode ?? color ?? JVxColors.COMPONENT_DISABLED_LIGHTER;

    return _wrapIcon(ImageLoader.loadImage(imageDefinition, color: JVxColors.isLightTheme(context) ? color_ : colorDarkMode_));
  }

  Widget _wrapIcon(Widget icon) {
    return SizedBox(
      width: iconAreaSize,
      height: iconAreaSize,
      child: Center(
        child: icon,
      ),
    );
  }

  Widget createEmbeddableIcon(BuildContext? context, IconData icon) {
    Widget ico;

    if (icon.fontFamily == FontAwesomeIcons.plus.fontFamily) {
      ico = FaIcon(
          icon,
          size: iconSize,
          color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER
      );
    }
    else {
      //should work with any icon data
      ico = Icon(
          icon,
          size: iconSize,
          color: JVxColors.isLightTheme(context) ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER
      );
    }

    return _wrapIcon(ico);
  }

  /// Wraps the suf/pre-fix icon items with a container.
  Widget? _createXFixWidget(List<Widget> iconItems) {
    if (iconItems.isEmpty) {
      return null;
    }

    return Container(
      padding: iconsPadding,
      child: Row(
        crossAxisAlignment: iconCrossAxisAlignment,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: iconItems,
      ),
    );
  }

  /// Creates a list of widgets to show at the end of a Text field.
  List<Widget> createSuffixIconItems([BuildContext? context, bool forceAll = false]) {
    List<Widget> icons = [];

    Widget? clearIcon = createClearIcon(context, forceAll);
    if (clearIcon != null) {
      icons.add(clearIcon);
    }

    icons.addAll(_createIconsFromStyle(context, FlComponentModel.STYLE_SUFFIX_ICON));

    return icons;
  }

  /// Constructs a single widget to show at the end of a Text field, unifying all suffixIconItems.
  Widget? createSuffixIcon(BuildContext context) {
    List<Widget> iconItems = createSuffixIconItems(context);

    // Just insert a center and voila, Text field is expanding without
    // setting "expanding" to true.
    iconItems.add(const Center());

    return _createXFixWidget(iconItems);
  }

  /// Creates a list of widgets to show at the start of a Text field.
  List<Widget> createPrefixIconItems([BuildContext? context]) {
    return _createIconsFromStyle(context, FlComponentModel.STYLE_PREFIX_ICON);
  }

  /// Constructs a single widget to show at the end of a Text field, unifying all suffixIconItems.
  Widget? createPrefixIcon(BuildContext? context) {
    return _createXFixWidget(createPrefixIconItems(context));
  }

  InputBorder? createBorder(FlTextBorderType pBorderType) {
    Color borderEnabledColor;
    Color? borderFocusedColor;

    if (model.isBorderVisible) {
      borderEnabledColor = _extractBorderColor(FlComponentModel.STYLE_BORDER_COLOR) ?? JVxColors.COMPONENT_BORDER;
      borderFocusedColor = _extractBorderColor(FlComponentModel.STYLE_BORDER_COLOR_FOCUSED);
    } else {
      borderEnabledColor = Colors.transparent;
      borderFocusedColor = Colors.transparent;
    }

    switch (pBorderType) {
      case FlTextBorderType.border:
      case FlTextBorderType.errorBorder:
      case FlTextBorderType.enabledBorder:
        return OutlineInputBorder(
          borderSide: BorderSide(
            color: borderEnabledColor,
          ),
        );

      case FlTextBorderType.disabledBorder:
        return OutlineInputBorder(
          borderSide: BorderSide(
            color: model.isBorderVisible ? JVxColors.COMPONENT_DISABLED : Colors.transparent,
          ),
        );
      case FlTextBorderType.focusedBorder:
      case FlTextBorderType.focusedErrorBorder:
        return borderFocusedColor != null
            ? OutlineInputBorder(
                borderSide: BorderSide(
                  color: borderFocusedColor,
                ),
              )
            : null;
    }
  }

  /// Returns all extra paddings this text field has in sum apart from the text size itself.
  double extraWidthPaddings([BuildContext? context]) {
    int iconAmount = createSuffixIconItems(context, true).length + createPrefixIconItems(context).length;

    double width = (iconAreaSize * iconAmount);
    width += iconsPadding.horizontal;
    width += contentPadding.horizontal;

    return width;
  }

  Color? _extractBorderColor(String pStylePrefix) {
    List<String> styles = _extractStringsFromStyle(pStylePrefix);
    if (styles.isEmpty) {
      return null;
    } else {
      List<String> borderColorStrings = styles[0].split("_");

      Color? iconColor = ParseUtil.parseColor(borderColorStrings[0]);
      Color? iconColorDarkMode =
          borderColorStrings.length >= 2 ? ParseUtil.parseColor(borderColorStrings[1]) : null;

      return JVxColors.isLightTheme(FlutterUI.getCurrentContext()!) ? iconColor : iconColorDarkMode ?? iconColor;
    }
  }

  /// Extracts all [prefix]ed icons from the styles
  List<Widget> _createIconsFromStyle(BuildContext? context, String prefix) {
    List<String> listIconStrings = _extractStringsFromStyle(prefix);

    List<Widget> icons = [];

    for (String iconString in listIconStrings) {
      List<String> iconParts = iconString.split("_");
      String iconName = iconParts[0];

      if (iconName.isNotEmpty) {
        //FontAwesome is our default icon library
        if (!IconUtil.isFontIcon(iconName)) {
          iconName ="${IconUtil.PREFIX_FONT_AWESOME}.$iconName";
        }

        icons.add(createIcon(
            context,
            iconName,
            iconParts.length >= 2 ? ParseUtil.parseColor(iconParts[1]) : null,
            iconParts.length >= 3 ? ParseUtil.parseColor(iconParts[2]) : null));
      }
    }

    return icons;
  }

  /// Extracts all strings from the styles that start with the given [prefix].
  List<String> _extractStringsFromStyle(String prefix) {
    List<String> listStrings = [];

    for (String style in model.styles) {
      if (style.startsWith(prefix)) {
        listStrings.add(style.substring(prefix.length));
      }
    }

    return listStrings;
  }
}
