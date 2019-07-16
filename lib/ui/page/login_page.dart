import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/inherited/login_provider.dart';
import 'package:jvx_mobile_v3/ui/widgets/login_background.dart';
import 'package:jvx_mobile_v3/ui/widgets/login_widget.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

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
      backgroundColor: Color(0xffeeeeee),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[LoginBackground(), LoginWidgets()],
      ),
    ),
  );

  showValidationError(LoginValidationType type) {
    scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text(type == LoginValidationType.username
          ? UIData.enter_valid_number
          : UIData.enter_valid_otp),
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