import 'dart:convert' as utf8;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

import '../../../injection_container.dart';
import '../../utils/theme/theme_manager.dart';
import '../widgets/util/fontAwesomeChanger.dart';
import 'co_action_component_widget.dart';
import 'models/button_component_model.dart';

class CoButtonWidget extends CoActionComponentWidget {
  final ButtonComponentModel componentModel;
  CoButtonWidget({this.componentModel}) : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoButtonWidgetState();
}

class CoButtonWidgetState extends CoActionComponentWidgetState<CoButtonWidget> {
  void updateImage() {
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
            widget.componentModel.iconSize =
                Size(double.parse(strinArr[1]), double.parse(strinArr[2]));
            if (strinArr[3] != null) {
              widget.componentModel.network =
                  strinArr[3].toLowerCase() == 'true';
            }

            if (widget.componentModel.appState.files.containsKey(strinArr[0])) {
              setState(() => widget.componentModel.icon = Image.memory(
                    utf8.base64Decode(
                        widget.componentModel.appState.files[strinArr[0]]),
                    width: widget.componentModel.iconSize.width,
                    height: widget.componentModel.iconSize.height,
                    color: !widget.componentModel.enabled
                        ? Colors.grey.shade500
                        : null,
                  ));
            } else if (widget.componentModel.network) {
              setState(() => widget.componentModel.icon = Image.network(
                    widget.componentModel.appState.baseUrl + strinArr[0],
                    width: widget.componentModel.iconSize.width,
                    height: widget.componentModel.iconSize.height,
                    color: !widget.componentModel.enabled
                        ? Colors.grey.shade500
                        : null,
                  ));
            }
          }
        } else {
          File file =
              File('${widget.componentModel.appState.dir}${strinArr[0]}');
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
                  color: !widget.componentModel.enabled
                      ? Colors.grey.shade500
                      : null,
                ));
          }
        }
      }
    }
  }

  void initState() {
    super.initState();

    this.updateImage();

    widget.componentModel.addListener(() => this.updateImage());
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    Widget textWidget = new Text(
        widget.componentModel.text != null ? widget.componentModel.text : "",
        style: TextStyle(
            fontSize: widget.componentModel.fontStyle.fontSize,
            color: !widget.componentModel.enabled
                ? Colors.grey.shade500
                : widget.componentModel.foreground != null
                    ? widget.componentModel.foreground
                    : Theme.of(context).primaryTextTheme.bodyText1.color));

    if (widget.componentModel.text?.isNotEmpty ?? true) {
      if (widget.componentModel.image != null) {
        child = Row(
          children: <Widget>[
            widget.componentModel.icon != null
                ? widget.componentModel.icon
                : SizedBox(
                    width: widget.componentModel.iconSize.width,
                    height: widget.componentModel.iconSize.height),
            SizedBox(width: widget.componentModel.iconPadding),
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

    if (widget.componentModel.isPreferredSizeSet &&
        widget.componentModel.preferredSize.width < minWidth) {
      padding = EdgeInsets.symmetric(horizontal: 0);
      minWidth = widget.componentModel.preferredSize.width;
    }

    if (widget.componentModel.style == 'hyperlink') {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        margin: EdgeInsets.all(4),
        child: GestureDetector(
          onTap: () {
            widget.componentModel.enabled
                ? widget.componentModel.onAction(widget.componentModel.action)
                : null;
          },
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                widget.componentModel.text != null
                    ? widget.componentModel.text
                    : '',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: widget.componentModel.fontStyle.fontSize,
                    color: !widget.componentModel.enabled
                        ? Colors.grey.shade500
                        : widget.componentModel.foreground != null
                            ? widget.componentModel.foreground
                            : Colors.blue),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
        margin: widget.componentModel.margin,
        child: ButtonTheme(
            minWidth: minWidth,
            padding: padding,
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            shape:
                widget.componentModel.appState.applicationStyle?.buttonShape ??
                    null,
            child: SizedBox(
                height: 50,
                child: RaisedButton(
                  onPressed: widget.componentModel.enabled
                      ? () {
                          widget.componentModel
                              .onAction(widget.componentModel.action);
                        }
                      : null,
                  color: widget.componentModel.background != null
                      ? widget.componentModel.background
                      : Theme.of(context).primaryColor,
                  elevation: 2,
                  disabledColor: Colors.grey.shade300,
                  child: child,
                  splashColor: widget.componentModel.background != null
                      ? TinyColor(widget.componentModel.background)
                          .darken()
                          .color
                      : Theme.of(context).primaryColor,
                ))));
  }
}
