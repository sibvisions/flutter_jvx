import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../screen/core/so_component_data.dart';
import '../screen/core/so_screen.dart';
import 'co_container_widget.dart';
import 'models/custom_container_component_model.dart';

class CoCustomContainerWidget extends CoContainerWidget {
  CoCustomContainerWidget(
      {required CustomContainerComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoCustomContainerWidgetState();
}

class CoCustomContainerWidgetState extends CoContainerWidgetState {
  late SignatureController _signatureController;

  Future<void> _onEndDrawing() async {
    CustomContainerComponentModel customContainerComponentModel =
        widget.componentModel as CustomContainerComponentModel;

    if (customContainerComponentModel.dataProvider != null &&
        _signatureController.isNotEmpty) {
      SoComponentData data = SoScreen.of(context)!
          .getComponentData(customContainerComponentModel.dataProvider!);

      Uint8List? pngBytes = await _signatureController.toPngBytes();

      await data.setValues(
        context,
        [base64Encode(pngBytes!.toList())],
        [customContainerComponentModel.columnName],
      );
    }
  }

  @override
  void initState() {
    super.initState();

    if ((widget.componentModel as CustomContainerComponentModel)
        .isSignaturePad) {
      _signatureController = SignatureController(
          exportBackgroundColor: widget.componentModel.background,
          onDrawEnd: () => _onEndDrawing(),
          penStrokeWidth: 5,
          penColor: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Signature(
        controller: _signatureController,
        backgroundColor: widget.componentModel.background,
        height: widget.componentModel.preferredSize?.height ?? 300,
        width: widget.componentModel.preferredSize?.width ?? 300,
      ),
    );
  }
}
