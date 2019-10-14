import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/logic/bloc/press_button_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/press_button_view_model.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'jvx_component.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JVxButton extends JVxComponent {
  String text = "";
  StreamSubscription<FetchProcess> apiStreamSubscription;
  PressButtonBloc pressButtonBloc = PressButtonBloc();

  JVxButton(Key componentId, BuildContext context) : super(componentId, context);

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT);
  }

  void buttonPressed() {
    pressButtonBloc.pressButtonController.add(
      PressButtonViewModel(clientId: globals.clientId, 
        action: prefix0.Action(componentId: this.name, 
        label: this.text))
    );
  }

  @override
  Widget getWidget() {
    return 
      SizedBox(
        child: RaisedButton(
          key: this.componentId, 
          onPressed: buttonPressed,
          color: UIData.ui_kit_color_2[400],
          elevation: 10,
          child: Text(text, 
            style: TextStyle(
              fontSize: style.fontSize,
              color: UIData.textColor
            )
          ),
          splashColor: this.background,
        ),
      );
  }
}