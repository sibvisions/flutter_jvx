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
import 'package:flutter/services.dart';

import '../../../flutter_ui.dart';
import '../../../mask/frame/frame.dart';
import '../../../mask/state/app_style.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../model/response/application_settings_response.dart';
import '../../../util/jvx_colors.dart';
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

  /// How much space an icon should take up in the text field.
  static const double iconAreaSize = 24;

  /// How much space the icon is itself
  static const double iconSize = 16;

  static const EdgeInsets MOBILE_PADDING = EdgeInsets.fromLTRB(10, 15, 10, 15);

  static const EdgeInsets WEBFRAME_PADDING = EdgeInsets.fromLTRB(10, 12, 10, 12);
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextInputType keyboardType;

  final FocusNode focusNode;

  final TextEditingController textController;

  final bool isMandatory;

  /// Additional input decorations not handled by the model.
  final InputDecoration inputDecoration;

  final List<TextInputFormatter>? inputFormatters;

  final bool hideClearIcon;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  EdgeInsets get contentPadding => Frame.isWebFrame() ? WEBFRAME_PADDING : MOBILE_PADDING;

  EdgeInsets get iconsPadding => const EdgeInsets.only(left: 5, right: 10);

  int? get minLines => null;

  int? get maxLines => 1;

  bool get isExpandend => false;

  bool get obscureText => false;

  String get obscuringCharacter => "•";

  bool get showSuffixIcon => true;

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
    this.inputDecoration = const InputDecoration(),
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
    ThemeData themeData = Theme.of(context);

    fillColor ??= themeData.inputDecorationTheme.fillColor ?? themeData.backgroundColor;

    focusNode.canRequestFocus = model.isFocusable;

    return TextField(
      controller: textController,
      decoration: inputDecoration.copyWith(
        enabled: model.isEnabled,
        hintText: model.placeholder,
        contentPadding: contentPadding,
        border: createBorder(FlTextBorderType.border),
        errorBorder: createBorder(FlTextBorderType.errorBorder),
        enabledBorder: createBorder(FlTextBorderType.enabledBorder),
        focusedBorder: createBorder(FlTextBorderType.focusedBorder),
        disabledBorder: createBorder(FlTextBorderType.disabledBorder),
        focusedErrorBorder: createBorder(FlTextBorderType.focusedBorder),
        suffixIcon: createSuffixIcon(),
        suffixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
        suffix: createSuffix(),
        fillColor: fillColor,
        filled: true,
        isDense: Frame.isWebFrame(),
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

  /// Creates the clear icon at the end of a textfield.
  Widget? createClearIcon([bool pForce = false]) {
    if ((textController.text.isEmpty || hideClearIcon || !model.isEditable || !model.isEnabled) && !pForce) {
      return null;
    }

    bool isLight = Theme.of(FlutterUI.getCurrentContext()!).brightness == Brightness.light;

    return InkWell(
      canRequestFocus: false,
      onTap: () {
        if (!model.isReadOnly) {
          textController.clear();
          if (focusNode.hasFocus) {
            valueChanged("");
          } else {
            endEditing("");
          }
        }
      },
      child: SizedBox(
        width: iconAreaSize,
        height: iconAreaSize,
        child: Center(
          child: Icon(
            Icons.clear,
            size: iconSize,
            color: isLight ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
          ),
        ),
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

    return icons;
  }

  /// Constructs a single widget to show at the end of a textfield, unifying all suffixIconItems.
  Widget? createSuffixIcon() {
    if (!showSuffixIcon) {
      return null;
    }

    List<Widget> suffixIconItems = createSuffixIconItems();

    // Just insert a center and voilá, textfield is expanding without
    // setting "expanding" to true.
    suffixIconItems.add(const Center());

    /// -4 => The editable text inside a textfield is somehow 8 pixels bigger.
    double paddingAdjustment = 0;
    if (Frame.isWebFrame()) {
      paddingAdjustment = -4 - ((iconAreaSize - iconSize) / 2);
    }

    return Container(
      padding: iconsPadding.copyWith(
          top: contentPadding.top + paddingAdjustment, bottom: contentPadding.bottom + paddingAdjustment),
      child: Row(
        crossAxisAlignment: iconCrossAxisAlignment,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: suffixIconItems,
      ),
    );
  }

  Widget? createSuffix() {
    return null;
  }

  InputBorder? createBorder(FlTextBorderType pBorderType) {
    switch (pBorderType) {
      case FlTextBorderType.border:
      case FlTextBorderType.errorBorder:
      case FlTextBorderType.enabledBorder:
        return OutlineInputBorder(
          borderSide: BorderSide(
            color: model.isBorderVisible ? JVxColors.COMPONENT_BORDER : Colors.transparent,
          ),
        );

      case FlTextBorderType.disabledBorder:
        return OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: model.isBorderVisible ? JVxColors.COMPONENT_DISABLED : Colors.transparent,
          ),
        );
      case FlTextBorderType.focusedBorder:
      case FlTextBorderType.focusedErrorBorder:
        return model.isBorderVisible
            ? null
            : const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent));
    }
  }

  /// Returns all extra paddings this text field has in sum apart from the text size itself.
  double extraWidthPaddings() {
    int iconAmount = createSuffixIconItems(true).length;

    double width = (iconAreaSize * iconAmount);
    width += iconsPadding.horizontal;
    width += contentPadding.horizontal;

    return width;
  }
}
