import 'dart:convert' as utf8;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../injection_container.dart';
import '../../models/api/requests/press_button_request.dart';
import '../../services/remote/cubit/api_cubit.dart';
import '../../util/app/text_utils.dart';
import '../../util/color/color_extension.dart';
import '../../util/icon/font_awesome_changer.dart';
import '../../util/theme/theme_manager.dart';
import '../widgets/custom/custom_toggle_button.dart';
import 'co_action_component_widget.dart';
import 'model/toggle_button_component_model.dart';

class CoToggleButtonWidget extends CoActionComponentWidget {
  final ToggleButtonComponentModel componentModel;

  CoToggleButtonWidget({required this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoToggleButtonWidgetState();
}

class CoToggleButtonWidgetState
    extends CoActionComponentWidgetState<CoToggleButtonWidget> {
  void updateImage() {
    if (widget.componentModel.image != null) {
      if (checkFontAwesome(widget.componentModel.image!)) {
        widget.componentModel.icon = convertFontAwesomeTextToIcon(
            widget.componentModel.image!,
            sl<ThemeManager>().value.primaryColor.textColor());
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
                    utf8.base64Decode(widget.componentModel.appState.fileConfig
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

  void buttonPressed() {
    setState(() {
      widget.componentModel.selected = !widget.componentModel.selected;
    });

    TextUtils.unfocusCurrentTextfield(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      PressButtonRequest pressButton = PressButtonRequest(
          componentId: widget.componentModel.name,
          classNameEventSourceRef:
              widget.componentModel.classNameEventSourceRef,
          clientId:
              widget.componentModel.appState.applicationMetaData!.clientId);

      sl<ApiCubit>().pressButton(pressButton);
    });
  }

  Color _getTextColor() {
    if (widget.componentModel.enabled &&
        widget.componentModel.isForegroundSet) {
      return widget.componentModel.foreground;
    } else if (widget.componentModel.enabled) {
      return Theme.of(context).primaryColor.textColor();
    } else {
      return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    Widget textWidget = new Text(widget.componentModel.text,
        style: TextStyle(
            fontSize: widget.componentModel.fontStyle.fontSize,
            color: _getTextColor()));

    if (widget.componentModel.text.isNotEmpty) {
      if (widget.componentModel.image != null) {
        child = Row(
          children: <Widget>[
            widget.componentModel.icon ??
                SizedBox(
                    width: widget.componentModel.iconSize.width,
                    height: widget.componentModel.iconSize.height),
            SizedBox(width: 10),
            textWidget
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

    widget.componentModel.disabledColor = Colors.orange;

    return CustomToggleButton(
      background: widget.componentModel.selected
          ? widget.componentModel.background
          : widget.componentModel.disabledColor,
      child: child,
      enabled: widget.componentModel.enabled,
      minWidth: minWidth,
      onPressed: buttonPressed,
      padding: padding,
      shape: widget.componentModel.appState.applicationStyle?.buttonShape,
    );
  }
}
