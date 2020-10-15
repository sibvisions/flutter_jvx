import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/logic/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/model/api/request/set_component_value.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/ui/layout/i_alignment_constants.dart';
import 'package:jvx_flutterclient/ui/widgets/custom_icon.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/utils/globals.dart' as globals;

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
    SetComponentValue setComponentValue = SetComponentValue(this.name, value);
    BlocProvider.of<ApiBloc>(context).dispatch(setComponentValue);
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
                          globals.applicationStyle.controlsOpacity),
                  borderRadius: BorderRadius.circular(
                      globals.applicationStyle.cornerRadiusEditors)),
              child: CustomIcon(
                image: image,
              ))
        ]));
  }
}
