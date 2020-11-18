import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/core/utils/theme/theme_manager.dart';

import '../../../../injection_container.dart';
import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import '../../../models/api/request/press_button.dart';
import '../../../models/api/so_action.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/app/text_utils.dart';
import '../../widgets/util/fontAwesomeChanger.dart';
import '../component_widget.dart';
import 'co_popup_menu_widget.dart';
import 'popup_button_component_model.dart';
import 'popup_component_model.dart';

class CoPopupMenuButtonWidget extends ComponentWidget {
  CoPopupMenuButtonWidget({Key key, PopupButtonComponentModel componentModel})
      : super(key: key, componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoPopupMenuButtonWidgetState();
}

class CoPopupMenuButtonWidgetState
    extends ComponentWidgetState<CoPopupMenuButtonWidget> {
  String text;
  bool eventAction = false;
  CoPopupMenuWidget menu;
  String defaultMenuItem;
  Widget icon;
  bool network = false;

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(TextUtils.averageCharactersTextField,
            Theme.of(context).textTheme.button)
        .toDouble();
    return Size(width, 50);
  }

  @override
  get minimumSize {
    return Size(50, 50);
  }

  @override
  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = changedProperties.getProperty<String>(ComponentProperty.TEXT, text);
    eventAction = changedProperties.getProperty<bool>(
        ComponentProperty.EVENT_ACTION, eventAction);
    defaultMenuItem = changedProperties.getProperty<String>(
        ComponentProperty.DEFAULT_MENU_ITEM, defaultMenuItem);

    String image =
        changedProperties.getProperty<String>(ComponentProperty.IMAGE);
    if (image != null) {
      if (checkFontAwesome(image)) {
        icon = convertFontAwesomeTextToIcon(image,
            sl<ThemeManager>().themeData.primaryTextTheme.bodyText1.color);
      } else {
        List strinArr = List<String>.from(image.split(','));
        if (kIsWeb) {
          if (appState.files.containsKey(strinArr[0])) {
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
                this.appState.baseUrl + strinArr[0],
                width: size.width,
                height: size.height,
              );
            } else {
              icon = Image.memory(
                  base64Decode(this.appState.files[strinArr[0]]),
                  width: size.width,
                  height: size.height);
            }

            // BlocProvider.of<ApiBloc>(context)
            //     .add(Reload(requestType: RequestType.RELOAD));
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

            // BlocProvider.of<ApiBloc>(context)
            //     .add(Reload(requestType: RequestType.RELOAD));
          }
        }
      }
    }
  }

  void buttonPressed(BuildContext context) {
    if (defaultMenuItem != null) {
      valueChanged(this.name);
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
        return ((widget.componentModel as PopupButtonComponentModel)
                .menu
                ?.componentModel as PopupComponentModel)
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
        ((widget.componentModel as PopupButtonComponentModel)
                .menu
                ?.componentModel as PopupComponentModel)
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
    Widget textWidget = new Text(text != null ? text : "",
        style: TextStyle(
            fontSize: style.fontSize,
            color: Theme.of(context).primaryTextTheme.bodyText1.color));

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

    return Container(
      margin: EdgeInsets.all(4),
      child: ButtonTheme(
          minWidth: 44,
          child: SizedBox(
              height: 50,
              child: RaisedButton(
                onPressed: () => this.enabled ? buttonPressed(context) : null,
                color: Theme.of(context).primaryColor,
                shape: this.appState.applicationStyle?.buttonShape,
                child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  Flexible(
                      fit: FlexFit.loose, flex: 5, child: Center(child: child)),
                  Flexible(
                      fit: FlexFit.loose,
                      flex: 5,
                      child: _getPopupMenu(colorScheme)),
                ]),
                splashColor: this.background,
              ))),
    );
  }
}
