import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/layout/i_alignment_constants.dart';
import '../../ui/widgets/custom_icon.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/set_component_value.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/component/i_component.dart';
import '../../ui/component/jvx_component.dart';
import '../../utils/globals.dart' as globals;

class JVxIcon extends JVxComponent implements IComponent {
  String text;
  bool selected = false;
  bool eventAction = false;
  String image;

  JVxIcon(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

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
  Widget getWidget() {
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
                  borderRadius: BorderRadius.circular(globals.applicationStyle.cornerRadiusEditors)),
              child: CustomIcon(
                image: image,
              ))
        ]));
  }
}
