import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/api/response/menu_item.dart';
import '../../../models/app/app_state.dart';
import '../custom/custom_icon.dart';

class MenuTabsWidget extends StatefulWidget {
  final List<MenuItem> items;
  final bool groupedMenuMode;
  final Function onPressed;
  final AppState appState;

  const MenuTabsWidget(
      {Key key,
      this.items,
      this.groupedMenuMode,
      this.onPressed,
      this.appState})
      : super(key: key);

  @override
  _MenuTabsWidgetState createState() => _MenuTabsWidgetState();
}

class _MenuTabsWidgetState extends State<MenuTabsWidget>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  List<Widget> _buildGroupedGridView(List<MenuItem> menuItems) {
    Map<String, List<MenuItem>> groupedMItems =
        groupBy(menuItems, (obj) => obj.group);

    List<Widget> widgets = <Widget>[];

    groupedMItems.forEach((k, v) {
      print(v[0].group.toString());
      Widget group = GridView(
        key: new Key(v[0].group.toString()),
        gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 210, crossAxisSpacing: 1),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ScrollPhysics(),
        children: _buildGroupGridViewCards(v),
      );

      widgets.add(group);
    });

    return widgets;
  }

  List<Widget> _buildGroupGridViewCards(List<MenuItem> menuItems) {
    List<Widget> widgets = <Widget>[];

    menuItems.forEach((mItem) {
      Widget menuItemCard = _getMenuItem(mItem);

      widgets.add(menuItemCard);
    });

    return widgets;
  }

  GestureDetector _getMenuItem(MenuItem item) {
    return GestureDetector(
      child: new Container(
        margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
        color: Theme.of(context)
            .primaryColor
            .withOpacity(widget.appState.applicationStyle?.menuOpacity),
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
                                  image: item.image,
                                  size: Size(72, 72),
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

  @override
  void initState() {
    super.initState();
    var newMap = groupBy(widget.items, (obj) => obj.group);
    int index = 0;
    if (widget.appState.menuCurrentPageIndex != null &&
        widget.appState.menuCurrentPageIndex < newMap.length)
      index = widget.appState.menuCurrentPageIndex;
    _tabController = new TabController(
        initialIndex: index, vsync: this, length: newMap.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = _buildGroupedGridView(this.widget.items);

    return DefaultTabController(
      length: widgetList.length,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              isScrollable: true,
              labelStyle: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              tabs: widgetList.map((Widget choice) {
                return Tab(
                  text: choice.key.toString().split('\'')[1],
                );
              }).toList(),
              onTap: (index) {
                widget.appState.menuCurrentPageIndex = index;
              },
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: widgetList.map((Widget choice) {
            return choice;
          }).toList(),
        ),
      ),
    );
  }
}
