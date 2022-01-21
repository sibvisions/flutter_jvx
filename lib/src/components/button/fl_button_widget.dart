import 'package:flutter/material.dart';

import '../../model/component/button/fl_button_model.dart';

/// The widget representing a button.
class FlButtonWidget extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The model containing every information to build the button.
  final FlButtonModel buttonModel;

  // The width as constrained by the parent widget.
  final double? width;

  // The height as constrained by the parent widget.
  final double? height;

  // The function to call on the press of the button.
  final VoidCallback onPress;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [FlButtonWidget]
  const FlButtonWidget({Key? key, required this.buttonModel, required this.onPress, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPress, child: _getTextWidget());
  }

  Text _getTextWidget() {
    return Text(buttonModel.text,
        textWidthBasis: TextWidthBasis.parent,
        style: TextStyle(
          fontSize: buttonModel.fontSize.toDouble(),
        ));
  }
}
