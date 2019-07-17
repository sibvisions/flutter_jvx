import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_scaffold.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appTitle: 'Menu', 
      bodyData: Center(
        child: Text('Hallo')
      ),
    );
  }
}