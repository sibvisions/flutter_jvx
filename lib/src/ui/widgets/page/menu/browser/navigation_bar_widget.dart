import 'package:flutter/material.dart';

class NavigationBarWidget extends StatelessWidget {
  final Widget child;

  const NavigationBarWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Home',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(width: 100.0),
              Text(
                'About',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(width: 100.0),
              Text(
                'Contact',
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
        Expanded(child: child)
      ],
    );
  }
}
