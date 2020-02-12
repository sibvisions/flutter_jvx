import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../logic/bloc/error_handler.dart';
import '../../logic/bloc/theme_bloc.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/api/response/menu.dart';
import '../../ui/widgets/common_dialogs.dart';
import '../../ui/widgets/login_background.dart';
import '../../ui/widgets/login_widget.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/translations.dart';
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
            if (state.error != null && state.error) {
              showError(context, Translations.of(context).text2('Error'),
                  state.message);
            }

            if (state != null &&
                state.requestType == RequestType.LOGIN &&
                !state.loading &&
                (state.error == null || !state.error) &&
                state.menu != null) {
              if (state.userData != null) {
                if (state.userData.userName != null) {
                  globals.username = state.userData.userName;
                }
                if (state.userData.displayName != null) {
                  globals.displayName = state.userData.displayName;
                }

                if (state.userData.profileImage != null)
                  globals.profileImage = state.userData.profileImage;
              }
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
    return BlocBuilder<ThemeBloc, ThemeData>(
      builder: (context, state) {
        return loginBuilder();
      }
    );
  }
}
