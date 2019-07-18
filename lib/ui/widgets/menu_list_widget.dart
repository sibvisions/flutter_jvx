import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';

class MenuListWidget extends StatelessWidget {
  final List<MenuItem> menuItems;

  const MenuListWidget({Key key, @required this.menuItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: this.menuItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(this.menuItems[index].action.label),
            subtitle: Text('Group: ' + this.menuItems[index].group),
            onTap: () {
              print("Pressed Menu Item" + this.menuItems[index].action.label);
            },
          );
        },
      ),
    );
  }
}