import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/model/component/custom/fl_custom_container_model.dart';
import 'package:signature/signature.dart';

import '../base_wrapper/fl_stateless_widget.dart';

class FlSignaturePadWidget<T extends FlCustomContainerModel> extends FlStatelessWidget<T> {
  final SignatureController controller;

  const FlSignaturePadWidget({
    Key? key,
    required T model,
    required this.controller,
  }) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    return Signature(
      controller: controller,
      backgroundColor: model.background ?? themeData.backgroundColor,
    );
  }
}
