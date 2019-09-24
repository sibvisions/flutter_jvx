import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/inherited/login_provider.dart';
import 'package:jvx_mobile_v3/ui/widgets/login_widget.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

enum LoginValidationType { username, password }

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final scaffoldState = GlobalKey<ScaffoldState>();

  Widget loginScaffold() => LoginProvider(
    validationErrorCallback: showValidationError,
    child: Scaffold(
      key: scaffoldState,
      backgroundColor: globals.applicationStyle != null ? Color(int.parse('0xFF${globals.applicationStyle.loginBackground.substring(1)}')) : null,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 100, 8, 8),
            child: globals.applicationStyle != null ? Image.asset(
              '${globals.dir}${globals.applicationStyle.loginIcon}',
              fit: BoxFit.none,
              alignment: Alignment.topCenter,
            ) : Container(),
          ),
          LoginWidgets()
        ],
      ),
    ),
  );

  showValidationError(LoginValidationType type) {
    scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text(type == LoginValidationType.username
          ? Translations.of(context).text2('enter_valid_username', 'Enter a valid username')
          : Translations.of(context).text2('enter_valid_password', 'Enter a valid password'),
      ),
      duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loginScaffold();
  }
}