import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/widgets/page/menu/browser/navigation_bar_widget.dart';

class BrowserMenuWidget extends StatefulWidget {
  @override
  _BrowserMenuWidgetState createState() => _BrowserMenuWidgetState();
}

class _BrowserMenuWidgetState extends State<BrowserMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return NavigationBarWidget(
      child: Center(
        child: Text('HELLO'),
      ),
    );
  }
}
