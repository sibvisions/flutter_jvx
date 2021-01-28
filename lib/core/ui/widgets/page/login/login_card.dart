import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_flutterclient/core/models/api/response/menu_item.dart';
import 'package:jvx_flutterclient/core/models/app/menu_arguments.dart';
import 'package:jvx_flutterclient/core/ui/pages/menu_page.dart';
import 'package:jvx_flutterclient/core/ui/pages/settings_page.dart';
import 'package:jvx_flutterclient/core/ui/widgets/dialogs/dialogs.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/shared_pref_provider.dart';

import '../../../../models/api/request.dart';
import '../../../../models/api/request/login.dart';
import '../../../../models/app/app_state.dart';
import '../../../../services/remote/bloc/api_bloc.dart';
import '../../../../utils/app/text_utils.dart';
import '../../../../utils/translation/app_localizations.dart';
import 'gradient_button.dart';

class LoginCard extends StatefulWidget {
  final String username;
  final AppState appState;

  final focus = FocusNode();

  LoginCard({Key key, this.username, this.appState}) : super(key: key);

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
                (widget.appState.applicationStyle != null &&
                        widget.appState.applicationStyle?.loginTitle != null)
                    ? new Text(
                        widget.appState.applicationStyle?.loginTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : AutoSizeText(
                        widget.appState.appName,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: TextEditingController(text: username ?? ''),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(widget.focus);
                      },
                      autocorrect: false,
                      onChanged: (username) => this.username = username,
                      style: new TextStyle(fontSize: 14.0, color: Colors.black),
                      decoration: new InputDecoration(
                          hintStyle: TextStyle(color: Colors.green),
                          labelText:
                              AppLocalizations.of(context).text("Username:"),
                          labelStyle: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w600)),
                    )),
                new SizedBox(
                  height: 10.0,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      focusNode: widget.focus,
                      onChanged: (password) => this.password = password,
                      style: new TextStyle(fontSize: 14.0, color: Colors.black),
                      decoration: new InputDecoration(
                          labelText:
                              AppLocalizations.of(context).text('Password:'),
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
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool val) {
                        setState(() {
                          rememberMe = val;
                        });
                      },
                    ),
                    FlatButton(
                        onPressed: () {
                          setState(() {
                            rememberMe = !rememberMe;
                          });
                        },
                        padding: EdgeInsets.zero,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Text(
                          AppLocalizations.of(context).text('Remember me?'),
                          style: Theme.of(context).textTheme.body2,
                        )),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                        child: new GradientButton(
                            appState: widget.appState,
                            onPressed: () {
                              TextUtils.unfocusCurrentTextfield(context);
                              _login(context);
                            },
                            text: AppLocalizations.of(context)
                                .text('Login')
                                .toUpperCase()))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        child: new FlatButton.icon(
                          onPressed: () {
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              Navigator.of(context)
                                  .pushNamed(SettingsPage.route);
                            });
                          },
                          label: Text(
                              AppLocalizations.of(context).text('Settings')),
                          icon: FaIcon(
                            FontAwesomeIcons.cog,
                            color: Theme.of(context).primaryColor,
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
        width: !kIsWeb ? deviceSize.width * 0.85 : 400,
        child: new Card(
            color: Colors.white, elevation: 2.0, child: loginBuilder()),
      ),
    );
  }

  @override
  initState() {
    super.initState();
    username = widget.username;
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
    if (widget.appState.isOffline) {
      bool loginSuccess = SharedPrefProvider.of(context)
          .manager
          .login(username?.trim(), password?.trim());

      if (loginSuccess) {
        Navigator.of(context).pushReplacementNamed(MenuPage.route,
            arguments: MenuArguments(<MenuItem>[], true, null));
      } else {
        showError(context, 'Login error', 'False username or password');
      }
    } else {
      Login login = Login(
          clientId: widget.appState.clientId,
          createAuthKey: rememberMe,
          username: username?.trim(),
          password: password?.trim(),
          requestType: RequestType.LOGIN);

      BlocProvider.of<ApiBloc>(context).add(login);
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return loginCard();
  }
}
