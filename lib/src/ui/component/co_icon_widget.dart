import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_data.dart';
import 'package:flutterclient/src/ui/screen/core/so_screen.dart';
import 'package:signature/signature.dart';

import '../../../injection_container.dart';
import '../../models/api/requests/set_component_value.dart';
import '../../services/remote/cubit/api_cubit.dart';
import '../layout/i_alignment_constants.dart';
import '../widgets/custom/custom_icon.dart';
import 'component_widget.dart';
import 'model/icon_component_model.dart';

class CoIconWidget extends ComponentWidget {
  final IconComponentModel componentModel;

  CoIconWidget({required this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoIconWidgetState();
}

class CoIconWidgetState extends ComponentWidgetState<CoIconWidget> {
  late SignatureController _signatureController;

  Future<void> _onEndDrawing() async {
    if (widget.componentModel.dataProvider != null &&
        _signatureController.isNotEmpty) {
      SoComponentData data = SoScreen.of(context)!
          .getComponentData(widget.componentModel.dataProvider!);

      Uint8List? pngBytes = await _signatureController.toPngBytes();

      await data.setValues(
        context,
        [pngBytes],
        [widget.componentModel.columnName],
      );
    }
  }

  void valueChanged(dynamic value) {
    SetComponentValueRequest setComponentValue = SetComponentValueRequest(
        componentId: widget.componentModel.name,
        value: value,
        clientId: widget.componentModel.appState.applicationMetaData!.clientId);

    sl<ApiCubit>().setComponentValue(setComponentValue);
  }

  @override
  void initState() {
    super.initState();

    if (widget.componentModel.isSignaturePad) {
      _signatureController = SignatureController(
          exportBackgroundColor: widget.componentModel.background,
          onDrawEnd: () => _onEndDrawing(),
          penStrokeWidth: 5,
          penColor: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.componentModel.isSignaturePad) {
      return LayoutBuilder(
        builder: (context, constraints) => Signature(
          controller: _signatureController,
          backgroundColor: widget.componentModel.background,
          height: widget.componentModel.preferredSize?.height ?? 300,
          width: widget.componentModel.preferredSize?.width ?? 300,
        ),
      );
    }

    return Container(
        child: Row(
            mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                widget.componentModel.horizontalAlignment),
            crossAxisAlignment: IAlignmentConstants.getCrossAxisAlignment(
                widget.componentModel.verticalAlignment),
            children: <Widget>[
          Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Container(
                  decoration: BoxDecoration(
                      color: widget.componentModel.isBackgroundSet
                          ? widget.componentModel.background
                          : Colors.white.withOpacity(widget.componentModel
                                  .appState.applicationStyle?.controlsOpacity ??
                              1.0),
                      borderRadius: BorderRadius.circular(widget.componentModel
                              .appState.applicationStyle?.cornerRadiusEditors ??
                          5)),
                  child: CustomIcon(
                    image: widget.componentModel.image,
                    color: widget.componentModel.foreground,
                    prefferedSize: widget.componentModel.preferredSize,
                  )))
        ]));
  }
}
