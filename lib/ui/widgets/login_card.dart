import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/inherited/login_provider.dart';
import 'package:jvx_mobile_v3/logic/bloc/login_bloc.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/ui/page/login_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/ui/widgets/gradient_button.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';

class LoginCard extends StatefulWidget {
  @override
  _LoginCardState createState() => new _LoginCardState();
}

class _LoginCardState extends State<LoginCard> with SingleTickerProviderStateMixin {
  var deviceSize;
  AnimationController controller;
  Animation<double> animation;
  LoginBloc loginBloc;
  String username, password;
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
                      new TextField(
                        onChanged: (username) => username = username,
                        enabled: !snapshot.data,
                        style:
                            new TextStyle(fontSize: 15.0, color: Colors.black),
                        decoration: new InputDecoration(
                            hintText: Translations.of(context).text("enter_code_hint"),
                            labelText: Translations.of(context).text("enter_code_label"),
                            labelStyle: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      new SizedBox(
                        height: 10.0,
                      ),
                      new TextField(
                        onChanged: (password) => password = password,
                        style: new TextStyle(
                            fontSize: 15.0, color: Colors.black),
                        decoration: new InputDecoration(
                            hintText: Translations.of(context).text('enter_otp_hint'),
                            labelText: Translations.of(context).text('enter_otp_label'),
                            labelStyle:
                                TextStyle(fontWeight: FontWeight.w700)),
                        obscureText: true,
                      ),
                      new SizedBox(
                        height: 30.0,
                      ),
                      Container(
                        child: new GradientButton(
                          onPressed: () => print("Hallo"),
                          text: Translations.of(context).text('login'))
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
        height: deviceSize.height / 2 - 20,
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

  showPhoneError(BuildContext context) {
    LoginProvider.of(context)
        .validationErrorCallback(LoginValidationType.username);
  }

  showOTPError(BuildContext context) {
    LoginProvider.of(context).validationErrorCallback(LoginValidationType.password);
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return loginCard();
  }
}