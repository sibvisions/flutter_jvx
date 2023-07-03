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

import '../../../flutter_ui.dart';
import '../../../mask/frame/frame.dart';
import '../../../mask/state/app_style.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../model/response/application_settings_response.dart';
import '../../../util/font_awesome_util.dart';
import '../../../util/jvx_colors.dart';
import '../../../util/parse_util.dart';
import '../../base_wrapper/fl_stateless_data_widget.dart';

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

  /// The height of a mobile text field.
  static const double MOBILE_HEIGHT = kMinInteractiveDimension;

  /// The height of a web frame text field.
  static const double WEBFRAME_HEIGHT = 32;

  /// The height of a text field.
  // ignore: non_constant_identifier_names
  static double get TEXT_FIELD_HEIGHT => Frame.isWebFrame() ? WEBFRAME_HEIGHT : MOBILE_HEIGHT;

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

  bool get isExpandend => false;

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
      if (Theme.of(context).brightness == Brightness.light) {
        fillColor = applicationSettings.colors?.mandatoryBackground;
      } else {
        fillColor = applicationSettings.darkColors?.mandatoryBackground;
      }
    }
    fillColor ??= defaultBackground(context);

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
        suffixIcon: createSuffixIcon(),
        suffixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 0),
        prefixIcon: createPrefixIcon(),
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
      expands: isExpandend,
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
    return themeData.inputDecorationTheme.fillColor ?? themeData.colorScheme.background;
  }

  /// Creates the clear icon at the end of a textfield.
  Widget? createClearIcon([bool pForce = false]) {
    if ((textController.text.isEmpty ||
            hideClearIcon ||
            !model.isEditable ||
            !model.isEnabled ||
            model.hideClearIcon) &&
        !pForce) {
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
      child: createBaseIcon(
        Icons.clear,
      ),
    );
  }

  Widget createBaseIcon(IconData pIcon, [Color? pColor, Color? pColorDarkMode]) {
    Color iconColor = pColor ?? JVxColors.COMPONENT_DISABLED;
    Color iconColorDarkMode = pColorDarkMode ?? pColor ?? JVxColors.COMPONENT_DISABLED_LIGHTER;

    bool isLight = Theme.of(FlutterUI.getCurrentContext()!).brightness == Brightness.light;

    return SizedBox(
      width: iconAreaSize,
      height: iconAreaSize,
      child: Center(
        child: FaIcon(
          pIcon,
          size: iconSize,
          color: isLight ? iconColor : iconColorDarkMode,
        ),
      ),
    );
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

  /// Creates a list of widgets to show at the end of a textfield.
  List<Widget> createSuffixIconItems([bool pForceAll = false]) {
    List<Widget> icons = [];

    Widget? clearIcon = createClearIcon(pForceAll);
    if (clearIcon != null) {
      icons.add(clearIcon);
    }

    icons.addAll(_createIconsFromStyle(FlComponentModel.SUFFIX_ICON_STYLE));

    return icons;
  }

  /// Constructs a single widget to show at the end of a textfield, unifying all suffixIconItems.
  Widget? createSuffixIcon() {
    List<Widget> iconItems = createSuffixIconItems();

    // Just insert a center and voilá, textfield is expanding without
    // setting "expanding" to true.
    iconItems.add(const Center());

    return _createXFixWidget(iconItems);
  }

  /// Creates a list of widgets to show at the start of a textfield.
  List<Widget> createPrefixIconItems() {
    return _createIconsFromStyle(FlComponentModel.PREFIX_ICON_STYLE);
  }

  /// Constructs a single widget to show at the end of a textfield, unifying all suffixIconItems.
  Widget? createPrefixIcon() {
    return _createXFixWidget(createPrefixIconItems());
  }

  InputBorder? createBorder(FlTextBorderType pBorderType) {
    Color borderEnabledColor;
    Color? borderFocusedColor;

    if (model.isBorderVisible) {
      borderEnabledColor = _extractBorderColor(FlComponentModel.BORDER_COLOR_STYLE) ?? JVxColors.COMPONENT_BORDER;
      borderFocusedColor = _extractBorderColor(FlComponentModel.BORDER_COLOR_FOCUSED_STYLE);
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
  double extraWidthPaddings() {
    int iconAmount = createSuffixIconItems(true).length + createPrefixIconItems().length;

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

      Color? iconColor = ParseUtil.parseServerColor(borderColorStrings[0]);
      Color? iconColorDarkMode =
          borderColorStrings.length >= 2 ? ParseUtil.parseServerColor(borderColorStrings[1]) : null;

      return Theme.of(FlutterUI.getCurrentContext()!).brightness == Brightness.light
          ? iconColor
          : iconColorDarkMode ?? iconColor;
    }
  }

  /// Extracts all prefix icons from the styles
  List<Widget> _createIconsFromStyle([String pIconStringPrefix = FlComponentModel.ICON_STYLE_STRING_PREFIX]) {
    List<String> listIconStrings = _extractStringsFromStyle(pIconStringPrefix);

    List<Widget> icons = [];

    for (String iconString in listIconStrings) {
      List<String> iconParts = iconString.split("_");
      String iconName = iconParts[0];

      if (iconName.isEmpty) {
        continue;
      }

      if (!FontAwesomeUtil.checkFontAwesome(iconName)) {
        iconName = "${FontAwesomeUtil.FONT_AWESOME_PREFIX}.$iconName";
      }

      Color? iconColor = iconParts.length >= 2 ? ParseUtil.parseServerColor(iconParts[1]) : null;
      Color? iconColorDarkMode = iconParts.length >= 3 ? ParseUtil.parseServerColor(iconParts[2]) : null;

      IconData iconData = FontAwesomeUtil.ICONS[iconName] ?? FontAwesomeIcons.circleQuestion;

      icons.add(createBaseIcon(iconData, iconColor, iconColorDarkMode));
    }

    return icons;
  }

  /// Extracts all strings from the styles that start with the given prefix.
  List<String> _extractStringsFromStyle(String pStylePrefix) {
    List<String> listStrings = [];

    for (String style in model.styles) {
      if (style.startsWith(pStylePrefix)) {
        listStrings.add(style.substring(pStylePrefix.length));
      }
    }

    return listStrings;
  }
}
