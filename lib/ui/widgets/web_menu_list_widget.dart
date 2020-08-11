import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/ui/screen/i_screen.dart';
import 'package:tinycolor/tinycolor.dart';

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

class WebMenuListWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool groupedMenuMode;

  WebMenuListWidget(
      {Key key, @required this.menuItems, this.groupedMenuMode = true})
      : super(key: key);

  @override
  _WebMenuListWidgetState createState() => _WebMenuListWidgetState();
}

class _WebMenuListWidgetState extends State<WebMenuListWidget> {
  String title;

  @override
  Widget build(BuildContext context) {
    return errorAndLoadingListener(
      BlocListener<ApiBloc, Response>(
        listener: (context, state) {
          print("*** WebMenuListWidget - RequestType: " +
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
        child: Container(
          height: MediaQuery.of(context).size.height,
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
      ),
    );
  }

  void _onTap(MenuItem menuItem) {
    if (globals.customScreenManager != null &&
        !globals.customScreenManager
            .getScreen(menuItem.action.componentId,
                templateName: menuItem.templateName)
            .withServer()) {
      IScreen screen = globals.customScreenManager.getScreen(
          menuItem.action.componentId,
          templateName: menuItem.templateName);

      globals.appFrame.setScreen(screen.getWidget());

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => globals.appFrame.getWidget()));
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
      Widget heading = Container(
        alignment: Alignment.centerLeft,
        margin: new EdgeInsets.symmetric(horizontal: 8.0),
        height: 25,
        child: Text(
          k,
          style: TextStyle(
              color: (globals.applicationStyle != null &&
                      globals.applicationStyle.sideMenuGroupTextColor != null)
                  ? globals.applicationStyle.sideMenuGroupTextColor
                  : null,
              fontWeight: FontWeight.bold),
        ),
      );

      Widget card = Container(
          child: Column(
        children: _buildTiles(v),
      ));

      if (true) {
        tiles.add(Column(
          children: [
            heading,
            card,
          ],
        ));
      } else {
        tiles.add(card);
      }
    });

    return tiles;
  }

  List<Widget> _buildTiles(List v) {
    List<Widget> widgets = <Widget>[];

    v.forEach((mItem) {
      Widget tile = Container(
          child: Tooltip(
              waitDuration: Duration(milliseconds: 500),
              message: mItem.action.label,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  hoverColor: TinyColor((globals.applicationStyle != null &&
                                    globals.applicationStyle.sideMenuColor !=
                                        null)
                                ? globals.applicationStyle.sideMenuColor
                                    .withOpacity(0.95)
                                : Colors.grey[600]).darken().color,
                  onTap: () => _onTap(mItem),
                  child: Column(children: <Widget>[
                    Container(
                      height:32,
                      child: Center(
                        child: Row(
                          children: [
                            mItem.image != null
                                ? new CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: CustomIcon(
                                        image: mItem.image,
                                        size: Size(16, 16),
                                        color: (globals.applicationStyle !=
                                                    null &&
                                                globals.applicationStyle
                                                        .sideMenuTextColor !=
                                                    null)
                                            ? globals.applicationStyle
                                                .sideMenuTextColor
                                            : null))
                                : new CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: Icon(
                                      FontAwesomeIcons.clone,
                                      size: 16,
                                      color: Colors.grey[400],
                                    )),
                            Container(
                              constraints:
                                  BoxConstraints(minWidth: 100, maxWidth: 180),
                              child: Text(
                                mItem.action.label,
                                style: TextStyle(
                                    color: (globals.applicationStyle != null &&
                                            globals.applicationStyle
                                                    .sideMenuTextColor !=
                                                null)
                                        ? globals
                                            .applicationStyle.sideMenuTextColor
                                        : null,
                                    fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              )));
      widgets.add(tile);
      if (v.indexOf(mItem) < v.length - 1)
        widgets.add(Divider(
          height: 2,
          indent: 15,
          endIndent: 15,
        ));
    });

    return widgets;
  }
}
