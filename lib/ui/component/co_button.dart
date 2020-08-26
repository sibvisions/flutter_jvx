import 'dart:io';
import 'dart:convert' as utf8;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_creator.dart';
import 'package:tinycolor/tinycolor.dart';
import '../../model/api/request/reload.dart';
import '../../model/api/request/request.dart';
import '../widgets/fontAwesomeChanger.dart';
import '../../utils/text_utils.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/press_button.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import 'co_action_component.dart';
import '../../utils/uidata.dart';
import '../../model/so_action.dart';
import '../../utils/globals.dart' as globals;

class CoButton extends CoActionComponent {
  String text = "";
  Widget icon;
  String textStyle;

  CoButton(Key componentId, BuildContext context) : super(componentId, context);

  factory CoButton.withCompContext(ComponentContext componentContext) {
    return CoButton(componentContext.globalKey, componentContext.context);
  }

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
    textStyle = changedComponent.getProperty<String>(
        ComponentProperty.STYLE, textStyle);

    String image =
        changedComponent.getProperty<String>(ComponentProperty.IMAGE);
    if (image != null) {
      if (checkFontAwesome(image)) {
        icon = convertFontAwesomeTextToIcon(image, UIData.textColor);
      } else {
        List strinArr = List<String>.from(image.split(','));
        if (kIsWeb) {
          if (globals.files.containsKey(strinArr[0])) {
            Size size = Size(16, 16);

            if (strinArr.length >= 3 &&
                double.tryParse(strinArr[1]) != null &&
                double.tryParse(strinArr[2]) != null) {
              size = Size(double.parse(strinArr[1]), double.parse(strinArr[2]));
            }
            icon = Image.memory(
              utf8.base64Decode(globals.files[strinArr[0]]),
              width: size.width,
              height: size.height,
              color: !this.enabled ? Colors.grey.shade500 : null,
            );

            BlocProvider.of<ApiBloc>(context)
                .dispatch(Reload(requestType: RequestType.RELOAD));
          }
        } else {
          File file = File('${globals.dir}${strinArr[0]}');
          if (file.existsSync()) {
            Size size = Size(16, 16);

            if (strinArr.length >= 3 &&
                double.tryParse(strinArr[1]) != null &&
                double.tryParse(strinArr[2]) != null)
              size = Size(double.parse(strinArr[1]), double.parse(strinArr[2]));
            icon = Image.memory(
              file.readAsBytesSync(),
              width: size.width,
              height: size.height,
              color: !this.enabled ? Colors.grey.shade500 : null,
            );

            BlocProvider.of<ApiBloc>(context)
                .dispatch(Reload(requestType: RequestType.RELOAD));
          }
        }
      }
    }
  }

  void buttonPressed() {
    TextUtils.unfocusCurrentTextfield(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      PressButton pressButton =
          PressButton(SoAction(componentId: this.name, label: this.text));
      BlocProvider.of<ApiBloc>(context).dispatch(pressButton);
    });
  }

  @override
  Widget getWidget() {
    Widget child;
    Widget textWidget = new Text(text != null ? text : "",
        style: TextStyle(
            fontSize: style.fontSize,
            color: !this.enabled
                ? Colors.grey.shade500
                : this.foreground != null
                    ? this.foreground
                    : UIData.textColor));

    if (text?.isNotEmpty ?? true) {
      if (icon != null) {
        child = Row(
          children: <Widget>[icon, SizedBox(width: 10), textWidget],
          mainAxisAlignment: MainAxisAlignment.center,
        );
      } else {
        child = textWidget;
      }
    } else if (icon != null) {
      child = icon;
    } else {
      child = textWidget;
    }

    double minWidth = 44;
    EdgeInsets padding;

    if (this.isPreferredSizeSet && this.preferredSize.width < minWidth) {
      padding = EdgeInsets.symmetric(horizontal: 0);
      minWidth = this.preferredSize.width;
    }

    if (textStyle == 'hyperlink') {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        margin: EdgeInsets.all(4),
        child: GestureDetector(
          onTap: this.enabled ? buttonPressed : null,
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                text != null ? text : '',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: style.fontSize,
                    color: !this.enabled
                        ? Colors.grey.shade500
                        : this.foreground != null
                            ? this.foreground
                            : Colors.blue),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
        margin: EdgeInsets.all(4),
        child: ButtonTheme(
            minWidth: minWidth,
            padding: padding,
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            shape: globals.applicationStyle?.buttonShape ?? null,
            child: SizedBox(
                height: 40,
                child: RaisedButton(
                  key: this.componentId,
                  onPressed: this.enabled ? buttonPressed : null,
                  color: this.background != null
                      ? this.background
                      : UIData.ui_kit_color_2[600],
                  elevation: 2,
                  disabledColor: Colors.grey.shade300,
                  child: child,
                  splashColor: this.background != null
                      ? TinyColor(this.background).darken().color
                      : UIData.ui_kit_color_2[700],
                ))));
  }
}
