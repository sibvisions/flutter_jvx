import 'dart:convert' as utf8;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinycolor/tinycolor.dart';

import '../../../injection_container.dart';
import '../../models/api/component/changed_component.dart';
import '../../models/api/request/press_button.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../../utils/app/text_utils.dart';
import '../../utils/theme/theme_manager.dart';
import '../widgets/util/fontAwesomeChanger.dart';
import 'button_component_model.dart';
import 'co_action_component_widget.dart';

class CoButtonWidget extends CoActionComponentWidget {
  final ButtonComponentModel componentModel;
  CoButtonWidget({this.componentModel}) : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoButtonWidgetState();
}

class CoButtonWidgetState extends CoActionComponentWidgetState<CoButtonWidget> {
  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);

    if (widget.componentModel.image != null) {
      if (checkFontAwesome(widget.componentModel.image)) {
        widget.componentModel.icon = convertFontAwesomeTextToIcon(
            widget.componentModel.image,
            sl<ThemeManager>().themeData.primaryTextTheme.bodyText1.color);
      } else {
        List strinArr =
            List<String>.from(widget.componentModel.image.split(','));
        if (kIsWeb) {
          if (strinArr.length >= 3 &&
              double.tryParse(strinArr[1]) != null &&
              double.tryParse(strinArr[2]) != null) {
            widget.componentModel.size =
                Size(double.parse(strinArr[1]), double.parse(strinArr[2]));
            if (strinArr[3] != null) {
              widget.componentModel.network =
                  strinArr[3].toLowerCase() == 'true';
            }

            if (this.appState.files.containsKey(strinArr[0])) {
              setState(() => widget.componentModel.icon = Image.memory(
                    utf8.base64Decode(this.appState.files[strinArr[0]]),
                    width: widget.componentModel.size.width,
                    height: widget.componentModel.size.height,
                    color: !this.enabled ? Colors.grey.shade500 : null,
                  ));
            } else if (widget.componentModel.network) {
              setState(() => widget.componentModel.icon = Image.network(
                    this.appState.baseUrl + strinArr[0],
                    width: widget.componentModel.size.width,
                    height: widget.componentModel.size.height,
                    color: !this.enabled ? Colors.grey.shade500 : null,
                  ));
            }
          }
        } else {
          File file = File('${this.appState.dir}${strinArr[0]}');
          if (file.existsSync()) {
            Size size = Size(16, 16);

            if (strinArr.length >= 3 &&
                double.tryParse(strinArr[1]) != null &&
                double.tryParse(strinArr[2]) != null)
              size = Size(double.parse(strinArr[1]), double.parse(strinArr[2]));
            setState(() => widget.componentModel.icon = Image.memory(
                  file.readAsBytesSync(),
                  width: size.width,
                  height: size.height,
                  color: !this.enabled ? Colors.grey.shade500 : null,
                ));
          }
        }
      }
    }
  }

  void buttonPressed() {
    TextUtils.unfocusCurrentTextfield(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      PressButton pressButton =
          PressButton(widget.componentModel.action, this.appState.clientId);
      BlocProvider.of<ApiBloc>(context).add(pressButton);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    Widget textWidget = new Text(
        widget.componentModel.text != null ? widget.componentModel.text : "",
        style: TextStyle(
            fontSize: style.fontSize,
            color: !this.enabled
                ? Colors.grey.shade500
                : this.foreground != null
                    ? this.foreground
                    : Theme.of(context).primaryTextTheme.bodyText1.color));

    if (widget.componentModel.text?.isNotEmpty ?? true) {
      if (widget.componentModel.image != null) {
        child = Row(
          children: <Widget>[
            widget.componentModel.icon != null
                ? widget.componentModel.icon
                : SizedBox(
                    width: widget.componentModel.size.width,
                    height: widget.componentModel.size.height),
            SizedBox(width: 10),
            textWidget
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        );
      } else {
        child = textWidget;
      }
    } else if (widget.componentModel.icon != null) {
      child = widget.componentModel.icon;
    } else {
      child = textWidget;
    }

    double minWidth = 44;
    EdgeInsets padding;

    if (this.isPreferredSizeSet && this.preferredSize.width < minWidth) {
      padding = EdgeInsets.symmetric(horizontal: 0);
      minWidth = this.preferredSize.width;
    }

    if (widget.componentModel.style == 'hyperlink') {
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
                widget.componentModel.text != null
                    ? widget.componentModel.text
                    : '',
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
            shape: this.appState.applicationStyle?.buttonShape ?? null,
            child: SizedBox(
                height: 50,
                child: RaisedButton(
                  onPressed: this.enabled ? buttonPressed : null,
                  color: this.background != null
                      ? this.background
                      : Theme.of(context).primaryColor,
                  elevation: 2,
                  disabledColor: Colors.grey.shade300,
                  child: child,
                  splashColor: this.background != null
                      ? TinyColor(this.background).darken().color
                      : Theme.of(context).primaryColor,
                ))));
  }
}
