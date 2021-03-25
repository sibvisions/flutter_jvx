import 'package:flutter/material.dart';

import '../../../injection_container.dart';
import '../../models/api/requests/set_component_value.dart';
import '../../services/remote/cubit/api_cubit.dart';
import '../layout/I_alignment_constants.dart';
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
  void valueChanged(dynamic value) {
    SetComponentValueRequest setComponentValue = SetComponentValueRequest(
        componentId: widget.componentModel.name!,
        value: value,
        clientId: widget.componentModel.appState.applicationMetaData!.clientId);

    sl<ApiCubit>().setComponentValue(setComponentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
            mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                widget.componentModel.horizontalAlignment!),
            crossAxisAlignment: IAlignmentConstants.getCrossAxisAlignment(
                widget.componentModel.verticalAlignment!),
            children: <Widget>[
          Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Container(
                  decoration: BoxDecoration(
                      color: widget.componentModel.background != null
                          ? widget.componentModel.background
                          : Colors.white.withOpacity(widget.componentModel
                                  .appState.applicationStyle?.controlsOpacity ??
                              1.0),
                      borderRadius: BorderRadius.circular(widget.componentModel
                              .appState.applicationStyle?.cornerRadiusEditors ??
                          5)),
                  child: CustomIcon(
                    image: widget.componentModel.image ?? '',
                    color: widget.componentModel.foreground,
                    prefferedSize: widget.componentModel.preferredSize,
                  )))
        ]));
  }
}
