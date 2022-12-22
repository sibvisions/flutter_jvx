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

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../flutter_ui.dart';
import '../../../mask/frame/frame.dart';
import '../../../mask/state/app_style.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
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

  static const EdgeInsets MOBILE_PADDING = EdgeInsets.fromLTRB(10, 15, 10, 15);

  static const EdgeInsets WEBFRAME_PADDING = EdgeInsets.fromLTRB(10, 12, 10, 12);
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextInputType keyboardType;

  final FocusNode focusNode;

  final TextEditingController textController;

  final bool inTable;

  final bool isMandatory;

  /// Additional input decorations not handled by the model.
  final InputDecoration inputDecoration;

  final List<TextInputFormatter>? inputFormatters;

  final bool hideClearIcon;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double get clickableClearArea => 24;

  double get iconSize => 16;

  EdgeInsets get contentPadding => Frame.isWebFrame() ? WEBFRAME_PADDING : MOBILE_PADDING;

  EdgeInsets get iconPadding => const EdgeInsets.only(right: 5);

  EdgeInsets get iconsPadding => const EdgeInsets.only(left: 5, right: 10);

  int? get minLines => null;

  int? get maxLines => 1;

  bool get isExpandend => false;

  MaxLengthEnforcement? get maxLengthEnforcement => null;

  int? get maxLength => null;

  bool get obscureText => false;

  String get obscuringCharacter => "•";

  bool get showSuffixIcon => true;

  bool get isMultiLine => keyboardType == TextInputType.multiline;

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
    this.inTable = false,
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
      ApplicationSettingsResponse applicationSettings = AppStyle.of(context)!.applicationSettings;
      if (Theme.of(context).brightness == Brightness.light) {
        fillColor = applicationSettings.colors?.mandatoryBackground;
      } else {
        fillColor = applicationSettings.darkColors?.mandatoryBackground;
      }
    }
    ThemeData themeData = Theme.of(context);

    fillColor ??= themeData.inputDecorationTheme.fillColor ?? themeData.backgroundColor;

    focusNode.canRequestFocus = model.isFocusable;

    EdgeInsets? paddings;

    if (inTable && kIsWeb) {
      paddings = const EdgeInsets.only(top: 8);
    } else if (!inTable) {
      paddings = contentPadding;
    }

    bool isFilled = !inTable;
    return TextField(
      controller: textController,
      decoration: inputDecoration.copyWith(
        enabled: model.isEnabled,
        hintText: model.placeholder,
        contentPadding: paddings,
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
        filled: isFilled,
        isDense: !inTable && Frame.isWebFrame(),
      ),
      textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
      textAlignVertical: inTable ? TextAlignVertical.center : VerticalAlignmentE.toTextAlign(model.verticalAlignment),
      readOnly: model.isReadOnly,
      style: model.createTextStyle(),
      onChanged: valueChanged,
      onEditingComplete: focusNode.unfocus,
      expands: isExpandend,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      focusNode: focusNode,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
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
    if ((textController.text.isEmpty || hideClearIcon) && !pForce) {
      return null;
    }

    bool isLight = Theme.of(FlutterUI.getCurrentContext()!).brightness == Brightness.light;

    return InkWell(
      canRequestFocus: false,
      onTap: () {
        if (!model.isReadOnly) {
          if (focusNode.hasFocus) {
            textController.clear();
            valueChanged("");
          } else {
            endEditing("");
          }
        }
      },
      child: SizedBox(
        width: clickableClearArea,
        height: clickableClearArea,
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

    if (suffixIconItems.length > 1) {
      Widget lastWidget = suffixIconItems.removeLast();

      suffixIconItems = suffixIconItems.map<Widget>(
        (suffixItem) {
          EdgeInsets padding = iconPadding;

          if (suffixItem is GestureDetector || suffixItem is InkResponse) {
            padding = padding.copyWith(right: max(padding.right - ((clickableClearArea - iconSize) / 2), 0.0));
          }

          return Padding(
            padding: padding,
            child: suffixItem,
          );
        },
      ).toList();

      suffixIconItems.add(lastWidget);
    }

    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
    EdgeInsets padding = iconsPadding;
    if (!inTable && keyboardType == TextInputType.multiline) {
      padding = padding.copyWith(top: contentPadding.top);
      crossAxisAlignment = CrossAxisAlignment.start;
      if (suffixIconItems.isNotEmpty) {
        Widget lastItem = suffixIconItems.last;

        if (lastItem is GestureDetector || lastItem is InkResponse) {
          padding = padding.copyWith(
            right: max(padding.right - ((clickableClearArea - iconSize) / 2), 0.0),
          );
        }
      }
    }

    if (suffixIconItems.isEmpty) {
      suffixIconItems.add(const Center());
    }

    return Container(
      // Only on multiline editors.
      height: isMultiLine ? double.infinity : null,
      padding: padding,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
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
    if (inTable) {
      return InputBorder.none;
    }

    switch (pBorderType) {
      case FlTextBorderType.border:
      case FlTextBorderType.errorBorder:
      case FlTextBorderType.enabledBorder:
        return const OutlineInputBorder(
          borderSide: BorderSide(
            color: JVxColors.COMPONENT_BORDER,
          ),
        );
      case FlTextBorderType.focusedBorder:
        return null;
      case FlTextBorderType.disabledBorder:
        return const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: JVxColors.COMPONENT_DISABLED,
          ),
        );
      case FlTextBorderType.focusedErrorBorder:
        return null;
    }
  }

  /// Returns all extra paddings this text field has in sum apart from the text size itself.
  double extraWidthPaddings() {
    int iconAmount = createSuffixIconItems(true).length;

    double width = (iconSize * iconAmount) + (clickableClearArea - iconSize);
    width += (iconPadding.horizontal) * iconAmount;
    width += iconsPadding.horizontal;
    width += contentPadding.horizontal;

    return width;
  }
}
