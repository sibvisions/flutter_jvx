import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../flutterclient.dart';
import '../../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../../models/state/app_state.dart';

class WebMenuListWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool groupedMenuMode;
  final AppState appState;
  final Function(MenuItem) onMenuItemPressed;

  const WebMenuListWidget({
    Key? key,
    required this.menuItems,
    required this.appState,
    required this.onMenuItemPressed,
    this.groupedMenuMode = true,
  }) : super(key: key);

  @override
  _WebMenuListWidgetState createState() => _WebMenuListWidgetState();
}

class _WebMenuListWidgetState extends State<WebMenuListWidget> {
  int _selected = -1;

  void _onTap(MenuItem item) {
    setState(() {
      _selected = widget.menuItems.indexOf(item);
    });

    widget.onMenuItemPressed(item);
  }

  Color get _sideMenuColor {
    if (widget.appState.applicationStyle?.sideMenuStyle?.textColor != null) {
      return widget.appState.applicationStyle!.sideMenuStyle!.textColor!;
    } else {
      return Color(0xff6a6a6a);
    }
  }

  Color get _hoverColor {
    if (widget.appState.applicationStyle?.sideMenuStyle?.color != null) {
      return widget.appState.applicationStyle!.sideMenuStyle!.color!
          .withOpacity(0.95);
    } else {
      return Color(0xff171717).withOpacity(0.95);
    }
  }

  Color _iconColor(MenuItem item) {
    if (widget.appState.applicationStyle?.sideMenuStyle != null) {
      if (widget.menuItems.indexOf(item) == _selected) {
        if (widget.appState.applicationStyle?.sideMenuStyle?.selectionColor !=
            null) {
          return widget
              .appState.applicationStyle!.sideMenuStyle!.selectionColor!;
        } else {
          return Color(0xFF2196F3);
        }
      } else {
        if (widget.appState.applicationStyle?.sideMenuStyle?.textColor !=
            null) {
          return widget.appState.applicationStyle!.sideMenuStyle!.textColor!;
        } else {
          return Color(0xFFd9d9d9);
        }
      }
    } else {
      return Colors.white;
    }
  }

  List<Widget> _buildListTiles(BuildContext context) {
    final groupedMap = groupBy(widget.menuItems, (MenuItem obj) => obj.group);

    List<Widget> tiles = <Widget>[];

    groupedMap.forEach((group, groupedItems) {
      Widget heading = Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12.0, top: 10.0),
        height: 25,
        child: Text(
          group,
          style: TextStyle(color: _sideMenuColor, fontWeight: FontWeight.w500),
        ),
      );

      Widget card = Container(
        child: Column(
          children: _buildTiles(groupedItems),
        ),
      );

      if (widget.groupedMenuMode) {
        tiles.add(Column(
          children: [heading, card],
        ));
      } else {
        tiles.add(card);
      }
    });

    return tiles;
  }

  List<Widget> _buildTiles(List<MenuItem> groupedItems) {
    List<Widget> widgets = <Widget>[];

    for (final item in groupedItems) {
      Widget tile = Container(
        margin: const EdgeInsets.only(left: 5),
        child: Tooltip(
          waitDuration: const Duration(milliseconds: 500),
          message: item.text,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              hoverColor: _hoverColor,
              onTap: () => _onTap(item),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 34,
                    child: Center(
                      child: Row(
                        children: [
                          if (item.image != null && item.image!.isNotEmpty)
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: CustomIcon(
                                image: item.image!.split(',')[0],
                                prefferedSize: Size(16, 16),
                                color: _iconColor(item),
                              ),
                            )
                          else
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: FaIcon(
                                FontAwesomeIcons.clone,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          Container(
                            constraints:
                                BoxConstraints(minWidth: 100, maxWidth: 180),
                            child: Text(
                              item.text,
                              style: TextStyle(
                                  color: _iconColor(item),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

      widgets.add(tile);

      if (groupedItems.indexOf(item) < groupedItems.length - 1) {
        widgets.add(Divider(
          height: 2,
          indent: 15,
          endIndent: 15,
        ));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff171717).withOpacity(0.95),
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildListTiles(context),
        ),
      ),
    );
  }
}
