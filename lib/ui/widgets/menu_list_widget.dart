import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../utils/uidata.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../logic/bloc/error_handler.dart';
import '../../model/so_action.dart' as prefix0;
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/menu_item.dart';
import '../../model/api/request/open_screen.dart';
import '../../ui/page/open_screen_page.dart';
import '../../utils/globals.dart' as globals;
import '../../ui/widgets/custom_icon.dart';

class MenuListWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool groupedMenuMode;

  MenuListWidget(
      {Key key, @required this.menuItems, this.groupedMenuMode = true})
      : super(key: key);

  @override
  _MenuListWidgetState createState() => _MenuListWidgetState();
}

class _MenuListWidgetState extends State<MenuListWidget> {
  String title;

  @override
  Widget build(BuildContext context) {
    return errorAndLoadingListener(
      BlocListener<ApiBloc, Response>(
        listener: (context, state) {
          print("*** MenuListWidget - RequestType: " +
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
            globals.items = widget.menuItems;

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
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildListTiles(context),
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

  List<Widget> _buildListTiles(BuildContext context) {
    var newMap = groupBy(this.widget.menuItems, (obj) => obj.group);

    List<Widget> tiles = <Widget>[];

    newMap.forEach((k, v) {
      Widget heading = Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: ListTile(
            title: Text(
              k,
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
          color: UIData.ui_kit_color_2
              .withOpacity(globals.applicationStyle.menuOpacity),
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
                            child: Icon(FontAwesomeIcons.clone,
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
                  width: 75,
                  color: Colors.black.withOpacity(0.2),
                  child: Icon(
                    FontAwesomeIcons.chevronRight,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
        onTap: () => _onTap(mItem),
      ));
    });

    return widgets;
  }
}
