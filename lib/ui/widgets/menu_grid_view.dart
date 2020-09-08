import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../utils/uidata.dart';
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

class MenuGridView extends StatefulWidget {
  final List<MenuItem> items;
  final bool groupedMenuMode;

  MenuGridView({Key key, this.items, this.groupedMenuMode = true})
      : super(key: key);

  @override
  _MenuGridViewState createState() => _MenuGridViewState();
}

class _MenuGridViewState extends State<MenuGridView> {
  String title;

  bool errorMsgShown = false;

  @override
  Widget build(BuildContext context) {
    return errorAndLoadingListener(
      BlocListener<ApiBloc, Response>(
        // condition: (previousState, state) {
        //   print(
        //       '*** MenuGridView - HashCode: PREVIOUS: ${previousState.hashCode} NOW: ${state.hashCode}');
        //   return previousState.hashCode != state.hashCode;
        // },
        listener: (context, state) {
          print("*** MenuGridView - RequestType: " +
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
        child: widget.groupedMenuMode
            ? SingleChildScrollView(
                child: Column(
                  children: _buildGroupedGridView(this.widget.items),
                ),
              )
            : _buildGridView(this.widget.items),
      ),
    );
  }

  void _onTap(MenuItem menuItem) {
    if (globals.customScreenManager != null &&
        !globals.customScreenManager
            .getScreen(menuItem.action.componentId,
                templateName: menuItem.templateName)
            .withServer()) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
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

  Widget _buildGridView(List<MenuItem> menuItems) {
    return GridView.builder(
      itemCount: menuItems.length,
      gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210, crossAxisSpacing: 1),
      itemBuilder: (BuildContext context, int index) {
        return _getMenuItem(menuItems[index]);
      },
    );
  }

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

      widgets.add(StickyHeader(
        header: Container(
            color: Colors.white,
            child: _buildGroupHeader(v[0].group.toString())),
        content: group,
      ));
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

  Widget _buildGroupHeader(String groupName) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: ListTile(
          title: Text(
            groupName,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ));
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
                      item.action.label,
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
                              child: Icon(FontAwesomeIcons.clone,
                                  size: 72, color: Colors.white))),
                )),
          ],
        ),
      ),
      onTap: () => _onTap(item),
    );
  }
}
