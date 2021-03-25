import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/menu/menu_item.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/ui/widgets/custom/custom_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class MenuListViewWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool groupedMenuMode;
  final Function onPressed;
  final AppState appState;

  MenuListViewWidget(
      {Key? key,
      required this.menuItems,
      required this.groupedMenuMode,
      required this.onPressed,
      required this.appState})
      : super(key: key);

  @override
  _MenuListViewWidgetState createState() => _MenuListViewWidgetState();
}

class _MenuListViewWidgetState extends State<MenuListViewWidget> {
  List<Widget> _buildListTiles(BuildContext context) {
    Map<String, List<MenuItem>> newMap =
        groupBy(widget.menuItems, (obj) => obj.group);

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

  List<Widget> _buildTiles(List<MenuItem> v) {
    List<Widget> widgets = <Widget>[];

    v.forEach((MenuItem mItem) {
      widgets.add(GestureDetector(
        child: Container(
          height: 76,
          margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
          color: Theme.of(context).primaryColor.withOpacity(
              widget.appState.applicationStyle?.opacity?.menuOpacity ?? 1.0),
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
                                image: mItem.image!,
                                prefferedSize: Size(32, 32),
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
                            mItem.text,
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
