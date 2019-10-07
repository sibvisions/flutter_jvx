import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/inherited/login_provider.dart';
import 'package:jvx_mobile_v3/logic/new_bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/menu.dart';
import 'package:jvx_mobile_v3/ui/widgets/login_background.dart';
import 'package:jvx_mobile_v3/ui/widgets/login_widget.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

import 'menu_page.dart';

enum LoginValidationType { username, password }

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final scaffoldState = GlobalKey<ScaffoldState>();

  Widget loginScaffold() => Scaffold(
        key: scaffoldState,
        backgroundColor: globals.applicationStyle != null
            ? Color(int.parse(
                '0xFF${globals.applicationStyle.loginBackground.substring(1)}'))
            : null,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[LoginBackground(), LoginWidgets()],
        ),
      );

  Widget loginBuilder() => BlocBuilder<ApiBloc, Response>(
        builder: (context, state) {
          if (state.requestType == RequestType.LOGOUT && !state.loading && (state.error == null || !state.error)) {
            return loginScaffold();
          }

          if (state.requestType == RequestType.LOGIN &&
              !state.loading &&
              (state.error == null || !state.error) &&
              state.responseObjects != null) {
            Menu menu = state.responseObjects
                .firstWhere((r) => r is Menu, orElse: () => null);

            if (menu != null)
              Future.delayed(
                  Duration.zero,
                  () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => MenuPage(
                            menuItems: menu.items,
                          ))));
          }

          if ((state.requestType == RequestType.DOWNLOAD_IMAGES ||
                      state.requestType == RequestType.DOWNLOAD_TRANSLATION) &&
                  state.loading ||
              state.download == null) {
            return Scaffold(
              body: Center(
                child: Text('Loading...'),
              ),
            );
          }

          return loginScaffold();
        },
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
