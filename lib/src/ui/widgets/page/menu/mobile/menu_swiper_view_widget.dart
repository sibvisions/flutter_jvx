import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../../models/state/app_state.dart';
import '../../../custom/custom_icon.dart';

class MenuSwiperViewWidget extends StatefulWidget {
  final List<MenuItem> items;
  final bool groupedMenuMode;
  final Function(MenuItem) onPressed;
  final AppState appState;

  const MenuSwiperViewWidget({
    Key? key,
    required this.items,
    required this.onPressed,
    required this.appState,
    this.groupedMenuMode = true,
  }) : super(key: key);

  @override
  _MenuSwiperViewWidgetState createState() => _MenuSwiperViewWidgetState();
}

class _MenuSwiperViewWidgetState extends State<MenuSwiperViewWidget> {
  int _index = 0;

  List<Widget> _buildGroupGridViewCards(List<MenuItem> menuItems) {
    List<Widget> widgets = <Widget>[];

    menuItems.forEach((item) {
      Widget menuItemCard = _getMenuItem(item);

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

      widgets.add(SingleChildScrollView(
        child: StickyHeader(
          header: Container(
            color: Colors.white
                .withOpacity(widget.appState.applicationStyle!.menuOpacity),
            child: _buildGroupHeader(items[0].group),
          ),
          content: groupWidget,
        ),
      ));
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = _buildGroupedGridView(widget.items);

    return Swiper(
      index: _index,
      indicatorLayout: PageIndicatorLayout.SCALE,
      onIndexChanged: (index) {
        // TODO: Set global index
      },
      itemCount: widgetList.length,
      itemBuilder: (context, index) {
        return widgetList[index];
      },
    );
  }
}
