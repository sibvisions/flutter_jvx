import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../logic/bloc/api_bloc.dart';
import '../../logic/bloc/error_handler.dart';
import '../../model/so_action.dart' as prefix0;
import '../../model/api/request/open_screen.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/menu_item.dart';
import '../../utils/globals.dart' as globals;
import '../page/open_screen_page.dart';
import '../../ui/widgets/custom_icon.dart';

class MenuTabsWidget extends StatefulWidget {
  final List<MenuItem> items;
  final bool groupedMenuMode;

  MenuTabsWidget({Key key, this.items, this.groupedMenuMode = true})
      : super(key: key);

  @override
  _MenuTabsWidgetState createState() => _MenuTabsWidgetState();
}

class _MenuTabsWidgetState extends State<MenuTabsWidget> {
  String title;

  bool errorMsgShown = false;

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

            Navigator.of(context).push(MaterialPageRoute(
                settings: RouteSettings(name: "/OpenScreen"),
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
                  indicatorColor: Colors.white,
                  isScrollable: true,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  tabs: widgetList.map((Widget choice) {
                    return Tab(
                      text: choice.key.toString().split('\'')[1],
                    );
                  }).toList(),
                ),
              ),
            ),
            body: TabBarView(
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
            .getScreen(menuItem.action.componentId,
                templateName: menuItem.templateName)
            .withServer()) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => globals.customScreenManager
              .getScreen(menuItem.action.componentId,
                  templateName: menuItem.templateName)
              .getWidget()));
    } else {
      prefix0.SoAction action = menuItem.action;

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
      Widget group = GridView.count(
        key: new Key(v[0].group.toString()),
        padding: EdgeInsets.fromLTRB(14, 5, 14, 5),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ScrollPhysics(),
        crossAxisCount: 2,
        children: _buildGroupGridViewCards(v),
      );

      widgets.add(group);
    });

    return widgets;
  }

  List<Widget> _buildGroupGridViewCards(List<MenuItem> menuItems) {
    List<Widget> widgets = <Widget>[];

    menuItems.forEach((mItem) {
      Widget menuItemCard = _buildGroupItemCard(mItem);

      widgets.add(menuItemCard);
    });

    return widgets;
  }

  Widget _buildGroupItemCard(MenuItem menuItem) {
    return new GestureDetector(
      child: new Card(
        color: Colors.white.withOpacity(globals.applicationStyle.menuOpacity),
        margin: EdgeInsets.all(5),
        shape: globals.applicationStyle.menuShape,
        elevation: 2.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: menuItem.image != null
                  ? new CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child:
                          CustomIcon(image: menuItem.image, size: Size(48, 48)))
                  : new CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        FontAwesomeIcons.clone,
                        size: 48,
                        color: Colors.grey[400],
                      )),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  menuItem.action.label,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                )),
          ],
        ),
      ),
      onTap: () => _onTap(menuItem),
    );
  }
}
