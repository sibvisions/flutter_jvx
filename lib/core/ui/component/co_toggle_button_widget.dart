import 'dart:convert' as utf8;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/core/models/api/request/press_button.dart';
import 'package:jvx_flutterclient/core/models/api/so_action.dart';
import 'package:jvx_flutterclient/core/services/remote/bloc/api_bloc.dart';
import 'package:jvx_flutterclient/core/ui/widgets/custom/custom_toggle_button.dart';
import 'package:jvx_flutterclient/core/utils/app/text_utils.dart';

import '../../../injection_container.dart';
import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../utils/theme/theme_manager.dart';
import '../widgets/util/fontAwesomeChanger.dart';
import 'co_action_component_widget.dart';
import 'component_model.dart';

class CoToggleButtonWidget extends CoActionComponentWidget {
  CoToggleButtonWidget({ComponentModel componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoToggleButtonWidgetState();
}

class CoToggleButtonWidgetState extends CoActionComponentWidgetState {
  String text = '';
  Widget icon;
  String textStyle;
  bool network = false;
  Size size = Size(16, 16);
  String image;

  Color _disabledColor;
  bool _selected = false;

  @override
  updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    text = changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
    textStyle = changedComponent.getProperty<String>(
        ComponentProperty.STYLE, textStyle);

    image = changedComponent.getProperty<String>(ComponentProperty.IMAGE);
    if (image != null) {
      if (checkFontAwesome(image)) {
        icon = convertFontAwesomeTextToIcon(image,
            sl<ThemeManager>().themeData.primaryTextTheme.bodyText1.color);
      } else {
        List strinArr = List<String>.from(image.split(','));
        if (kIsWeb) {
          if (strinArr.length >= 3 &&
              double.tryParse(strinArr[1]) != null &&
              double.tryParse(strinArr[2]) != null) {
            size = Size(double.parse(strinArr[1]), double.parse(strinArr[2]));
            if (strinArr[3] != null) {
              network = strinArr[3].toLowerCase() == 'true';
            }

            if (this.appState.files.containsKey(strinArr[0])) {
              setState(() => icon = Image.memory(
                    utf8.base64Decode(this.appState.files[strinArr[0]]),
                    width: size.width,
                    height: size.height,
                    color: !this.enabled ? Colors.grey.shade500 : null,
                  ));
            } else if (network) {
              setState(() => icon = Image.network(
                    this.appState.baseUrl + strinArr[0],
                    width: size.width,
                    height: size.height,
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
            setState(() => icon = Image.memory(
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
    setState(() {
      this._selected = !_selected;
    });

    TextUtils.unfocusCurrentTextfield(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      PressButton pressButton =
          PressButton(SoAction(componentId: this.name, label: this.text), this.appState.clientId);
      BlocProvider.of<ApiBloc>(context).add(pressButton);
    });
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
                    : Theme.of(context).primaryTextTheme.bodyText1.color));

    if (text?.isNotEmpty ?? true) {
      if (image != null) {
        child = Row(
          children: <Widget>[
            icon != null
                ? icon
                : SizedBox(width: size.width, height: size.height),
            SizedBox(width: 10),
            textWidget
          ],
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

    _disabledColor = Colors.grey;

    return CustomToggleButton(
      background: this._selected ? this.background : _disabledColor,
      child: child,
      enabled: this.enabled,
      minWidth: minWidth,
      onPressed: buttonPressed,
      padding: padding,
      shape: this.appState?.applicationStyle?.buttonShape,
    );
  }
}
