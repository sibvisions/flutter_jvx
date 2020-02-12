import '../../../model/api/response/response_object.dart';
import '../../../model/menu_item.dart';

class Menu extends ResponseObject {
  List<MenuItem> items;
  String name;
  String componentId;

  Menu({this.items});

  Menu.fromJson(Map<String, dynamic> json)
    : items = readMenuItemListFromJson(json['items']),
      name = json['name'],
      componentId = json['componentId'];
  
  static readMenuItemListFromJson(List items) {
    List<MenuItem> convertedMenuItems = new List<MenuItem>();
    try {
      for (int i = 0; i < items.length; i++) {
        convertedMenuItems.add(MenuItem.fromJson(items[i]));
      }
    } catch (e) {
      print(e.toString());
    }
    return convertedMenuItems;
  }
}