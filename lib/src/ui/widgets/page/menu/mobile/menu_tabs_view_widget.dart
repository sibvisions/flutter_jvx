import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/menu/menu_item.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/ui/widgets/custom/custom_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuTabsViewWidget extends StatefulWidget {
  final List<MenuItem> items;
  final bool groupedMenuMode;
  final Function(MenuItem) onPressed;
  final AppState appState;

  const MenuTabsViewWidget({
    Key? key,
    required this.items,
    required this.onPressed,
    required this.appState,
    this.groupedMenuMode = true,
  }) : super(key: key);

  @override
  _MenuTabsViewWidgetState createState() => _MenuTabsViewWidgetState();
}

class _MenuTabsViewWidgetState extends State<MenuTabsViewWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Widget> _buildGroupedGridView(List<MenuItem> menuItems) {
    Map<String, List<MenuItem>> groupedMenuItems =
        groupBy(menuItems, (obj) => obj.group);

    List<Widget> widgets = <Widget>[];

    groupedMenuItems.forEach((group, items) {
      Widget groupWidget = GridView(
        key: Key(group),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 210, crossAxisSpacing: 1),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ScrollPhysics(),
        children: _buildGroupGridViewCards(items),
      );

      widgets.add(groupWidget);
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
            .withOpacity(widget.appState.applicationStyle!.menuOpacity),
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

  @override
  void initState() {
    super.initState();

    final groupedMenuItems =
        groupBy(widget.items, (MenuItem item) => item.group);

    int index = 0;

    // TODO: Set global index

    _tabController = TabController(
        initialIndex: index, vsync: this, length: groupedMenuItems.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = _buildGroupedGridView(widget.items);

    return DefaultTabController(
        length: widgetList.length,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                isScrollable: true,
                labelStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                tabs: widgetList
                    .map((Widget tabWidget) => Tab(
                          text: (tabWidget.key as ValueKey).value,
                        ))
                    .toList(),
                onTap: (index) {
                  // TODO: Set global index
                },
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: widgetList,
          ),
        ));
  }
}
