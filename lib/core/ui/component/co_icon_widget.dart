import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../models/api/request/set_component_value.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../layout/I_alignment_constants.dart';
import '../widgets/custom/custom_icon.dart';
import 'component_model.dart';
import 'component_widget.dart';

class CoIconWidget extends ComponentWidget {
  CoIconWidget({ComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoIconWidgetState();
}

class CoIconWidgetState extends ComponentWidgetState {
  @override
  int verticalAlignment = 1;
  @override
  int horizontalAlignment = 1;
  String text;
  bool selected = false;
  bool eventAction = false;
  String image;

  @override
  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
    eventAction = changedProperties.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    selected = changedProperties.getProperty<bool>(
        ComponentProperty.SELECTED, selected);
    image =
        changedProperties.getProperty<String>(ComponentProperty.IMAGE, image);
  }

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
                image: image,
              ))
        ]));
  }
}
