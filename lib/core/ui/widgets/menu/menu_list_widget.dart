import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../models/api/response/menu_item.dart';
import '../../../models/app/app_state.dart';
import '../custom/custom_icon.dart';

class MenuListWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool groupedMenuMode;
  final Function onPressed;
  final AppState appState;

  MenuListWidget(
      {Key key,
      @required this.menuItems,
      this.groupedMenuMode = true,
      this.onPressed,
      this.appState})
      : super(key: key);

  @override
  _MenuListWidgetState createState() => _MenuListWidgetState();
}

class _MenuListWidgetState extends State<MenuListWidget> {
  List<Widget> _buildListTiles(BuildContext context) {
    var newMap = groupBy(this.widget.menuItems, (obj) => obj.group);

    List<Widget> tiles = <Widget>[];

    newMap.forEach((k, v) {
      Widget heading = Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: ListTile(
            title: Text(
              k,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.grey.shade700, fontWeight: FontWeight.bold),
            ),
          ));

      Widget card = Container(
        child: Column(children: _buildTiles(v)),
      );

      if (widget.groupedMenuMode) {
        Widget sticky = StickyHeader(
          header: Container(
            color: Colors.white,
            child: heading,
          ),
          content: card,
        );

        tiles.add(sticky);
      } else {
        tiles.add(card);
      }
    });

    return tiles;
  }

  List<Widget> _buildTiles(List v) {
    List<Widget> widgets = <Widget>[];

    v.forEach((mItem) {
      widgets.add(GestureDetector(
        child: Container(
          height: 76,
          margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
          color: Theme.of(context)
              .primaryColor
              .withOpacity(widget.appState.applicationStyle?.menuOpacity),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 75,
                color: Colors.black.withOpacity(0.1),
                child: mItem.image != null
                    ? new CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Center(
                            child: CustomIcon(
                                image: mItem.image,
                                size: Size(32, 32),
                                color: Colors.white)))
                    : new CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Center(
                            child: FaIcon(FontAwesomeIcons.clone,
                                size: 32, color: Colors.white))),
              ),
              Expanded(
                  child: Container(
                      color: Colors.black.withOpacity(0.2),
                      padding: EdgeInsets.fromLTRB(15, 3, 5, 3),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            mItem.action.label,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          )))),
              Container(
                  alignment: Alignment.center,
                  width: 75,
                  color: Colors.black.withOpacity(0.2),
                  child: FaIcon(
                    FontAwesomeIcons.chevronRight,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
        onTap: () => widget.onPressed(mItem),
      ));
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildListTiles(context),
        ),
      ),
    );
  }
}
