import 'package:flutter/material.dart';
import 'package:flutter_client/util/constants/i_color.dart';
import 'package:flutter_client/util/image/image_loader.dart';

import '../../model/component/button/fl_button_model.dart';
import '../../model/layout/alignments.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import '../label/fl_label_widget.dart';

/// The widget representing a button.
class FlButtonWidget<T extends FlButtonModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The function to call on the press of the button.
  final VoidCallback onPress;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget? get image {
    if (model.image != null) {
      return ImageLoader.loadImage(model.image!,
          pWantedColor: model.isEnabled ? null : IColorConstants.COMPONENT_DISABLED);
    }
    return null;
  }

  bool get enableFeedback => true;

  InteractiveInkFeatureFactory? get splashFactory => null;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlButtonWidget]
  const FlButtonWidget({Key? key, required FlButtonModel model, required this.onPress})
      : super(key: key, model: model as T);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: getOnPressed(),
      child: getDirectButtonChild(context),
      style: getButtonStyle(),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the icon and/or the text of the button.
  Widget? getButtonChild() {
    if (model.labelModel.text.isNotEmpty && image != null) {
      if (model.labelModel.verticalAlignment != VerticalAlignment.CENTER &&
          model.labelModel.horizontalAlignment == HorizontalAlignment.CENTER) {
        return Column(
          children: <Widget>[
            image!,
            SizedBox(height: model.imageTextGap.toDouble()),
            Flexible(child: _getTextWidget())
          ],
          mainAxisSize: MainAxisSize.min,
          textBaseline: TextBaseline.alphabetic,
          textDirection: // If the text is aligned to the left, the text comes before the icon
              model.labelModel.verticalAlignment == VerticalAlignment.TOP ? TextDirection.rtl : TextDirection.ltr,
        );
      } else {
        return Row(
          children: <Widget>[image!, SizedBox(width: model.imageTextGap.toDouble()), Flexible(child: _getTextWidget())],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: _getCrossAxisAlignment(model.labelModel.verticalAlignment),
          textBaseline: TextBaseline.alphabetic,
          textDirection: // If the text is aligned to the left, the text comes before the icon
              model.labelModel.horizontalAlignment == HorizontalAlignment.LEFT ? TextDirection.rtl : TextDirection.ltr,
        );
      }
    } else if (model.labelModel.text.isNotEmpty) {
      return _getTextWidget();
    } else if (image != null) {
      return image!;
    } else {
      return null;
    }
  }

  Widget? getDirectButtonChild(BuildContext context) {
    return Container(
      child: getButtonChild(),
      decoration: getBoxDecoration(context),
      alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
    );
  }

  /// Converts [VerticalAlignment] into a usable [CrossAxisAlignment] for [Row]
  CrossAxisAlignment _getCrossAxisAlignment(VerticalAlignment pAlignment) {
    if (pAlignment == VerticalAlignment.TOP) {
      return CrossAxisAlignment.start;
    } else if (pAlignment == VerticalAlignment.BOTTOM) {
      return CrossAxisAlignment.end;
    }

    return CrossAxisAlignment.center;
  }

  /// Gets the text widget of the button with the label model.
  Widget _getTextWidget() {
    return FlLabelWidget(model: model.labelModel).getTextWidget();
  }

  /// Gets the button style.
  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      elevation: MaterialStateProperty.all(model.borderPainted ? 2 : 0),
      backgroundColor: model.background != null ? MaterialStateProperty.all(model.background) : null,
      padding: MaterialStateProperty.all(model.paddings),
    );
  }

  BoxDecoration? getBoxDecoration(BuildContext pContext) => null;

  Function()? getOnPressed() {
    return model.isEnabled && model.isFocusable ? onPress : null;
  }
}
