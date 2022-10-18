import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../util/constants/i_color.dart';
import '../../../mask/state/app_style.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../model/layout/alignments.dart';
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
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextInputType keyboardType;

  final FocusNode focusNode;

  final TextEditingController textController;

  final bool inTable;

  final bool isMandatory;

  /// Additional input decorations not handled by the model.
  final InputDecoration inputDecoration;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double get clickableClearArea => 24;

  double get iconSize => 16;

  EdgeInsets get contentPadding => inTable ? EdgeInsets.zero : const EdgeInsets.fromLTRB(10, 15, 10, 15);

  EdgeInsets get iconPadding => const EdgeInsets.only(right: 5);

  EdgeInsets get iconsPadding => const EdgeInsets.only(left: 5, right: 10);

  int? get minLines => null;

  int? get maxLines => model.rows;

  List<TextInputFormatter>? get inputFormatters => null;

  MaxLengthEnforcement? get maxLengthEnforcement => null;

  int? get maxLength => null;

  bool get obscureText => false;

  String get obscuringCharacter => "•";

  bool get showSuffixIcon => true;

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
    this.keyboardType = TextInputType.text,
    this.inTable = false,
    this.isMandatory = false,
    this.inputDecoration = const InputDecoration(),
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Color? fillColor = model.background ??
        (isMandatory ? AppStyle.of(context)!.applicationSettings.colors?.mandatoryBackground : null);
    bool isFilled = fillColor != null && !inTable;

    return TextField(
      controller: textController,
      decoration: inputDecoration.copyWith(
        enabled: model.isEnabled,
        hintText: model.placeholder,
        contentPadding: contentPadding,
        border: createBorder(context, FlTextBorderType.border),
        errorBorder: createBorder(context, FlTextBorderType.errorBorder),
        enabledBorder: createBorder(context, FlTextBorderType.enabledBorder),
        focusedBorder: createBorder(context, FlTextBorderType.focusedBorder),
        disabledBorder: createBorder(context, FlTextBorderType.disabledBorder),
        focusedErrorBorder: createBorder(context, FlTextBorderType.focusedBorder),
        suffixIcon: createSuffixIcon(),
        suffix: createSuffix(),
        fillColor: fillColor,
        filled: isFilled,
      ),
      textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
      textAlignVertical: VerticalAlignmentE.toTextAlign(model.verticalAlignment),
      readOnly: model.isReadOnly,
      style: model.createTextStyle(),
      onChanged: valueChanged,
      onEditingComplete: () {
        focusNode.unfocus();
      },
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      focusNode: !model.isReadOnly ? focusNode : null,
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
    if (textController.text.isEmpty && !pForce) {
      return null;
    }

    return InkWell(
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
            color: IColorConstants.COMPONENT_DISABLED,
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

    if (suffixIconItems.isEmpty) {
      return null;
    }

    if (suffixIconItems.length > 1) {
      Widget lastWidget = suffixIconItems.removeLast();

      suffixIconItems = suffixIconItems.map<Widget>(
        (suffixItem) {
          EdgeInsets padding = iconPadding;

          if (suffixItem is GestureDetector || suffixItem is InkResponse) {
            padding = padding.copyWith(right: max(padding.right - (clickableClearArea - iconSize), 0.0));
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

    return Container(
      height: double.infinity,
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

  InputBorder? createBorder(BuildContext context, FlTextBorderType pBorderType) {
    if (inTable) {
      return InputBorder.none;
    }

    switch (pBorderType) {
      case FlTextBorderType.border:
      case FlTextBorderType.errorBorder:
      case FlTextBorderType.enabledBorder:
        return const OutlineInputBorder(
          borderSide: BorderSide(
            color: IColorConstants.COMPONENT_DISABLED,
          ),
        );
      case FlTextBorderType.focusedBorder:
        return null;
      case FlTextBorderType.disabledBorder:
        return const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: IColorConstants.COMPONENT_DISABLED,
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
