import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/widgets/login_background.dart';
import 'package:jvx_mobile_v3/ui/widgets/login_card.dart';

class LoginWidgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100,),
            LoginCard()
          ],
        ),
      ),
    );
  }
}