import 'dart:io';
import 'dart:convert' as utf8;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_creator.dart';
import '../../model/api/request/press_button.dart';
import '../../model/api/request/reload.dart';
import '../../model/api/request/request.dart';
import '../widgets/fontAwesomeChanger.dart';
import 'co_popup_menu.dart';
import '../../utils/uidata.dart';
import '../../utils/text_utils.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import 'i_component.dart';
import 'component.dart';
import '../../utils/globals.dart' as globals;
import '../../model/so_action.dart';

class CoPopupMenuButton extends Component implements IComponent {
  String text;
  bool eventAction = false;
  CoPopupMenu menu;
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

  CoPopupMenuButton(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  factory CoPopupMenuButton.withCompContext(ComponentContext componentContext) {
    return CoPopupMenuButton(
        componentContext.globalKey, componentContext.context);
  }

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
              );
            } else {
              icon = Image.memory(utf8.base64Decode(globals.files[strinArr[0]]),
                  width: size.width, height: size.height);
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
            );

            BlocProvider.of<ApiBloc>(context)
                .dispatch(Reload(requestType: RequestType.RELOAD));
          }
        }
      }
    }
  }

  void buttonPressed() {
    if (defaultMenuItem != null) {
      valueChanged(this.name);
    } else {
      _showPopupMenu();
    }
  }

  void valueChanged(dynamic value) {
    TextUtils.unfocusCurrentTextfield(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      PressButton pressButton =
          PressButton(SoAction(componentId: value, label: null));
      BlocProvider.of<ApiBloc>(context).dispatch(pressButton);
    });
  }

  PopupMenuButton<String> _getPopupMenu(ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      onSelected: (String item) {
        valueChanged(item);
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuItem<String>> menuItems =
            new List<PopupMenuItem<String>>();
        menu?.menuItems?.forEach((i) {
          menuItems.add(PopupMenuItem<String>(
              value: i.name, child: Text(i.text), enabled: i.enabled));
        });
        return menuItems;
      },
      padding: EdgeInsets.only(bottom: 8, left: 16),
      icon: FaIcon(
        FontAwesomeIcons.sortDown,
        color: UIData.textColor,
      ),
    );
  }

  void _showPopupMenu() async {
    List<PopupMenuItem<String>> menuItems = new List<PopupMenuItem<String>>();
    menu?.menuItems?.forEach((i) {
      menuItems.add(PopupMenuItem<String>(
        value: i.name,
        child: Text(i.text),
        enabled: i.enabled,
      ));
    });

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RenderBox button = this.componentId.currentContext.findRenderObject();
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
      valueChanged(newValue);
    });
  }

  @override
  Widget getWidget() {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    Widget child;
    Widget textWidget = new Text(text != null ? text : "",
        style: TextStyle(fontSize: style.fontSize, color: UIData.textColor));

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
          height: 40,
          child: RaisedButton(
              key: this.componentId,
              onPressed: this.enabled ? buttonPressed : null,
              color: this.background != null
                  ? this.background
                  : UIData.ui_kit_color_2[600],
              elevation: 2,
              shape: globals.applicationStyle.buttonShape,
              child: Row(children: <Widget>[
                Expanded(child: Center(child: child)),
                _getPopupMenu(colorScheme),
              ])),
        ),
        splashColor: this.background,
      ),
    );
  }
}
