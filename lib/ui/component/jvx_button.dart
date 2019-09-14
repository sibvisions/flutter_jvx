import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/logic/bloc/press_button_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/press_button_view_model.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'jvx_component.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JVxButton extends JVxComponent {
  String text = "";
  StreamSubscription<FetchProcess> apiStreamSubscription;
  PressButtonBloc pressButtonBloc = PressButtonBloc();

  JVxButton(Key componentId, BuildContext context) : super(componentId, context);

  @override
  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    text = properties.getProperty<String>("text");
  }

  void buttonPressed() {
    apiStreamSubscription = apiSubscription(pressButtonBloc.apiResult, context);
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
          color: this.background,
          child: Text(text, 
            style: style
          ),
        ),
      );
  }
}