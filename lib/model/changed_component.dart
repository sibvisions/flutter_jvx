

class ChangedComponent {
  String id;
  String name;
  String className;
  int verticalAlignment;
  String text;
  bool eventAction;
  String parent;
  int indexOf;
  String constraint;
  String layout;
  bool mobileAutoclose;

  ChangedComponent({
    this.id,
    this.name,
    this.className,
    this.verticalAlignment,
    this.text,
    this.eventAction,
    this.parent,
    this.indexOf,
    this.constraint,
    this.layout,
    this.mobileAutoclose
  });

  ChangedComponent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    layout = json['layout'];
    mobileAutoclose = json['mobile.autoclose'];
    className = json['className'];

    verticalAlignment = json['verticalAlignment'];
    text = json['text'];
    eventAction = json['eventAction'];
    parent = json['parent'];
    indexOf = json['indexOf'];
    constraint = json['constraints'];
  }
}