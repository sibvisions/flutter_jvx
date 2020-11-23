import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/core/ui/component/icon_component_model.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../models/api/request/set_component_value.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../layout/I_alignment_constants.dart';
import '../widgets/custom/custom_icon.dart';
import 'component_widget.dart';

class CoIconWidget extends ComponentWidget {
  final IconComponentModel componentModel;

  CoIconWidget({this.componentModel}) : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoIconWidgetState();
}

class CoIconWidgetState extends ComponentWidgetState<CoIconWidget> {
  void valueChanged(dynamic value) {
    SetComponentValue setComponentValue =
        SetComponentValue(this.name, value, this.appState.clientId);
    BlocProvider.of<ApiBloc>(context).add(setComponentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
            mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                this.horizontalAlignment),
            children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  color: background != null
                      ? background
                      : Colors.white.withOpacity(
                          this.appState.applicationStyle?.controlsOpacity),
                  borderRadius: BorderRadius.circular(
                      this.appState.applicationStyle?.cornerRadiusEditors)),
              child: CustomIcon(
                image: widget.componentModel.image,
              ))
        ]));
  }
}
