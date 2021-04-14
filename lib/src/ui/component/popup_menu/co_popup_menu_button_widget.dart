import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../util/app/text_utils.dart';
import '../../../util/color/color_extension.dart';
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

    widget.componentModel.onAction(
        context, value, widget.componentModel.classNameEventSourceRef);
  }

  PopupMenuButton<String> _getPopupMenu(ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      onSelected: (String item) {
        valueChanged(item);
      },
      itemBuilder: (BuildContext context) {
        if (widget.componentModel.enabled) {
          return (widget.componentModel.menu?.componentModel
                  as PopupMenuComponentModel)
              .menuItems;
        } else {
          return <PopupMenuEntry<String>>[];
        }
      },
      padding: EdgeInsets.only(bottom: 8),
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

  _getCurrentTextColor() {
    if (!widget.componentModel.enabled) {
      return Colors.grey.shade500;
    } else if (widget.componentModel.isForegroundSet) {
      return widget.componentModel.foreground;
    } else {
      return Theme.of(context).primaryColor.textColor();
    }
  }

  _getSplashColor() {
    if (widget.componentModel.isBackgroundSet) {
      return widget.componentModel.background.withOpacity(widget.componentModel
              .appState.applicationStyle?.opacity?.controlsOpacity ??
          1.0);
    } else {
      return Colors.black.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    Widget textWidget = new Text(widget.componentModel.text,
        style: TextStyle(
            fontSize: widget.componentModel.fontStyle.fontSize,
            color: _getCurrentTextColor()));

    if (widget.componentModel.text.isNotEmpty) {
      if (widget.componentModel.icon != null) {
        if (widget.componentModel.horizontalTextPosition != TextAlign.left)
          child = Row(
            children: <Widget>[
              widget.componentModel.icon!,
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
              widget.componentModel.icon!,
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
    EdgeInsets padding = EdgeInsets.zero;

    if (widget.componentModel.isPreferredSizeSet &&
        widget.componentModel.preferredSize!.width < minWidth) {
      padding = EdgeInsets.symmetric(horizontal: 0);
      minWidth = widget.componentModel.preferredSize!.width;
    }

    return Container(
      margin: widget.componentModel.margin,
      child: ButtonTheme(
        minWidth: minWidth,
        padding: padding,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
              onPressed: () =>
                  widget.componentModel.enabled ? buttonPressed(context) : null,
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                  shape: MaterialStateProperty.all(widget
                      .componentModel
                      .appState
                      .applicationStyle
                      ?.buttonShape as OutlinedBorder),
                  overlayColor: MaterialStateProperty.all(_getSplashColor()),
                  padding: MaterialStateProperty.all(EdgeInsets.zero)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            child: Padding(
                                padding: EdgeInsets.only(left: minWidth / 2),
                                child: child))),
                    Container(
                        width: minWidth,
                        height: minWidth,
                        child: _getPopupMenu(Theme.of(context).colorScheme)),
                  ])),
        ),
      ),
    );
  }
}
