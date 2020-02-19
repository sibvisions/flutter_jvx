import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/press_button.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/component/jvx_action_component.dart';
import '../../utils/uidata.dart';
import '../../model/action.dart' as jvxAction;

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
  }

  @override
  Widget getWidget() {
    return 
      RaisedButton(
        key: this.componentId, 
        onPressed: this.enabled?buttonPressed:null,
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