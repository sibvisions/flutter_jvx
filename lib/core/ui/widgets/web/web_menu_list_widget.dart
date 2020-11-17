import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinycolor/tinycolor.dart';

import '../../../models/api/response/menu_item.dart';
import '../../../models/app/app_state.dart';
import '../custom/custom_icon.dart';

class WebMenuListWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool groupedMenuMode;
  final AppState appState;
  final Function onPressed;

  WebMenuListWidget(
      {Key key,
      @required this.menuItems,
      this.groupedMenuMode = true,
      @required this.appState,
      @required this.onPressed})
      : super(key: key);

  @override
  _WebMenuListWidgetState createState() => _WebMenuListWidgetState();
}

class _WebMenuListWidgetState extends State<WebMenuListWidget> {
  MenuItem selectedMenuItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildListTiles(context),
          ),
        ),
      ),
    );
  }

  void _onTap(MenuItem menuItem) {
    setState(() {
      this.selectedMenuItem = menuItem;
    });
    widget.onPressed(menuItem);
  }

  List<Widget> _buildListTiles(BuildContext context) {
    var newMap = groupBy(this.widget.menuItems, (obj) => obj.group);

    List<Widget> tiles = <Widget>[];

    newMap.forEach((k, v) {
      Widget heading = Container(
        alignment: Alignment.centerLeft,
        margin: new EdgeInsets.only(left: 12.0, top: 10.0),
        height: 25,
        child: Text(
          k,
          style: TextStyle(
              color: (widget.appState.applicationStyle != null &&
                      widget.appState.applicationStyle
                              ?.sideMenuGroupTextColor !=
                          null)
                  ? widget.appState.applicationStyle?.sideMenuGroupTextColor
                  : Color(0xff6a6a6a),
              fontWeight: FontWeight.w500),
        ),
      );

      Widget card = Container(
          child: Column(
        children: _buildTiles(v),
      ));

      if (widget.groupedMenuMode) {
        tiles.add(Column(
          children: [
            heading,
            card,
          ],
        ));
      } else {
        tiles.add(card);
      }
    });

    return tiles;
  }

  List<Widget> _buildTiles(List<MenuItem> v) {
    List<Widget> widgets = <Widget>[];

    v.forEach((MenuItem mItem) {
      Widget tile = Container(
          margin: EdgeInsets.only(left: 5),
          child: Tooltip(
              waitDuration: Duration(milliseconds: 500),
              message: mItem.text,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  hoverColor: TinyColor(
                    (widget.appState.applicationStyle != null &&
                            widget.appState.applicationStyle?.sideMenuColor !=
                                null)
                        ? widget.appState?.applicationStyle?.sideMenuColor
                            ?.withOpacity(0.95)
                        : Color(0xff171717).withOpacity(0.95),
                  ).lighten().color,
                  onTap: () => _onTap(mItem),
                  child: Column(children: <Widget>[
                    Container(
                      height: 34,
                      child: Center(
                        child: Row(
                          children: [
                            mItem.image != null
                                ? new CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: CustomIcon(
                                      image: mItem.image,
                                      size: Size(16, 16),
                                      color: mItem == this.selectedMenuItem
                                          ? (widget.appState.applicationStyle !=
                                                      null &&
                                                  widget
                                                          .appState
                                                          .applicationStyle
                                                          .sideMenuSelectionColor !=
                                                      null)
                                              ? widget.appState.applicationStyle
                                                  .sideMenuSelectionColor
                                              : Color(0xFF2196F3)
                                          : (widget.appState.applicationStyle !=
                                                      null &&
                                                  widget
                                                          .appState
                                                          .applicationStyle
                                                          .sideMenuTextColor !=
                                                      null)
                                              ? widget.appState.applicationStyle
                                                  .sideMenuTextColor
                                              : Color(0xFFd9d9d9),
                                    ),
                                  )
                                : new CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: FaIcon(
                                      FontAwesomeIcons.clone,
                                      size: 16,
                                      color: Colors.grey[400],
                                    )),
                            Container(
                              constraints:
                                  BoxConstraints(minWidth: 100, maxWidth: 180),
                              child: Text(
                                mItem.text,
                                style: TextStyle(
                                    color: mItem == this.selectedMenuItem
                                        ? (widget.appState.applicationStyle !=
                                                    null &&
                                                widget.appState.applicationStyle
                                                        .sideMenuSelectionColor !=
                                                    null)
                                            ? widget.appState.applicationStyle
                                                .sideMenuSelectionColor
                                            : Color(0xFF2196F3)
                                        : (widget.appState.applicationStyle !=
                                                    null &&
                                                widget.appState.applicationStyle
                                                        .sideMenuTextColor !=
                                                    null)
                                            ? widget.appState.applicationStyle
                                                .sideMenuTextColor
                                            : Color(0xFFd9d9d9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              )));
      widgets.add(tile);
      if (v.indexOf(mItem) < v.length - 1)
        widgets.add(Divider(
          height: 2,
          indent: 15,
          endIndent: 15,
        ));
    });

    return widgets;
  }
}
