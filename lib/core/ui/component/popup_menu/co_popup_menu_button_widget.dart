import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../injection_container.dart';
import '../../../models/api/component/changed_component.dart';
import '../../../models/api/request/press_button.dart';
import '../../../models/api/so_action.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/app/text_utils.dart';
import '../../../utils/theme/theme_manager.dart';
import '../../widgets/util/fontAwesomeChanger.dart';
import '../component_widget.dart';
import 'co_popup_menu_widget.dart';
import 'models/popup_menu_button_component_model.dart';
import 'models/popup_menu_component_model.dart';

class CoPopupMenuButtonWidget extends ComponentWidget {
  final PopupMenuButtonComponentModel componentModel;
  CoPopupMenuButtonWidget({Key key, this.componentModel})
      : super(key: key, componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoPopupMenuButtonWidgetState();
}

class CoPopupMenuButtonWidgetState
    extends ComponentWidgetState<CoPopupMenuButtonWidget> {
  CoPopupMenuWidget menu;
  Widget icon;
  bool network = false;

  @override
  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);

    if (widget.componentModel.image != null) {
      if (checkFontAwesome(widget.componentModel.image)) {
        icon = convertFontAwesomeTextToIcon(widget.componentModel.image,
            sl<ThemeManager>().themeData.primaryTextTheme.bodyText1.color);
      } else {
        List strinArr =
            List<String>.from(widget.componentModel.image.split(','));
        if (kIsWeb) {
          if (appState.files.containsKey(strinArr[0])) {
            if (strinArr.length >= 3 &&
                double.tryParse(strinArr[1]) != null &&
                double.tryParse(strinArr[2]) != null) {
              widget.componentModel.iconSize =
                  Size(double.parse(strinArr[1]), double.parse(strinArr[2]));

              if (strinArr[3] != null) {
                network = strinArr[3].toLowerCase() == 'true';
              }
            }
            if (network) {
              icon = Image.network(
                this.appState.baseUrl + strinArr[0],
                width: widget.componentModel.iconSize.width,
                height: widget.componentModel.iconSize.height,
              );
            } else {
              icon = Image.memory(
                  base64Decode(this.appState.files[strinArr[0]]),
                  width: widget.componentModel.iconSize.width,
                  height: widget.componentModel.iconSize.height);
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
            icon = Image.memory(
              file.readAsBytesSync(),
              width: size.width,
              height: size.height,
            );
          }
        }
      }
    }
  }

  void buttonPressed(BuildContext context) {
    if (widget.componentModel.defaultMenuItem != null) {
      valueChanged(widget.componentModel.name);
    } else {
      _showPopupMenu(context);
    }
  }

  void valueChanged(dynamic value) {
    TextUtils.unfocusCurrentTextfield(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      PressButton pressButton = PressButton(
          SoAction(componentId: value, label: null), this.appState.clientId);
      BlocProvider.of<ApiBloc>(context).add(pressButton);
    });
  }

  PopupMenuButton<String> _getPopupMenu(ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      onSelected: (String item) {
        valueChanged(item);
      },
      itemBuilder: (BuildContext context) {
        return (widget.componentModel.menu?.componentModel
                as PopupMenuComponentModel)
            ?.menuItems;
      },
      padding: EdgeInsets.only(bottom: 8, left: 16),
      icon: FaIcon(
        FontAwesomeIcons.sortDown,
        color: Theme.of(context).primaryTextTheme.bodyText1.color,
      ),
    );
  }

  void _showPopupMenu(BuildContext context) async {
    List<PopupMenuItem<String>> menuItems =
        (widget.componentModel.menu?.componentModel as PopupMenuComponentModel)
            ?.menuItems;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RenderBox button = context.findRenderObject();
    Offset tabPosition = button.localToGlobal(Offset.zero);
    final size = button.size;
    tabPosition = Offset(
        tabPosition.dx + size.width / 2, tabPosition.dy + size.height / 2);

    await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
          tabPosition & Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size // Bigger rect, the entire screen
          ),
      items: menuItems,
    ).then<void>((String newValue) {
      if (newValue != null) valueChanged(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    Widget child;
    Widget textWidget = new Text(
        widget.componentModel.text != null ? widget.componentModel.text : "",
        style: TextStyle(
            fontSize: widget.componentModel.fontStyle.fontSize,
            color: Theme.of(context).primaryTextTheme.bodyText1.color));

    if (widget.componentModel.text?.isNotEmpty ?? true) {
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

    return Container(
      height: 50,
      child: ButtonTheme(
          minWidth: 44,
          child: SizedBox(
              child: RaisedButton(
            onPressed: () =>
                widget.componentModel.enabled ? buttonPressed(context) : null,
            color: Theme.of(context).primaryColor,
            elevation: 10,
            shape: this.appState.applicationStyle?.buttonShape,
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Flexible(
                  fit: FlexFit.loose, flex: 8, child: Center(child: child)),
              Flexible(
                  fit: FlexFit.loose,
                  flex: 2,
                  child: _getPopupMenu(colorScheme)),
            ]),
            splashColor: widget.componentModel.background,
          ))),
    );
  }
}
