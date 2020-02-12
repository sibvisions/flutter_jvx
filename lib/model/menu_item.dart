import '../model/action.dart';

class MenuItem {
  Action action;
  String group;
  String image;

  MenuItem({this.action, this.group, this.image});

  MenuItem.fromJson(Map<String, dynamic> json)
    : action = Action.fromJson(json['action']),
      group = json['group'],
      image = json['image'];
}