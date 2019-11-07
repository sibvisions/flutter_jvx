import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/error_handler.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/model/api/request/open_screen.dart';
import 'package:jvx_mobile_v3/model/api/response/screen_generic.dart';
import 'package:jvx_mobile_v3/ui/page/open_screen_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/ui/widgets/fontAwesomeChanger.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class MenuGridView extends StatefulWidget {
  final List<MenuItem> items;

  MenuGridView({Key key, this.items}) : super(key: key);

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
        child: GridView.builder(
          itemCount: this.widget.items.length,
          gridDelegate:
              new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
            return new GestureDetector(
              child: new Card(
                margin: EdgeInsets.all(6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 2.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    widget.items[index].image != null
                        ? new CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: !widget.items[index].image
                                    .startsWith('FontAwesome')
                                ? new Image.asset(
                                    '${globals.dir}${widget.items[index].image}')
                                : _iconBuilder(formatFontAwesomeText(
                                    widget.items[index].image)))
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
                          widget.items[index].action.label,
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ),
              onTap: () {
                prefix0.Action action = widget.items[index].action;

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
        ),
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
}
