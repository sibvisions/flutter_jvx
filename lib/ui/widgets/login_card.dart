import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/request.dart';
import '../../model/api/request/login.dart';
import '../../ui/widgets/gradient_button.dart';
import '../../utils/translations.dart';
import '../../utils/uidata.dart';
import '../../utils/globals.dart' as globals;

class LoginCard extends StatefulWidget {
  final focus = FocusNode();
  @override
  _LoginCardState createState() => new _LoginCardState();
}

class _LoginCardState extends State<LoginCard>
    with SingleTickerProviderStateMixin {
  Size deviceSize;
  bool rememberMe = false;
  AnimationController controller;
  Animation<double> animation;
  String username = '', password = '';

  Widget loginBuilder() => Form(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
          child: SingleChildScrollView(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                (globals.applicationStyle != null &&
                        globals.applicationStyle.loginTitle != null)
                    ? new Text(
                        globals.applicationStyle.loginTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : AutoSizeText(
                        globals.appName,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(widget.focus);
                      },
                      autocorrect: false,
                      onChanged: (username) => this.username = username,
                      style: new TextStyle(fontSize: 14.0, color: Colors.black),
                      decoration: new InputDecoration(
                          hintStyle: TextStyle(color: Colors.green),
                          labelText: Translations.of(context)
                              .text2("Username:", 'Username:'),
                          labelStyle: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w600)),
                    )),
                new SizedBox(
                  height: 10.0,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      onFieldSubmitted: (String value) {
                        _login(context);
                      },
                      focusNode: widget.focus,
                      onChanged: (password) => this.password = password,
                      style: new TextStyle(fontSize: 14.0, color: Colors.black),
                      decoration: new InputDecoration(
                          labelText: Translations.of(context)
                              .text2('Password:', 'Password:'),
                          labelStyle: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w600)),
                      obscureText: true,
                    )),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: rememberMe,
                      activeColor: UIData.ui_kit_color_2,
                      onChanged: (bool val) {
                        setState(() {
                          rememberMe = val;
                        });
                      },
                    ),
                    Text(Translations.of(context)
                        .text2('Remember me?', 'Remember me?'),
                        style: Theme.of(context).textTheme.body2,
                        ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                        child: new GradientButton(
                            onPressed: () {
                              _login(context);
                            },
                            text: Translations.of(context)
                                .text2('Login', 'Login').toUpperCase()))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        child: new FlatButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                          label: Text(Translations.of(context)
                              .text2('Settings', 'Settings')),
                          icon: Icon(
                            FontAwesomeIcons.cog,
                            color: UIData.ui_kit_color_2[300],
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget loginCard() {
    return Opacity(
      opacity: animation.value,
      child: SizedBox(
        width: deviceSize.width * 0.85,
        child: new Card(
            color: Colors.white, elevation: 2.0, child: loginBuilder()),
      ),
    );
  }

  @override
  initState() {
    super.initState();
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
    super.dispose();
  }

  _login(BuildContext context) {
    // if (this.password.length > 0 && this.username.length > 0) {
    /*
      loginBloc.loginSink.add(
          new LoginViewModel.withPW(
              username: username,
              password: password,
              rememberMe: rememberMe));
      */

    Login login = Login(
        action: 'Anmelden',
        clientId: globals.clientId,
        createAuthKey: rememberMe,
        username: username?.trim(),
        password: password?.trim(),
        requestType: RequestType.LOGIN);

    BlocProvider.of<ApiBloc>(context).dispatch(login);
    // } else {
    //   showError(context, Translations.of(context).text2('Error', 'Error'), Translations.of(context).text2('Please enter your username and password.'));
    // }
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return loginCard();
  }
}
