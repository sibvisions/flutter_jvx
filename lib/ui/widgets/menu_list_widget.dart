import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../logic/bloc/error_handler.dart';
import '../../model/action.dart' as prefix0;
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/menu_item.dart';
import '../../model/api/request/open_screen.dart';
import '../../ui/page/open_screen_page.dart';
import '../../utils/uidata.dart';
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

            Navigator.of(context).push(MaterialPageRoute(
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
            padding: EdgeInsets.symmetric(horizontal: 7),
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

  List<Widget> _buildListTiles(BuildContext context) {
    var newMap = groupBy(this.widget.menuItems, (obj) => obj.group);

    List<Widget> tiles = <Widget>[];

    newMap.forEach((k, v) {
      Widget heading = Padding(
          padding: EdgeInsets.symmetric(horizontal: 13),
          child: ListTile(
            title: Text(
              k,
              style: TextStyle(
                  color: Colors.grey.shade700, fontWeight: FontWeight.bold),
            ),
          ));

      Widget card = Card(
        color: Colors.white.withOpacity(globals.applicationStyle.menuOpacity),
        elevation: 2.0,
        child: Column(children: _buildTiles(v)),
      );

      if (widget.groupedMenuMode) {
        Widget sticky = StickyHeader(
          header: Container(
            color: Colors.white.withOpacity(globals.applicationStyle.menuOpacity),
            child: heading,
          ),
          content: card,
        );

        tiles.add(sticky);
      } else {
        tiles..add(card);
      }
    });

    return tiles;
  }

  List<Widget> _buildTiles(List v) {
    List<Widget> widgets = <Widget>[];

    v.forEach((mItem) {
      Widget tile = ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                child: CustomIcon(image: mItem.image, size: Size(32,32)))   
            : new CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  FontAwesomeIcons.clone,
                  size: 32,
                  color: Colors.grey[400],
                )),
        trailing: Icon(
          FontAwesomeIcons.chevronRight,
          color: Colors.grey[300],
        ),
      );
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
