import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/error_handler.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/api/response/menu.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/ui/widgets/login_background.dart';
import 'package:jvx_mobile_v3/ui/widgets/login_widget.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/translations.dart';

import 'menu_page.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  bool errorMsgShown = false;

  Widget loginScaffold() => Scaffold(
        key: scaffoldState,
        backgroundColor: (globals.applicationStyle != null &&
                globals.applicationStyle.loginBackground != null)
            ? Color(int.parse(
                '0xFF${globals.applicationStyle.loginBackground.substring(1)}'))
            : null,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[LoginBackground(), LoginWidgets()],
        ),
      );

  Widget loginBuilder() => errorAndLoadingListener(
        BlocListener<ApiBloc, Response>(
          listener: (context, state) {
            if (state != null &&
                state.requestType == RequestType.LOGIN &&
                !state.loading &&
                (state.error == null || !state.error) &&
                state.menu != null) {
              Menu menu = state.menu;

              if (menu != null)
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => MenuPage(
                          menuItems: menu.items,
                        )));
            }
          },
          child: loginScaffold(),
        ),
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loginBuilder();
  }
}
