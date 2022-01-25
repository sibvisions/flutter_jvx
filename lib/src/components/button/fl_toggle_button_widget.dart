import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/button/fl_toggle_button_model.dart';
import '../label/fl_label_widget.dart';
import '../../model/layout/alignments.dart';

/// The widget representing a button.
class FlToggleButtonWidget extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The model containing every information to build the button.
  final FlToggleButtonModel model;

  // The function to call on the press of the button.
  final VoidCallback onPress;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlButtonWidget]
  const FlToggleButtonWidget({Key? key, required this.model, required this.onPress}) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      child: Container(
        child: _getButtonChild(),
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 10.0, color: model.selected ? Colors.black26 : const Color(0x00000000))]),
        alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(model.background),
          padding: MaterialStateProperty.all(model.margins)),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the icon and/or the text of the button.
  Widget _getButtonChild() {
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
}
