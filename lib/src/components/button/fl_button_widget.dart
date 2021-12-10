import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'package:flutter_client/util/constants/i_color_constants.dart';

import '../../model/component/button/fl_button_model.dart';
import 'package:flutter/material.dart';

class FlButtonWidget extends StatelessWidget {
  const FlButtonWidget({Key? key, required this.buttonModel, required this.onPress, this.width, this.height}) : super(key: key);

  final FlButtonModel buttonModel;
  final double? width;
  final double? height;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: ElevatedButton(onPressed: onPress, child: _getTextWidget()));
  }

  Text _getTextWidget() {
    return Text(buttonModel.text,
        style: TextStyle(
            fontSize: buttonModel.fontStyle.fontSize)
    );
  }
}
