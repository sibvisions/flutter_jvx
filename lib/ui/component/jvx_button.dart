import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/press_button.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_action_component.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/model/action.dart' as jvxAction;

class JVxButton extends JVxActionComponent {
  String text = "";

  JVxButton(Key componentId, BuildContext context) : super(componentId, context);

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
  }

  void buttonPressed() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    Future.delayed(const Duration(milliseconds: 10), () {
      PressButton pressButton = PressButton(jvxAction.Action(componentId: this.name, label: this.text));
      BlocProvider.of<ApiBloc>(context).dispatch(pressButton);
    });

    //if (this.onButtonPressed!=null) {
    //  this.onButtonPressed(this.name, this.text);
    //}
  }

  @override
  Widget getWidget() {
    return 
      RaisedButton(
        key: this.componentId, 
        onPressed: buttonPressed,
        color: UIData.ui_kit_color_2[400],
        elevation: 10,
        child: Text(text!=null?text:"", 
          style: TextStyle(
            fontSize: style.fontSize,
            color: UIData.textColor
          )
        ),
        splashColor: this.background,
      );
  }
}