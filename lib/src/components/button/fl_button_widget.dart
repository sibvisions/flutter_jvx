import 'package:flutter/material.dart';

import '../../../components.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/jvx_colors.dart';
import '../../model/layout/alignments.dart';

/// The widget representing a button.
class FlButtonWidget<T extends FlButtonModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const String OFFLINE_BUTTON = "OfflineButton";
  static const String QR_SCANNER_BUTTON = "QRScannerButton";
  static const String CALL_BUTTON = "CallButton";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The function to call on the press of the button.
  final VoidCallback? onPress;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget? get image {
    if (model.image != null) {
      return ImageLoader.loadImage(model.image!, pWantedColor: model.createTextStyle().color);
    }
    return null;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlButtonWidget]
  const FlButtonWidget({super.key, required super.model, this.onPress});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: getOnPressed(context),
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
          children: <Widget>[
            image!,
            SizedBox(height: model.imageTextGap.toDouble()),
            Flexible(child: createTextWidget()),
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: getCrossAxisAlignment(model.labelModel.verticalAlignment),
          textBaseline: TextBaseline.alphabetic,
          textDirection: // If the text is aligned to the left, the text comes before the icon
              model.labelModel.horizontalAlignment == HorizontalAlignment.LEFT ? TextDirection.rtl : TextDirection.ltr,
          children: <Widget>[
            image!,
            SizedBox(width: model.imageTextGap.toDouble()),
            Flexible(child: createTextWidget())
          ],
        );
      }
    } else if (model.labelModel.text.isNotEmpty) {
      return createTextWidget();
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
  Widget createTextWidget() {
    TextStyle textStyle = model.labelModel.createTextStyle();

    if (!model.isEnabled) {
      textStyle = textStyle.copyWith(color: JVxColors.darken(JVxColors.COMPONENT_DISABLED));
    } else if (model.labelModel.foreground == null && model.style == "hyperlink") {
      textStyle = textStyle.copyWith(color: Colors.blue);
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
      backgroundColor = JVxColors.COMPONENT_DISABLED;
    } else if (model.style == "hyperlink") {
      backgroundColor = Colors.transparent;
    } else {
      backgroundColor = model.background;
    }

    bool hasElevation = model.borderPainted && !model.borderOnMouseEntered && model.isEnabled;
    hasElevation == hasElevation && backgroundColor != Colors.transparent;

    return ButtonStyle(
      elevation: MaterialStateProperty.all(hasElevation ? 2 : 0),
      backgroundColor: backgroundColor != null ? MaterialStateProperty.all(backgroundColor) : null,
      padding: MaterialStateProperty.all(model.paddings),
      splashFactory: !model.borderPainted ? NoSplash.splashFactory : null,
      overlayColor: !model.borderPainted ? MaterialStateProperty.all(Colors.transparent) : null,
    );
  }

  Function()? getOnPressed(BuildContext context) {
    if (model.isEnabled) {
      return onPress;
    }
    return null;
  }
}
