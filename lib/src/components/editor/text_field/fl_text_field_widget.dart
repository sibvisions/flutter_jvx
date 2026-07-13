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

import 'dart:io';
import 'dart:math' hide log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../flutter_ui.dart';
import '../../../mask/state/app_style.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../model/response/application_settings_response.dart';
import '../../../util/icon_util.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/jvx_colors.dart';
import '../../../util/parse_util.dart';
import '../../../util/widget_util.dart';
import '../../../util/widgets/no_focus_node.dart';
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

  /// The height of a text field.
  // ignore: non_constant_identifier_names
  static double TEXT_FIELD_HEIGHT = JVxColors.componentHeight();

  /// The height of a text.
  // ignore: non_constant_identifier_names
  static double TEXT_HEIGHT(TextStyle style) => ParseUtil.getTextHeight(text: "a", style: style);

  /// The padding of a text field.
  // ignore: non_constant_identifier_names
  static EdgeInsets TEXT_FIELD_PADDING(TextStyle style) {
    double verticalPadding = max(0, (TEXT_FIELD_HEIGHT - ParseUtil.getTextHeight(text: "a", style: style)) / 2);

    return EdgeInsets.fromLTRB(10, verticalPadding, 0, verticalPadding);
  }

  /// How much space an icon should take up in the text field.
  static const double iconAreaSize = 26;

  /// How much space the icon is itself
  static const double iconSize = 16;

  static const double iconsPaddingHorizontal = 5;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextInputType keyboardType;

  final FocusNode focusNode;

  final TextEditingController textController;

  final bool isMandatory;

  final List<TextInputFormatter>? inputFormatters;

  final bool hideClearIcon;

  final bool showCopy;

  final bool hideSuffixIcons;

  final bool hidePrefixIcons;

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

    return EdgeInsets.fromLTRB(iconsPaddingHorizontal, verticalPadding, iconsPaddingHorizontal, verticalPadding);
  }

  int? get minLines => null;

  int? get maxLines => 1;

  bool get isExpanded => false;

  bool get obscureText => false;

  String get obscuringCharacter => "•";

  bool get isMultiLine => keyboardType == TextInputType.multiline;

  CrossAxisAlignment get iconCrossAxisAlignment => CrossAxisAlignment.center;

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
    this.showCopy = false,
    this.hideSuffixIcons = false,
    this.hidePrefixIcons = false
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return createTextField(context).field;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ({InputDecoration decoration, Widget? suffixIcon, int prefixCount, int suffixCount}) createInputDecoration(
    BuildContext context,
    {bool filled = true,
    bool showSuffixIcons = true,
    bool withSuffixArea = false,
    bool fillWithCenter = false
  }) {
    InputBorder? borDisabled = createBorder(context, FlTextBorderType.disabledBorder);

    ({Widget? widget, int count})? prefix = hidePrefixIcons ? null : _createPrefixIcon(context);
    ({Widget? widget, int count})? suffix = hideSuffixIcons ? null : _createSuffixIcon(context, withSuffixArea);

    Widget? wSuffix = showSuffixIcons ? suffix?.widget : null;

    //multiline needs Center to enlarge
    if (fillWithCenter && wSuffix == null) {
      wSuffix = Center();
    }

    return (decoration: InputDecoration(
      enabled: model.isEnabled,
      alignLabelWithHint: true,
      hintText: model.isBorderVisible ? null : model.placeholder,
      labelText: model.isBorderVisible ? model.placeholder : null,
      labelStyle: model.createTextStyle(
        foreground: textController.text.isEmpty ? JVxColors.TEXT_HINT_LABEL_COLOR : null,
      ),
      hintStyle: model.createTextStyle(
        foreground: textController.text.isEmpty ? JVxColors.TEXT_HINT_LABEL_COLOR : null,
      ),
      contentPadding: contentPadding,
      border: createBorder(context, FlTextBorderType.border),
      errorBorder: createBorder(context, FlTextBorderType.errorBorder),
      enabledBorder: model.isEditable ? createBorder(context, FlTextBorderType.enabledBorder) : borDisabled,
      focusedBorder: createBorder(context, FlTextBorderType.focusedBorder),
      disabledBorder: borDisabled,
      focusedErrorBorder: createBorder(context, FlTextBorderType.focusedErrorBorder),
      suffixIcon: wSuffix,
      suffixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 0),
      prefixIcon: prefix?.widget,
      prefixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 0),
      fillColor: getFillColor(context),
      filled: filled,
      isDense: true,
    ),
    suffixIcon: suffix?.widget,
    prefixCount: prefix?.count ?? 0,
    suffixCount: suffix?.count ?? 0);
  }

  ({TextField field, Widget? suffixIcon, int prefixCount, int suffixCount}) createTextField(
    BuildContext context,
    {bool noDecoration = false,
    bool withSuffixArea = false
    }) {

    var inputDecoration = createInputDecoration(context, withSuffixArea: withSuffixArea);

    return (
      field: TextField(
        controller: textController,
        decoration:
          noDecoration ?
            InputDecoration(
              filled: false,
              isDense: true,
              enabled: model.isEnabled,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: contentPadding.copyWith(left: 0, right: 0),
            )
          :
          inputDecoration.decoration,
        textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
        textAlignVertical: VerticalAlignmentE.toTextAlign(model.verticalAlignment),
        readOnly: model.isReadOnly,
        style: _createTextStyle(),
        onChanged: valueChanged,
        onEditingComplete: () => endEditing(textController.text, FlTextFieldModel.ENTER_KEY),
        expands: isExpanded,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: model.isEnabled ? keyboardType : TextInputType.none,
        focusNode: model.isEnabled ? focusNode : NoFocusNode(),
        contextMenuBuilder: model.isEnabled ? null : (context, editableTextState) {
          return SizedBox.shrink();
        },
        selectionControls: model.isEnabled ? null : EmptyTextSelectionControls(),
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        obscuringCharacter: obscuringCharacter,
      ),
      suffixIcon: inputDecoration.suffixIcon,
      prefixCount: inputDecoration.prefixCount,
      suffixCount: inputDecoration.suffixCount
    );
  }

  /// The default background color of a text field.
  static Color? defaultBackground(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return themeData.inputDecorationTheme.fillColor ?? themeData.colorScheme.surface;
  }

  Color? getFillColor(BuildContext context) {
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

    return fillColor;
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
            valueChanged("", true);
            textController.clear();
          } else {
            endEditing("", FlTextFieldModel.FOCUS_LOST);
          }
        }
      },
      child: createEmbeddableIcon(context, Icons.clear),
    );
  }

  Widget createIcon(BuildContext? context, String imageDefinition, [Color? color, Color? colorDarkMode]) {
    Color color_ = color ?? JVxColors.COMPONENT_DISABLED;
    Color colorDarkMode_ = colorDarkMode ?? color ?? JVxColors.COMPONENT_DISABLED_LIGHTER;

    if (imageDefinition == "default.progress") {
      return _wrapIcon(SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        )
      ));
    }
    else {
      return _wrapIcon(ImageLoader.loadImage(imageDefinition, color: JVxColors.isLightTheme(context) ? color_ : colorDarkMode_));
    }
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

  Icon _getIcon(BuildContext? context, IconData icon, [double? size]) {
    return Icon(
      icon,
      size: size ?? iconSize,
      color: getEmbeddableIconColor(context)
    );
  }

  Color getEmbeddableIconColor(BuildContext? context) {
    return JVxColors.isLightTheme(context) && model.background == null ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER;
  }

  Widget createEmbeddableIcon(BuildContext? context, IconData icon, [double? size]) {
    return _wrapIcon(_getIcon(context, icon, size));
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

    if (model.showCopy || showCopy) {
      if (!((textController.text.isEmpty || !model.isEnabled) && !forceAll)) {
        Widget iconCopy = InkWell(
          canRequestFocus: false,
          onTap: () async {
            try {
              await Clipboard.setData(ClipboardData(text: textController.text));

              if (kIsWeb || !Platform.isAndroid) {
                // ignore: use_build_context_synchronously
                WidgetUtil.showToast(context, "Copied to clipboard");
              }
            } catch (e) {
              // ignore: use_build_context_synchronously
              WidgetUtil.showToast(context, "Copy failed $e");
            }
          },
          child: createEmbeddableIcon(context, Icons.copy),
        );

        icons.add(iconCopy);
      }
    }

    icons.addAll(_createIconsFromStyle(context, FlComponentModel.STYLE_SUFFIX_ICON));

    return icons;
  }

  /// Constructs a single widget to show at the end of a Text field, unifying all suffixIconItems.
  ({Widget? widget, int count}) _createSuffixIcon(BuildContext context, bool force) {
    List<Widget> iconItems = createSuffixIconItems(context);

    int count = iconItems.length;

    if (iconItems.isEmpty && force) {
      iconItems.add(SizedBox(width: iconAreaSize));

      count = 0;
    }

    // Just insert a center and voila, Text field is expanding without
    // setting "expanding" to true.
    iconItems.add(const Center());

    return (widget: _createXFixWidget(iconItems), count: count);
  }

  /// Creates a list of widgets to show at the start of a Text field.
  List<Widget> createPrefixIconItems([BuildContext? context]) {
    return _createIconsFromStyle(context, FlComponentModel.STYLE_PREFIX_ICON);
  }

  /// Constructs a single widget to show at the end of a Text field, unifying all suffixIconItems.
  ({Widget? widget, int count}) _createPrefixIcon(BuildContext? context) {
    List<Widget> iconItems = createPrefixIconItems(context);

    int count = iconItems.length;

    //only center if icon is available and in multiline mode
    if (iconItems.isNotEmpty && maxLines == null) {
      iconItems.add(const Center());
    }

    return (widget: _createXFixWidget(iconItems), count: count);
  }

  InputBorder? createBorder(BuildContext context, FlTextBorderType borderType) {
    Color borderEnabledColor;
    Color? borderDisabledColor;
    Color? borderFocusedColor;

    if (model.isBorderVisible) {
      borderEnabledColor = _extractColor(FlComponentModel.STYLE_BORDER_COLOR) ?? JVxColors.COMPONENT_BORDER;
      borderFocusedColor = _extractColor(FlComponentModel.STYLE_BORDER_COLOR_FOCUSED);

      borderDisabledColor = _extractColor(FlComponentModel.STYLE_BORDER_COLOR_DISABLED);
    } else {
      borderEnabledColor = Colors.transparent;
      borderFocusedColor = Colors.transparent;
    }

    double editorBorderRadius = AppStyle.of(context).direct.editorBorderRadius();

    switch (borderType) {
      case FlTextBorderType.border:
      case FlTextBorderType.errorBorder:
      case FlTextBorderType.enabledBorder:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(editorBorderRadius),
          borderSide: BorderSide(
            color: borderEnabledColor,
          )
        );
      case FlTextBorderType.disabledBorder:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(editorBorderRadius),
          borderSide: BorderSide(
            color: model.isBorderVisible ? borderDisabledColor ?? JVxColors.COMPONENT_DISABLED : Colors.transparent,
          )
        );
      case FlTextBorderType.focusedBorder:
      case FlTextBorderType.focusedErrorBorder:
        return borderFocusedColor != null
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(editorBorderRadius),
                borderSide: BorderSide(
                  color: borderFocusedColor,
                )
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

  Color? _extractColor(String stylePrefix) {
    List<String> styles = _extractStringsFromStyle(stylePrefix);
    if (styles.isEmpty) {
      return null;
    } else {
      List<String> colorStrings = styles[0].split("_");

      Color? color = ParseUtil.parseColor(colorStrings[0]);
      Color? colorDarkMode =
          colorStrings.length >= 2 ? ParseUtil.parseColor(colorStrings[1]) : null;

      return JVxColors.isLightTheme(FlutterUI.getCurrentContext()!) ? color : colorDarkMode ?? color;
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
        if (!IconUtil.isFontIcon(iconName) && !iconName.contains(".")) {
          iconName ="${IconUtil.PREFIX_FONT_AWESOME}$iconName";
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

  TextStyle _createTextStyle() {
    Color? color;

    if (model.isEnabled) {
      color = _extractColor(FlComponentModel.STYLE_TEXT_COLOR);
    }
    else {
      color = _extractColor(FlComponentModel.STYLE_TEXT_COLOR_DISABLED);
    }

    return model.createTextStyle(foreground: color);
  }
}
