import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import '../label/fl_label_widget.dart';
import '../../model/layout/alignments.dart';

import '../../model/component/button/fl_button_model.dart';

/// The widget representing a button.
class FlButtonWidget<T extends FlButtonModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The function to call on the press of the button.
  final VoidCallback onPress;

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
        onPressed: onPress,
        child: Container(
          child: getButtonChild(),
          alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
        ),
        style: getButtonStyle());
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the icon and/or the text of the button.
  Widget getButtonChild() {
    if (model.text.isNotEmpty && model.image != null) {
      if (model.labelModel.verticalAlignment != VerticalAlignment.CENTER &&
          model.labelModel.horizontalAlignment == HorizontalAlignment.CENTER) {
        return Column(
          children: <Widget>[
            model.image!,
            SizedBox(width: model.imageTextGap.toDouble()),
            Flexible(child: _getTextWidget())
          ],
          mainAxisSize: MainAxisSize.min,
          textBaseline: TextBaseline.alphabetic,
          textDirection: // If the text is aligned to the left, the text comes before the icon
              model.labelModel.verticalAlignment == VerticalAlignment.TOP ? TextDirection.rtl : TextDirection.ltr,
        );
      } else {
        return Row(
          children: <Widget>[
            model.image!,
            SizedBox(width: model.imageTextGap.toDouble()),
            Flexible(child: _getTextWidget())
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: _getCrossAxisAlignment(model.labelModel.verticalAlignment),
          textBaseline: TextBaseline.alphabetic,
          textDirection: // If the text is aligned to the left, the text comes before the icon
              model.labelModel.horizontalAlignment == HorizontalAlignment.LEFT ? TextDirection.rtl : TextDirection.ltr,
        );
      }
    } else if (model.text.isNotEmpty) {
      return _getTextWidget();
    } else if (model.image != null) {
      return model.image!;
    } else {
      return const Text("No text/image");
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
        elevation: MaterialStateProperty.all(2),
        backgroundColor: MaterialStateProperty.all(model.background),
        padding: MaterialStateProperty.all(model.margins));
  }
}
