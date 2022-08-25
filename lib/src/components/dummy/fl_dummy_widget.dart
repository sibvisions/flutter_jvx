import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/component/dummy/fl_dummy_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlDummyWidget extends FlStatelessWidget<FlDummyModel> {
  const FlDummyWidget({Key? key, required FlDummyModel model}) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDebugMode
          ? Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
          : Theme.of(context).backgroundColor,
      alignment: Alignment.bottomLeft,
      child: Text(
        "Dummy for ${model.id}",
        textAlign: TextAlign.end,
      ),
    );
  }
}
