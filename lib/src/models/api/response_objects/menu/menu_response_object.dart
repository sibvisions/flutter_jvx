import '../../response_object.dart';
import 'menu_item.dart';

class MenuResponseObject extends ResponseObject {
  List<MenuItem> entries;

  MenuResponseObject({required String name, required this.entries})
      : super(name: name);

  MenuResponseObject.fromJson({required Map<String, dynamic> map})
      : entries = map['entries'] != null
            ? getEntries(entries: map['entries'])
            : <MenuItem>[],
        super.fromJson(map: map);

  static getEntries({required List<dynamic> entries}) {
    List<MenuItem> menuEntries = <MenuItem>[];

    for (int i = 0; i < entries.length; i++) {
      menuEntries.add(MenuItem.fromJson(map: entries[i]));
    }

    return menuEntries;
  }
}
