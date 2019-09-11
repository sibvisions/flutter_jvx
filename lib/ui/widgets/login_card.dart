import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/inherited/login_provider.dart';
import 'package:jvx_mobile_v3/logic/bloc/login_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/login_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/ui/page/login_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/ui/widgets/gradient_button.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class LoginCard extends StatefulWidget {
  @override
  _LoginCardState createState() => new _LoginCardState();
}

class _LoginCardState extends State<LoginCard> with SingleTickerProviderStateMixin {
  var deviceSize;
  bool rememberMe = false;
  AnimationController controller;
  Animation<double> animation;
  LoginBloc loginBloc;
  String username = '', password = '';
  StreamSubscription<FetchProcess> apiStreamSubscription;

  Widget loginBuilder() => StreamBuilder<bool>(
        stream: loginBloc.loginResult,
        initialData: false,
        builder: (context, snapshot) => Form(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Text(
                        globals.applicationStyle.loginTitle,
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      new TextField(
                        onChanged: (username) => this.username = username,
                        enabled: !snapshot.data,
                        style:
                            new TextStyle(fontSize: 15.0, color: Colors.black),
                        decoration: new InputDecoration(
                            // hintText: Translations.of(context).text2("Username:"),
                            labelText: Translations.of(context).text2("Username:"),
                            labelStyle: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      new SizedBox(
                        height: 10.0,
                      ),
                      new TextField(
                        onChanged: (password) => this.password = password,
                        style: new TextStyle(
                            fontSize: 15.0, color: Colors.black),
                        decoration: new InputDecoration(
                            // hintText: Translations.of(context).text('enter_password_hint'),
                            labelText: Translations.of(context).text2('Password:'),
                            labelStyle:
                                TextStyle(fontWeight: FontWeight.w700)),
                        obscureText: true,
                      ),
                      new CheckboxListTile(
                        onChanged: (bool val) {
                          setState(() {
                            rememberMe = val;
                          });
                        },
                        value: rememberMe,
                        title: Text(Translations.of(context).text2('Remember me?')),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: UIData.ui_kit_color_2,
                      ),
                      Container(
                        child: new GradientButton(
                          onPressed: () {
                            this.password.length > 0 && this.username.length > 0
                            ? loginBloc.loginSink.add(new LoginViewModel.withPW(username: username, password: password, rememberMe: rememberMe))
                            : print(this.password);
                          },
                          text: Translations.of(context).text2('Logon'))
                      ),
                      Container(
                        child: new FlatButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                          label: Text(Translations.of(context).text2('Settings')),
                          icon: Icon(FontAwesomeIcons.cog, color: UIData.ui_kit_color_2,),
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
      );

  Widget loginCard() {
    return Opacity(
      opacity: animation.value,
      child: SizedBox(
        height: deviceSize.height / 2 - 5,
        width: deviceSize.width * 0.85,
        child: new Card(
            color: Colors.white, elevation: 2.0, child: loginBuilder()),
      ),
    );
  }

  @override
  initState() {
    super.initState();
    loginBloc = new LoginBloc();
    apiStreamSubscription = apiSubscription(loginBloc.apiResult, context);
    controller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1500));
    animation = new Tween(begin: 0.0, end: 1.0).animate(
        new CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
    animation.addListener(() => this.setState(() {}));
    controller.forward();
  }

  @override
  void dispose() {
    controller?.dispose();
    loginBloc?.dispose();
    apiStreamSubscription?.cancel();
    super.dispose();
  }

  showUsernameError(BuildContext context) {
    LoginProvider.of(context)
        .validationErrorCallback(LoginValidationType.username);
  }

  showPasswordError(BuildContext context) {
    LoginProvider.of(context).validationErrorCallback(LoginValidationType.password);
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return loginCard();
  }
}