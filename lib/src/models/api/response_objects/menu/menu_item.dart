class MenuItem {
  String componentId;
  String group;
  String? image;
  String text;

  MenuItem(
      {required this.componentId,
      required this.group,
      required this.image,
      required this.text});

  MenuItem.fromJson({required Map<String, dynamic> map})
      : componentId = map['componentId'],
        group = map['group'],
        image = map['image'],
        text = map['text'];
}
