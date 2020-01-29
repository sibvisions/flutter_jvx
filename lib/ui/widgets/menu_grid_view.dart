import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../logic/bloc/api_bloc.dart';
import '../../logic/bloc/error_handler.dart';
import '../../model/action.dart' as prefix0;
import '../../model/api/request/open_screen.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/menu_item.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/uidata.dart';
import '../page/open_screen_page.dart';
import 'fontAwesomeChanger.dart';

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

          // if (state != null &&
          //     state.requestType == RequestType.APP_STYLE &&
          //     !state.loading &&
          //     !state.error) {
          //   globals.applicationStyle = state.applicationStyle;
          // }

          if (state != null &&
              state.screenGeneric != null &&
              state.requestType == RequestType.OPEN_SCREEN) {
            Key componentID = new Key(state.screenGeneric.componentId);
            globals.items = widget.items;

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

  Icon _iconBuilder(Map data) {
    Icon icon = new Icon(
      data['icon'],
      size: double.parse(data['size'] ?? '16'),
      color: UIData.ui_kit_color_2[300],
      key: data['key'],
      textDirection: data['textDirection'],
    );

    return icon;
  }

  Widget _buildGridView(List<MenuItem> menuItems) {
    return GridView.builder(
      itemCount: menuItems.length,
      gridDelegate:
          new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          child: new Card(
            margin: EdgeInsets.all(6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                menuItems[index].image != null
                    ? new CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: !menuItems[index].image.startsWith('FontAwesome')
                            ? new Image.asset(
                                '${globals.dir}${menuItems[index].image}',
                              )
                            : _iconBuilder(
                                formatFontAwesomeText(menuItems[index].image)))
                    : new CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          FontAwesomeIcons.clone,
                          size: 48,
                          color: Colors.grey[300],
                        )),
                Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      menuItems[index].action.label,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
          onTap: () {
            prefix0.Action action = menuItems[index].action;

            title = action.label;

            OpenScreen openScreen = OpenScreen(
                action: action,
                clientId: globals.clientId,
                manualClose: false,
                requestType: RequestType.OPEN_SCREEN);

            BlocProvider.of<ApiBloc>(context).dispatch(openScreen);

            /*
                    OpenScreenBloc openScreenBloc = OpenScreenBloc();
                    StreamSubscription<FetchProcess> apiStreamSubscription;

                    apiStreamSubscription = apiSubscription(openScreenBloc.apiResult, context);
                    openScreenBloc.openScreenSink.add(
                      new OpenScreenViewModel(action: action, clientId: globals.clientId, manualClose: true)
                    );

                    */
          },
        );
      },
    );
  }

  List<Widget> _buildGroupedGridView(List<MenuItem> menuItems) {
    Map<String, List<MenuItem>> groupedMItems =
        groupBy(menuItems, (obj) => obj.group);

    List<Widget> widgets = <Widget>[];

    groupedMItems.forEach((k, v) {
      Widget group = GridView.count(
        padding: EdgeInsets.symmetric(horizontal: 5),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ScrollPhysics(),
        crossAxisCount: 2,
        children: _buildGroupGridViewCards(v),
      );

      widgets.add(StickyHeader(
        header: Container(
            color: Colors.grey[200],
            child: _buildGroupHeader(v[0].group.toString())),
        content: group,
      ));

      // widgets.add(group);
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
        margin: EdgeInsets.all(5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                      child: !menuItem.image.startsWith('FontAwesome')
                          ? new Image.asset('${globals.dir}${menuItem.image}')
                          : _iconBuilder(formatFontAwesomeText(menuItem.image)))
                  : new CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        FontAwesomeIcons.clone,
                        size: 48,
                        color: Colors.grey[300],
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
      onTap: () {
        if (globals.customScreenManager != null &&
            !globals.customScreenManager
                .withServer(menuItem.action.componentId)) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => globals.customScreenManager
                  .getScreen(menuItem.action.componentId)
                  .getWidget()));
        } else {
          prefix0.Action action = menuItem.action;

          title = action.label;

          OpenScreen openScreen = OpenScreen(
              action: action,
              clientId: globals.clientId,
              manualClose: false,
              requestType: RequestType.OPEN_SCREEN);

          BlocProvider.of<ApiBloc>(context).dispatch(openScreen);
        }

        /*
                    OpenScreenBloc openScreenBloc = OpenScreenBloc();
                    StreamSubscription<FetchProcess> apiStreamSubscription;
                    
                    apiStreamSubscription = apiSubscription(openScreenBloc.apiResult, context);
                    openScreenBloc.openScreenSink.add(
                      new OpenScreenViewModel(action: action, clientId: globals.clientId, manualClose: true)
                    );

                    */
      },
    );
  }

  Widget _buildGroupHeader(String groupName) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: ListTile(
          title: Text(
            groupName,
            textAlign: TextAlign.left,
            // textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ));
  }
}
