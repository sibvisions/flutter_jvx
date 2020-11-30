import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/api/request/set_component_value.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../layout/I_alignment_constants.dart';
import '../widgets/custom/custom_icon.dart';
import 'component_widget.dart';
import 'models/icon_component_model.dart';

class CoIconWidget extends ComponentWidget {
  final IconComponentModel componentModel;

  CoIconWidget({this.componentModel}) : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoIconWidgetState();
}

class CoIconWidgetState extends ComponentWidgetState<CoIconWidget> {
  void valueChanged(dynamic value) {
    SetComponentValue setComponentValue = SetComponentValue(
        widget.componentModel.name,
        value,
        widget.componentModel.appState.clientId);
    BlocProvider.of<ApiBloc>(context).add(setComponentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
            mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                widget.componentModel.horizontalAlignment),
            children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  color: widget.componentModel.background != null
                      ? widget.componentModel.background
                      : Colors.white.withOpacity(widget.componentModel.appState
                          .applicationStyle?.controlsOpacity),
                  borderRadius: BorderRadius.circular(widget.componentModel
                      .appState.applicationStyle?.cornerRadiusEditors)),
              child: CustomIcon(
                image: widget.componentModel.image,
              ))
        ]));
  }
}
