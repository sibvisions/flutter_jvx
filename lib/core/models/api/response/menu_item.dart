class MenuItem {
  String componentId;
  String group;
  String image;
  String text;

  MenuItem({this.componentId, this.group, this.image, this.text});

  MenuItem.fromJson(Map<String, dynamic> json)
      : componentId = json['componentId'],
        group = json['group'],
        image = json['image'],
        text = json['text'];
}
