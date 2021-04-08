import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/api/so_action.dart';
import '../../../utils/app/text_utils.dart';
import '../component_widget.dart';
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
  void buttonPressed(BuildContext context) {
    if (widget.componentModel.defaultMenuItem != null) {
      valueChanged(widget.componentModel.name);
    } else {
      _showPopupMenu(context);
    }
  }

  void valueChanged(dynamic value) {
    TextUtils.unfocusCurrentTextfield(context);

    if (widget.componentModel.onAction != null)
      widget.componentModel
          .onAction(context, SoAction(componentId: value, label: null));
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
      padding: EdgeInsets.only(bottom: 8, right: 16),
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
    widget.componentModel.fontStyle = DefaultTextStyle.of(context)
        .style
        .merge(widget.componentModel.fontStyle);
    if (widget.componentModel.text?.isNotEmpty ?? true) {
      if (widget.componentModel.icon != null) {
        Widget icon = widget.componentModel.icon != null
            ? widget.componentModel.icon
            : SizedBox(
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

    return Container(
      margin: widget.componentModel.margin,
      child: ButtonTheme(
          minWidth: minWidth,
          padding: padding,
          child: RaisedButton(
            onPressed: () =>
                widget.componentModel.enabled ? buttonPressed(context) : null,
            color: Theme.of(context).primaryColor,
            shape: widget.componentModel.appState.applicationStyle?.buttonShape,
            child: SizedBox(
                height: 50,
                child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                          // fit: FlexFit.loose,
                          flex: 4,
                          child: Center(child: child)),
                      Flexible(
                          // fit: FlexFit.loose,
                          flex: 1,
                          child: _getPopupMenu(Theme.of(context).colorScheme)),
                    ])),
            splashColor: widget.componentModel.background,
          )),
    );
  }
}
