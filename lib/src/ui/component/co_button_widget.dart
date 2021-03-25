import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../util/color/color_extension.dart';
import '../../util/icon/font_awesome_changer.dart';
import '../widgets/dialog/loading_indicator_dialog.dart';
import 'co_action_component_widget.dart';
import 'model/button_component_model.dart';

class CoButtonWidget extends CoActionComponentWidget {
  final ButtonComponentModel componentModel;

  CoButtonWidget({required this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoButtonWidgetState();
}

class CoButtonWidgetState extends CoActionComponentWidgetState<CoButtonWidget> {
  void updateImage() {
    if (widget.componentModel.image != null) {
      if (checkFontAwesome(widget.componentModel.image!)) {
        widget.componentModel.icon = convertFontAwesomeTextToIcon(
            widget.componentModel.image!,
            !widget.componentModel.enabled
                ? Colors.grey.shade500
                : Theme.of(context).primaryColor.textColor());
      } else {
        List strinArr =
            List<String>.from(widget.componentModel.image!.split(','));
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

            if (widget.componentModel.appState.fileConfig.files
                .containsKey(strinArr[0])) {
              setState(() => widget.componentModel.icon = Image.memory(
                    base64Decode(widget.componentModel.appState.fileConfig
                        .files[strinArr[0]]!),
                    width: widget.componentModel.iconSize.width,
                    height: widget.componentModel.iconSize.height,
                    color: !widget.componentModel.enabled
                        ? Colors.grey.shade500
                        : null,
                  ));
            } else if (widget.componentModel.network) {
              setState(() => widget.componentModel.icon = Image.network(
                    widget.componentModel.appState.serverConfig!.baseUrl +
                        strinArr[0],
                    width: widget.componentModel.iconSize.width,
                    height: widget.componentModel.iconSize.height,
                    color: !widget.componentModel.enabled
                        ? Colors.grey.shade500
                        : null,
                  ));
            }
          }
        } else {
          File file = File(
              '${widget.componentModel.appState.baseDirectory}${strinArr[0]}');
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
    Widget textWidget = new Text(widget.componentModel.text ?? '',
        style: TextStyle(
            fontSize: widget.componentModel.fontStyle.fontSize,
            color: !widget.componentModel.enabled
                ? Colors.grey.shade500
                : widget.componentModel.foreground != null
                    ? widget.componentModel.foreground
                    : Theme.of(context).primaryColor.textColor()));

    if (widget.componentModel.text?.isNotEmpty ?? true) {
      if (widget.componentModel.image != null) {
        Widget icon = widget.componentModel.icon ??
            SizedBox(
                width: widget.componentModel.iconSize.width,
                height: widget.componentModel.iconSize.height);
        if (widget.componentModel.horizontalTextPosition != TextAlign.left)
          child = Row(
            children: <Widget>[
              icon,
              SizedBox(width: widget.componentModel.iconPadding),
              textWidget
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          );
        else
          child = Row(
            children: <Widget>[
              textWidget,
              SizedBox(width: widget.componentModel.iconPadding),
              icon,
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          );
      } else {
        child = textWidget;
      }
    } else if (widget.componentModel.icon != null) {
      child = widget.componentModel.icon!;
    } else {
      child = textWidget;
    }

    double minWidth = 44;
    EdgeInsets? padding;

    if (widget.componentModel.isPreferredSizeSet &&
        widget.componentModel.preferredSize!.width < minWidth) {
      padding = EdgeInsets.symmetric(horizontal: 0);
      minWidth = widget.componentModel.preferredSize!.width;
    }

    if (widget.componentModel.style == 'hyperlink') {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        margin: EdgeInsets.all(4),
        child: GestureDetector(
          onTap: () {
            if (widget.componentModel.enabled) {
              widget.componentModel
                  .onAction(context, widget.componentModel.name!);
            }
          },
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                widget.componentModel.text ?? '',
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
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.componentModel.enabled) {
                      if (widget.componentModel.classNameEventSourceRef ==
                          "OfflineButton") {
                        showLoadingIndicator(context);
                      }

                      widget.componentModel
                          .onAction(context, widget.componentModel.name!);
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          widget.componentModel.background ??
                              Theme.of(context).primaryColor),
                      elevation: MaterialStateProperty.all(2),
                      overlayColor: MaterialStateProperty.all(
                          widget.componentModel.background?.withOpacity(0.1) ??
                              Theme.of(context).primaryColor)),
                  child: child,
                ))));
  }
}
