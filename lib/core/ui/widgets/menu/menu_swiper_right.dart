import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../models/api/response/menu_item.dart';
import '../../../models/app/app_state.dart';
import '../custom/custom_icon.dart';

class MenuSwiperWidget extends StatefulWidget {
  final List<MenuItem> items;
  final bool groupedMenuMode;
  final Function onPressed;
  final AppState appState;

  MenuSwiperWidget(
      {Key key,
      this.items,
      this.groupedMenuMode = true,
      this.onPressed,
      this.appState})
      : super(key: key);

  @override
  _MenuSwiperRightState createState() => _MenuSwiperRightState();
}

class _MenuSwiperRightState extends State<MenuSwiperWidget> {
  List<Widget> _buildGroupedGridView(List<MenuItem> menuItems) {
    Map<String, List<MenuItem>> groupedMItems =
        groupBy(menuItems, (obj) => obj.group);

    List<Widget> widgets = <Widget>[];

    groupedMItems.forEach((k, v) {
      Widget group = GridView(
        gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 210, crossAxisSpacing: 1),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ScrollPhysics(),
        children: _buildGroupGridViewCards(v),
      );

      widgets.add(SingleChildScrollView(
          child: StickyHeader(
        header: Container(
            color: Colors.white
                .withOpacity(widget.appState.applicationStyle?.menuOpacity),
            child: _buildGroupHeader(v[0].group.toString())),
        content: group,
      )));
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
    List<Widget> widgetList = _buildGroupedGridView(this.widget.items);
    int index = 0;

    return Swiper(
      index: index,
      indicatorLayout: PageIndicatorLayout.SCALE,
      pagination: new SwiperPagination(
          builder: DotSwiperPaginationBuilder(
              color: Colors.grey[400], activeColor: Colors.grey.shade700)),
      onIndexChanged: (index) {
        widget.appState.menuCurrentPageIndex = index;
      },
      itemCount: widgetList.length,
      itemBuilder: (BuildContext context, int index) {
        return widgetList[index];
      },
    );
  }
}
