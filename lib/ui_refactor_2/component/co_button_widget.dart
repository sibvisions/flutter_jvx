import 'dart:io';
import 'dart:convert' as utf8;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/logic/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/model/api/request/press_button.dart';
import 'package:jvx_flutterclient/model/api/request/reload.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/model/so_action.dart';
import 'package:jvx_flutterclient/ui/widgets/fontAwesomeChanger.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/co_action_component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/utils/text_utils.dart';
import 'package:jvx_flutterclient/utils/uidata.dart';
import 'package:jvx_flutterclient/utils/globals.dart' as globals;
import 'package:tinycolor/tinycolor.dart';

class CoButtonWidget extends CoActionComponentWidget {
  CoButtonWidget({ComponentModel componentModel, Key key})
      : super(componentModel: componentModel, key: key);

  @override
  State<StatefulWidget> createState() => CoButtonWidgetState();
}

class CoButtonWidgetState extends CoActionComponentWidgetState<CoButtonWidget> {
  String text = '';
  Widget icon;
  String textStyle;
  bool network = false;

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
              if (strinArr[3] != null) {
                network = strinArr[3].toLowerCase() == 'true';
              }
            }
            if (network) {
              icon = Image.network(
                globals.baseUrl + strinArr[0],
                width: size.width,
                height: size.height,
                color: !this.enabled ? Colors.grey.shade500 : null,
              );
            } else {
              icon = Image.memory(
                utf8.base64Decode(globals.files[strinArr[0]]),
                width: size.width,
                height: size.height,
                color: !this.enabled ? Colors.grey.shade500 : null,
              );
            }

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
  void initState() {
    super.initState();
    this.updateProperties(widget.componentModel.currentChangedComponent);
    widget.componentModel.componentState = this;
    widget.componentModel.addListener(() =>
        this.updateProperties(widget.componentModel.currentChangedComponent));
  }

  @override
  Widget build(BuildContext context) {
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
