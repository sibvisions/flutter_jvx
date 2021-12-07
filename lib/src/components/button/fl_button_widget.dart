import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'package:flutter_client/util/constants/i_color_constants.dart';

import '../../model/component/button/fl_button_model.dart';
import 'package:flutter/material.dart';

class FlButtonWidget extends StatelessWidget {
  const FlButtonWidget({Key? key, required this.buttonModel, this.width, this.heigth}) : super(key: key);

  final FlButtonModel buttonModel;
  final double? width;
  final double? heigth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: heigth, child: ElevatedButton(onPressed: () {}, child: _getTextWidget()));
  }

  Text _getTextWidget() {
    return Text(buttonModel.text,
        style: TextStyle(
            fontSize: buttonModel.fontStyle.fontSize,
            color: buttonModel.enabled ? buttonModel.foreground : IColorConstants.COMPONENT_DISABLED));
  }
}
