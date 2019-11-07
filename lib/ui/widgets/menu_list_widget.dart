import 'dart:async';
import "package:collection/collection.dart";

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/error_handler.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/api/request/close_screen.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/model/api/request/open_screen.dart';
import 'package:jvx_mobile_v3/ui/page/open_screen_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/fontAwesomeChanger.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class MenuListWidget extends StatelessWidget {
  final List<MenuItem> menuItems;
  String title;

  MenuListWidget({Key key, @required this.menuItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return errorAndLoadingListener(
      BlocListener<ApiBloc, Response>(
        listener: (context, state) {
          if (state != null &&
              state.screenGeneric != null &&
              state.requestType == RequestType.OPEN_SCREEN) {
            Key componentID = new Key(state.screenGeneric.componentId);
            globals.items = this.menuItems;

            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => new OpenScreenPage(
                      screenGeneric: state.screenGeneric,
                      data: state.jVxData,
                      metaData: state.jVxMetaData,
                      request: state.request,
                      componentId: componentID,
                      title: title,
                      items: globals.items,
                    )));
          }
        },
        child: Container(
          child: ListView(
            children: _buildListTiles(context),
          ),
        ),
      ),
    );
  }

  List<ListTile> _buildListTiles(BuildContext context) {
    var newMap = groupBy(this.menuItems, (obj) => obj.group);

    List<ListTile> tiles = <ListTile>[];

    newMap.forEach((k, v) {
      ListTile heading = ListTile(
        title: Text(k, style: Theme.of(context).textTheme.headline,),
      );

      tiles.add(heading);

      v.forEach((mItem) {
        ListTile tile = ListTile(
                title: Text(mItem.action.label),
                onTap: () {
                  // CloseScreen closeScreen = CloseScreen(
                  //     clientId: globals.clientId,
                  //     componentId: this.menuItems[index].action.componentId
                  //         .toString()
                  //         .replaceAll("[<'", '')
                  //         .replaceAll("'>]", ''),
                  //     requestType: RequestType.CLOSE_SCREEN);

                  // BlocProvider.of<ApiBloc>(context).dispatch(closeScreen);

                  prefix0.Action action = mItem.action;
                  title = action.label;

                  OpenScreen openScreen = OpenScreen(
                      action: action,
                      clientId: globals.clientId,
                      manualClose: false,
                      requestType: RequestType.OPEN_SCREEN);

                  BlocProvider.of<ApiBloc>(context).dispatch(openScreen);
                },
                leading: mItem.image != null
                    ? new CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: !mItem
                                .image
                                .startsWith('FontAwesome')
                            ? new Image.asset(
                                '${globals.dir}${mItem.image}')
                            : _iconBuilder(formatFontAwesomeText(
                                mItem.image)))
                    : new CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          FontAwesomeIcons.clone,
                          size: 48,
                          color: Colors.grey[300],
                        )),
              );

              tiles.add(tile);
      });
    });

    return tiles;
  }

  Icon _iconBuilder(Map data) {
    Icon icon = new Icon(
      data['icon'],
      size: double.parse(data['size']),
      color: UIData.ui_kit_color_2,
      key: data['key'],
      textDirection: data['textDirection'],
    );

    return icon;
  }
}
