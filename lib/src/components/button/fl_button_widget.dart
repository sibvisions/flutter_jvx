import '../../model/component/button/fl_button_model.dart';
import 'package:flutter/material.dart';

class FlButtonWidget extends StatelessWidget {
  const FlButtonWidget({Key? key, required this.buttonModel}) : super(key: key);

  final FlButtonModel buttonModel;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {},
        child: Text(buttonModel.text)
    );
  }
}
