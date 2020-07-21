import 'so_action.dart';

class MenuItem {
  SoAction action;
  String group;
  String image;

  MenuItem({this.action, this.group, this.image});

  MenuItem.fromJson(Map<String, dynamic> json)
      : action = SoAction.fromJson(json['action']),
        group = json['group'],
        image = json['image'];
}
