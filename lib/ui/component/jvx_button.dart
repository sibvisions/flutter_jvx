import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/model/api/request/reload.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/ui/widgets/fontAwesomeChanger.dart';

import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/press_button.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/component/jvx_action_component.dart';
import '../../utils/uidata.dart';
import '../../model/action.dart' as jvxAction;
import '../../utils/globals.dart' as globals;

class JVxButton extends JVxActionComponent {
  String text = "";
  Widget icon;

  JVxButton(Key componentId, BuildContext context) : super(componentId, context);

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
    String image = changedComponent.getProperty<String>(ComponentProperty.IMAGE);
    if (image!=null) {
      if(checkFontAwesome(image)) {
        icon = convertFontAwesomeTextToIcon(image, UIData.textColor);
      } else {
        List strinArr = List<String>.from(image.split(','));
        File file = File('${globals.dir}${strinArr[0]}');
        if (file.existsSync()) {
          Size size = Size(16,16);

        if (strinArr.length>=3 && double.tryParse(strinArr[1])!=null && double.tryParse(strinArr[2])!=null) 
          size = Size(double.parse(strinArr[1]), double.parse(strinArr[2]));
        icon = Image.memory(
          file.readAsBytesSync(),
          width: size.width,
          height: size.height,
        );

        BlocProvider.of<ApiBloc>(context)
            .dispatch(Reload(requestType: RequestType.RELOAD));
      }
      }
    }
  }

  void buttonPressed() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      PressButton pressButton = PressButton(jvxAction.Action(componentId: this.name, label: this.text));
      BlocProvider.of<ApiBloc>(context).dispatch(pressButton);
    });
  }

  @override
  Widget getWidget() {
    Widget child;
    Widget textWidget = new Text(text!=null?text:"", 
      style: TextStyle(
        fontSize: style.fontSize,
        color: UIData.textColor
      )
    );

    if (text?.isNotEmpty ?? true) {
      if (icon!=null) {
        child = Row(children: <Widget>[icon, SizedBox(width: 10), textWidget], mainAxisAlignment: MainAxisAlignment.center,);
      } else {
        child = textWidget;
      }
    } else if (icon!=null) {
      child = icon;
    } else {
      child = textWidget;
    }

    return 
    ButtonTheme(
  minWidth: 44,
  child: 
      RaisedButton(
        key: this.componentId, 
        onPressed: this.enabled?buttonPressed:null,
        color: UIData.ui_kit_color_2[400],
        elevation: 10,
        child: child,
        splashColor: this.background,
      ));
  }
}