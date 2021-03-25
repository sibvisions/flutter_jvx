import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/src/util/app/text_utils.dart';
import 'package:flutterclient/src/util/color/color_extension.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../component_widget.dart';
import 'models/popup_menu_button_component_model.dart';
import 'models/popup_menu_component_model.dart';

class CoPopupMenuButtonWidget extends ComponentWidget {
  final PopupMenuButtonComponentModel componentModel;
  CoPopupMenuButtonWidget({Key? key, required this.componentModel})
      : super(key: key, componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoPopupMenuButtonWidgetState();
}

class CoPopupMenuButtonWidgetState
    extends ComponentWidgetState<CoPopupMenuButtonWidget> {
  void buttonPressed(BuildContext context) {
    if (widget.componentModel.defaultMenuItem != null) {
      valueChanged(widget.componentModel.name);
    } else {
      _showPopupMenu(context);
    }
  }

  void valueChanged(dynamic value) {
    TextUtils.unfocusCurrentTextfield(context);

    widget.componentModel.onAction(context, value);
  }

  PopupMenuButton<String> _getPopupMenu(ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      onSelected: (String item) {
        valueChanged(item);
      },
      itemBuilder: (BuildContext context) {
        return (widget.componentModel.menu?.componentModel
                as PopupMenuComponentModel)
            .menuItems;
      },
      padding: EdgeInsets.only(bottom: 8, left: 16),
      icon: FaIcon(
        FontAwesomeIcons.sortDown,
        color: Theme.of(context).primaryColor.textColor(),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) async {
    List<PopupMenuItem<String>> menuItems =
        (widget.componentModel.menu?.componentModel as PopupMenuComponentModel)
            .menuItems;

    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final RenderBox button = context.findRenderObject() as RenderBox;
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
    ).then<void>((String? newValue) {
      if (newValue != null) valueChanged(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    Widget child;
    Widget textWidget = new Text(widget.componentModel.text ?? "",
        style: TextStyle(
            fontSize: widget.componentModel.fontStyle.fontSize,
            color: Theme.of(context).primaryColor.textColor()));

    if (widget.componentModel.text?.isNotEmpty ?? true) {
      if (widget.componentModel.icon != null) {
        child = Row(
          children: <Widget>[
            widget.componentModel.icon!,
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

    return Container(
      margin: EdgeInsets.all(4),
      child: ButtonTheme(
          minWidth: 44,
          child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => widget.componentModel.enabled
                    ? buttonPressed(context)
                    : null,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                    shape: MaterialStateProperty.all(widget
                        .componentModel
                        .appState
                        .applicationStyle
                        ?.buttonShape as OutlinedBorder),
                    overlayColor: MaterialStateProperty.all(
                        widget.componentModel.background)),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                          // fit: FlexFit.loose,
                          flex: 5,
                          child: Center(child: child)),
                      Flexible(
                          // fit: FlexFit.loose,
                          flex: 5,
                          child: _getPopupMenu(colorScheme)),
                    ]),
              ))),
    );
  }
}
