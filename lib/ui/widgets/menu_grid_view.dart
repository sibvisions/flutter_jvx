import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/error_handler.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/model/api/request/open_screen.dart';
import 'package:jvx_mobile_v3/model/api/response/screen_generic.dart';
import 'package:jvx_mobile_v3/ui/page/open_screen_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/fontAwesomeChanger.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class MenuGridView extends StatelessWidget {
  final List<MenuItem> items;
  String title;
  bool errorMsgShown = false;

  MenuGridView({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<ApiBloc>(context).state.listen((resp) {
      if (resp != null &&
          !resp.loading &&
          !errorMsgShown) {
          errorMsgShown = true;
        Future.delayed(Duration.zero, () => handleError(resp, context));
      }

      if (resp != null &&
          resp.screenGeneric != null &&
          resp.requestType == RequestType.OPEN_SCREEN) {
        ScreenGeneric screenGeneric = resp.screenGeneric;
        List<JVxData> data = resp.jVxData;
        List<JVxMetaData> metaData = resp.jVxMetaData;

        Key componentID = new Key(screenGeneric.componentId);

        globals.items = items;

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => new OpenScreenPage(
                  changedComponents: screenGeneric.changedComponents,
                  data: data,
                  metaData: metaData,
                  componentId: componentID,
                  title: title,
                  items: globals.items,
                )));
      }
    });

    return new GridView.builder(
      itemCount: this.items.length,
      gridDelegate:
          new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          child: new Card(
            margin: EdgeInsets.all(6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            elevation: 2.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                items[index].image != null
                    ? new CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: !items[index].image.startsWith('FontAwesome')
                            ? new Image.asset(
                                '${globals.dir}${items[index].image}')
                            : _iconBuilder(
                                formatFontAwesomeText(items[index].image)))
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
                      items[index].action.label,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
          onTap: () {
            prefix0.Action action = items[index].action;

            title = action.label;

            OpenScreen openScreen = OpenScreen(
                action: action,
                clientId: globals.clientId,
                manualClose: true,
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
