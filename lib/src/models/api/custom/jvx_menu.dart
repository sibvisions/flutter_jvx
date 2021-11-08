class JVxMenu {

  List<JVxMenuGroup> menuGroups;

  JVxMenu({
    this.menuGroups = const []
  });

}

class JVxMenuGroup {
  final String name;
  final List<JVxMenuItem> items;

  JVxMenuGroup({
    required this.name,
    required this.items,
  });
}

class JVxMenuItem {
  final String componentId;
  final String? image;
  final String label;

  JVxMenuItem ({
    required this.componentId,
    this.image,
    required this.label
  });
}