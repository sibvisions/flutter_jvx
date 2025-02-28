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

import '../../model/component/fl_component_model.dart';
import '../../model/layout/alignments.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/icon_util.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../label/fl_label_widget.dart';

/// The widget representing a button.
class FlButtonWidget<T extends FlButtonModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const String OFFLINE_BUTTON = "OfflineButton";
  static const String SCANNER_BUTTON = "ScannerButton";
  static const String QR_SCANNER_BUTTON = "QRScannerButton";
  static const String CALL_BUTTON = "CallButton";
  static const String GEO_LOCATION_BUTTON = "GeoLocationButton";

  // ignore: non_constant_identifier_names
  static VoidCallback EMPTY_CALLBACK = () {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The function to call on the press of the button.
  final VoidCallback? onPress;

  /// The function if the button gained focus.
  final VoidCallback? onFocusGained;

  /// The function if the button lost focus.
  final VoidCallback? onFocusLost;

  /// The function if the mouse was pressed down.
  final Function(DragDownDetails)? onPressDown;

  /// The function if the mouse click is released.
  final Function(DragEndDetails)? onPressUp;

  /// The focus node of the button.
  final FocusNode focusNode;

  /// The tap target size
  final MaterialTapTargetSize? tapTargetSize;

  /// Whether to use minimal size for widget and remove paddings and reduce tap target size
  final bool? shrinkSize;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget? get image {
    String? imageDefinition = model.className != FlCellEditorClassname.CHECK_BOX_CELL_EDITOR
        ? model.image
        : ((model as FlCheckBoxModel).imageName != null && (model as FlCheckBoxModel).imageName!.isNotEmpty)
            ? (model as FlCheckBoxModel).imageName
            : null;

    if (imageDefinition != null) {
      Color? color;

      if (IconUtil.isFontIcon(imageDefinition)) {
        if (!model.borderPainted || model.borderOnMouseEntered) {
          color = JVxColors.LIGHTER_BLACK;
        } else {
          color = model.createTextStyle().color;
        }
      }

      return ImageLoader.loadImage(
        imageDefinition, color: color,
      );
    }

    return null;
  }

  bool get isButtonFocusable => model.isFocusable;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlButtonWidget]
  const FlButtonWidget({
    super.key,
    required super.model,
    required this.focusNode,
    this.shrinkSize,
    this.tapTargetSize,
    this.onPress,
    this.onFocusGained,
    this.onFocusLost,
    this.onPressDown,
    this.onPressUp,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    Function()? pressEvent = getOnPressed(context);
    if (pressEvent != null && pressEvent != EMPTY_CALLBACK) {
      pressEvent = () {
        if (model.isHapticLight) {
          HapticFeedback.lightImpact();
        } else if (model.isHapticMedium) {
          HapticFeedback.mediumImpact();
        } else if (model.isHapticHeavy) {
          HapticFeedback.heavyImpact();
        } else if (model.isHapticClick) {
          HapticFeedback.selectionClick();
        } else if (model.isHaptic) {
          HapticFeedback.vibrate();
        }
        getOnPressed(context)!.call();
      };
    }

    focusNode.canRequestFocus = isButtonFocusable;

    if (model.isTextButton) {
      return TextButton(
        focusNode: focusNode,
        onFocusChange: _onFocusChange,
        onPressed: pressEvent,
        style: createButtonStyle(context),
        child: createDirectButtonChild(context),
      );
    }

    return ElevatedButton(
      focusNode: focusNode,
      onFocusChange: _onFocusChange,
      onPressed: pressEvent,
      style: createButtonStyle(context),
      child: createDirectButtonChild(context),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the icon and/or the text of the button.
  Widget? createButtonChild(BuildContext context) {
    if (model.labelModel.text.isNotEmpty && image != null) {
      if (model.labelModel.verticalAlignment != VerticalAlignment.CENTER &&
          model.labelModel.horizontalAlignment == HorizontalAlignment.CENTER) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          textBaseline: TextBaseline.alphabetic,
          textDirection: // If the text is aligned to the left, the text comes before the icon
              model.labelModel.verticalAlignment == VerticalAlignment.TOP ? TextDirection.rtl : TextDirection.ltr,
          children: [
            image!,
            SizedBox(height: model.imageTextGap.toDouble()),
            Flexible(child: createTextWidget(context)),
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: getCrossAxisAlignment(model.labelModel.verticalAlignment),
          textBaseline: TextBaseline.alphabetic,
          textDirection: // If the text is aligned to the left, the text comes before the icon
              model.labelModel.horizontalAlignment == HorizontalAlignment.LEFT ? TextDirection.rtl : TextDirection.ltr,
          children: [
            image!,
            SizedBox(width: model.imageTextGap.toDouble()),
            Flexible(child: createTextWidget(context)),
          ],
        );
      }
    } else if (model.labelModel.text.isNotEmpty) {
      return createTextWidget(context);
    } else if (image != null) {
      return image!;
    } else {
      return null;
    }
  }

  Widget createDirectButtonChild(BuildContext context) {
    return Align(
      alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
      child: createButtonChild(context),
    );
  }

  /// Converts [VerticalAlignment] into a usable [CrossAxisAlignment] for [Row]
  CrossAxisAlignment getCrossAxisAlignment(VerticalAlignment pAlignment) {
    if (pAlignment == VerticalAlignment.TOP) {
      return CrossAxisAlignment.start;
    } else if (pAlignment == VerticalAlignment.BOTTOM) {
      return CrossAxisAlignment.end;
    }

    return CrossAxisAlignment.center;
  }

  /// Gets the text widget of the button with the label model.
  Widget createTextWidget(BuildContext context) {
    TextStyle textStyle = model.labelModel.createTextStyle();

    if (!model.isEnabled) {
      textStyle = textStyle.copyWith(color: JVxColors.COMPONENT_DISABLED);
    } else if (model.labelModel.foreground == null && model.isHyperLink) {
      textStyle = textStyle.copyWith(color: Colors.blue);
    } else if (!model.borderPainted || model.borderOnMouseEntered) {
      textStyle = textStyle.copyWith(
        color: JVxColors.isLightTheme(context) ? JVxColors.LIGHTER_BLACK : JVxColors.DARKER_WHITE,
      );
    }

    return FlLabelWidget.getTextWidget(
      model.labelModel,
      pTextStyle: textStyle,
    );
  }

  /// Gets the button style.
  ButtonStyle createButtonStyle(context) {
    Color? backgroundColor;

    if (!model.borderPainted || model.borderOnMouseEntered) {
      backgroundColor = Colors.transparent;
    } else if (!model.isEnabled) {
      backgroundColor = JVxColors.COMPONENT_DISABLED_LIGHTER;
    } else if (model.isHyperLink) {
      backgroundColor = Colors.transparent;
    } else {
      backgroundColor = model.background;
    }

    bool hasElevation = model.borderPainted && !model.borderOnMouseEntered && model.isEnabled;
    hasElevation &= backgroundColor != Colors.transparent;
    hasElevation &= !model.isTextButton;

    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size.zero),
      elevation: WidgetStateProperty.all(hasElevation ? 2 : 0),
      backgroundColor: backgroundColor != null ? WidgetStateProperty.all(backgroundColor) : null,
      //always EdgeInsets.zero paddings just looks wrong with border painted
      padding: WidgetStateProperty.all(shrinkSize == true ?
        (model.borderPainted ? const EdgeInsets.all(2) : EdgeInsets.zero)
        :
        model.paddings
      ),
      tapTargetSize:  shrinkSize == true ? MaterialTapTargetSize.shrinkWrap : tapTargetSize,
      splashFactory: !model.borderPainted ? NoSplash.splashFactory : null,
      overlayColor: !model.borderPainted
          ? WidgetStateProperty.all(Colors.transparent)
          : model.borderOnMouseEntered
              ? WidgetStateProperty.all(JVxColors.COMPONENT_DISABLED_LIGHTER)
              : null,
    );
  }

  Function()? getOnPressed(BuildContext context) {
    if (model.isEnabled) {
      return onPress;
    }
    return null;
  }

  void _onFocusChange(bool pFocus) {
    if (pFocus) {
      onFocusGained?.call();
    } else {
      onFocusLost?.call();
    }
  }
}
