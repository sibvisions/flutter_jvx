import '../response_object.dart';
import 'menu_item.dart';

class Menu extends ResponseObject {
  List<MenuItem> entries;
  
  Menu();

  Menu.fromJson(Map<String, dynamic> json)
    : entries = readMenuItemListFromJson(json['entries']),
      super.fromJson(json);

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