import 'package:flutter/material.dart';
import '../../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../../models/state/app_state.dart';
import '../../../custom/custom_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:collection/collection.dart';
import 'package:sticky_headers/sticky_headers.dart';

class MenuGridViewWidget extends StatefulWidget {
  final List<MenuItem> items;
  final bool groupedMenuMode;
  final Function(MenuItem) onPressed;
  final AppState appState;

  const MenuGridViewWidget(
      {Key? key,
      required this.items,
      required this.groupedMenuMode,
      required this.onPressed,
      required this.appState})
      : super(key: key);

  @override
  _MenuGridViewWidgetState createState() => _MenuGridViewWidgetState();
}

class _MenuGridViewWidgetState extends State<MenuGridViewWidget> {
  List<Widget> _buildGroupedGridView(List<MenuItem> menuItems) {
    Map<String, List<MenuItem>> groupedMenuItems =
        groupBy(menuItems, (obj) => obj.group);

    List<Widget> widgets = <Widget>[];

    groupedMenuItems.forEach((key, value) {
      Widget group = _buildGridView(value);

      widgets.add(StickyHeader(
        header: Container(
          color: Colors.white,
          child: _buildGroupHeader(value[0].group),
        ),
        content: group,
      ));
    });

    return widgets;
  }

  Widget _buildGridView(List<MenuItem> menuItems) {
    return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: menuItems.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 210, crossAxisSpacing: 1),
        itemBuilder: (BuildContext context, int index) {
          return _getMenuItem(menuItems[index]);
        });
  }

  GestureDetector _getMenuItem(MenuItem item) {
    return GestureDetector(
      child: new Container(
        margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
        color: Theme.of(context).primaryColor.withOpacity(
            widget.appState.applicationStyle?.opacity?.menuOpacity ?? 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
                flex: 25,
                child: Container(
                    color: Colors.black.withOpacity(0.2),
                    padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                    child: Center(
                        child: Text(
                      item.text,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )))),
            Expanded(
                flex: 75,
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: item.image != null
                      ? new CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Center(
                              child: CustomIcon(
                                  image: item.image!,
                                  prefferedSize: Size(72, 72),
                                  color: Colors.white)))
                      : new CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Center(
                              child: FaIcon(FontAwesomeIcons.clone,
                                  size: 72, color: Colors.white))),
                )),
          ],
        ),
      ),
      onTap: () => widget.onPressed(item),
    );
  }

  Widget _buildGroupHeader(String groupName) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: ListTile(
          title: Text(
            groupName,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groupedMenuMode) {
      return SingleChildScrollView(
        child: Column(
          children: _buildGroupedGridView(widget.items),
        ),
      );
    } else {
      return _buildGridView(widget.items);
    }
  }
}
