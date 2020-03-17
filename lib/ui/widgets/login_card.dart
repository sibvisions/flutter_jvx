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
  @override
  _LoginCardState createState() => new _LoginCardState();
}

class _LoginCardState extends State<LoginCard>
    with SingleTickerProviderStateMixin {
  var deviceSize;
  bool rememberMe = false;
  AnimationController controller;
  Animation<double> animation;
  String username = '',
      password = '';

  Widget loginBuilder() =>
    Form(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: SingleChildScrollView(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (globals.applicationStyle != null && globals.applicationStyle.loginTitle != null)
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
              new TextField(
                onChanged: (username) => this.username = username,
                style: new TextStyle(
                    fontSize: 15.0, color: Colors.black),
                decoration: new InputDecoration(
                  // hintText: Translations.of(context).text2("Username:"),
                    labelText: Translations.of(context)
                        .text2("Username:", 'Username:'),
                    labelStyle: TextStyle(fontWeight: FontWeight.w700)),
              ),
              new SizedBox(
                height: 10.0,
              ),
              new TextField(
                onSubmitted: (String value) {
                  _login(context);
                },
                onChanged: (password) => this.password = password,
                style: new TextStyle(
                    fontSize: 15.0, color: Colors.black),
                decoration: new InputDecoration(
                    labelText: Translations.of(context)
                        .text2('Password:', 'Password:'),
                    labelStyle: TextStyle(fontWeight: FontWeight.w700)),
                obscureText: true,
              ),
              SizedBox(height: 10,),
              new CheckboxListTile(
                onChanged: (bool val) {
                  setState(() {
                    rememberMe = val;
                  });
                },
                value: rememberMe,
                title: Text(Translations.of(context)
                    .text2('Remember me?', 'Remember me?')),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: UIData.ui_kit_color_2,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  child: new GradientButton(
                      onPressed: () {
                        _login(context);
                      },
                      text: Translations.of(context)
                          .text2('Login', 'Login'))),
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
        username: username,
        password: password,
        requestType: RequestType.LOGIN
      );

      BlocProvider.of<ApiBloc>(context).dispatch(login);
    // } else {
    //   showError(context, Translations.of(context).text2('Error', 'Error'), Translations.of(context).text2('Please enter your username and password.'));
    // }
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery
        .of(context)
        .size;
    return loginCard();
  }
}
