import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/ui_refactor_2/page/open_screen_page.dart';

import '../../utils/uidata.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../logic/bloc/error_handler.dart';
import '../../model/so_action.dart' as prefix0;
import '../../model/api/request/open_screen.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/menu_item.dart';
import '../../utils/globals.dart' as globals;
import '../../ui/widgets/custom_icon.dart';

class MenuTabsWidget extends StatefulWidget {
  final List<MenuItem> items;
  final bool groupedMenuMode;

  MenuTabsWidget({Key key, this.items, this.groupedMenuMode = true})
      : super(key: key);

  @override
  _MenuTabsWidgetState createState() => _MenuTabsWidgetState();
}

class _MenuTabsWidgetState extends State<MenuTabsWidget>
    with SingleTickerProviderStateMixin {
  String title;

  bool errorMsgShown = false;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    var newMap = groupBy(widget.items, (obj) => obj.group);
    int index = 0;
    if (globals.menuCurrentPageIndex != null &&
        globals.menuCurrentPageIndex < newMap.length)
      index = globals.menuCurrentPageIndex;
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

    return errorAndLoadingListener(
      BlocListener<ApiBloc, Response>(
        listener: (context, state) {
          print("*** MenuTabsWidget - RequestType: " +
              state.requestType.toString());

          if (state != null &&
              state.userData != null &&
              globals.customScreenManager != null) {
            globals.customScreenManager.onUserData(state.userData);
          }

          if (state != null &&
              state.responseData.screenGeneric != null &&
              state.requestType == RequestType.OPEN_SCREEN) {
            Key componentID =
                new Key(state.responseData.screenGeneric.componentId);
            globals.items = widget.items;

            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => new OpenScreenPage(
                      responseData: state.responseData,
                      request: state.request,
                      componentId: componentID,
                      title: title,
                      items: globals.items,
                      menuComponentId:
                          (state.request as OpenScreen).action.componentId,
                    )));
          }
        },
        child: DefaultTabController(
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
                    globals.menuCurrentPageIndex = index;
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
        ),
      ),
    );
  }

  void _onTap(MenuItem menuItem) {
    if (globals.customScreenManager != null &&
        !globals.customScreenManager
            .getScreen(menuItem.componentId,
                templateName: menuItem.text)
            .withServer()) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => globals.customScreenManager
              .getScreen(menuItem.componentId,
                  templateName: menuItem.text)
              .getWidget()));
    } else {
      prefix0.SoAction action = prefix0.SoAction(componentId: menuItem.componentId, label: menuItem.text);

      title = action.label;

      OpenScreen openScreen = OpenScreen(
        action: action,
        clientId: globals.clientId,
        manualClose: false,
        requestType: RequestType.OPEN_SCREEN,
      );

      BlocProvider.of<ApiBloc>(context).dispatch(openScreen);
    }
  }

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
        color: UIData.ui_kit_color_2
            .withOpacity(globals.applicationStyle.menuOpacity),
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
      onTap: () => _onTap(item),
    );
  }
}
