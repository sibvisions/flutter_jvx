import 'package:flutter/material.dart';
import '../../ui/widgets/login_card.dart';

class LoginWidgets extends StatelessWidget {
  final String username;

  const LoginWidgets({Key key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              LoginCard(
                username: username,
              )
            ],
          ),
        ),
      ),
    );
  }
}
