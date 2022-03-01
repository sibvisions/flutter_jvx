import 'package:flutter/material.dart';
import 'package:flutter_client/util/constants/i_color.dart';

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

  Widget? get image => model.image;

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
      onPressed: model.isEnabled && model.isFocusable ? onPress : null,
      child: Container(
        child: getButtonChild(),
        alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
      ),
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
        // side: MaterialStateProperty.all(
        //   BorderSide(
        //       color: model.isEnabled ? Colors.black : IColorConstants.COMPONENT_DISABLED,
        //       style: model.borderPainted ? BorderStyle.solid : BorderStyle.none),
        // ),
        elevation: MaterialStateProperty.all(model.borderPainted ? 2 : 0),
        backgroundColor: MaterialStateProperty.all(model.background),
        padding: MaterialStateProperty.all(model.paddings));
  }
}
