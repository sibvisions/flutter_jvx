import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/new_bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/action.dart' as prefix0;
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/model/open_screen/open_screen.dart';
import 'package:jvx_mobile_v3/ui/widgets/fontAwesomeChanger.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class MenuListWidget extends StatelessWidget {
  final List<MenuItem> menuItems;

  const MenuListWidget({Key key, @required this.menuItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title;
    return Container(
      child: ListView.builder(
        itemCount: this.menuItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(this.menuItems[index].action.label),
            subtitle: Text('Group: ' + this.menuItems[index].group),
            onTap: () {
              prefix0.Action action = menuItems[index].action;
              title = action.label;

              OpenScreen openScreen = OpenScreen(
                  action: action,
                  clientId: globals.clientId,
                  manualClose: true,
                  requestType: RequestType.OPEN_SCREEN);

              BlocProvider.of<ApiBloc>(context).dispatch(openScreen);
            },
            leading: this.menuItems[index].image != null 
                    ? new CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: !this.menuItems[index].image.startsWith('FontAwesome') 
                              ? new Image.asset('${globals.dir}${this.menuItems[index].image}')
                              : _iconBuilder(formatFontAwesomeText(this.menuItems[index].image))
                    )
                    : null,
          );
        },
      ),
    );
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