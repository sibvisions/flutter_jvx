enum BorderLayoutConstraints {
  NORTH,
  WEST,
  SOUTH,
  EAST,
  CENTER
}

enum UIComponents {
  BUTTON,
  LABEL,
  PANEL
}

class JvxComponent {
  String id;
  String name;
  UIComponents className;
  int verticalAlignment;
  String text;
  bool eventAction;
  String parent;
  int indexOf;
  BorderLayoutConstraints constraint;
  String layout;
  bool mobileAutoclose;

  JvxComponent({
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

  JvxComponent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    layout = json['layout'];
    mobileAutoclose = json['mobile.autoclose'];

    switch (json['className']) {
      case 'Panel':
        className = UIComponents.PANEL;
        break;
      case 'Button':
        className = UIComponents.BUTTON;
        break;
      default:
        className = UIComponents.LABEL;
        break;
    }

    verticalAlignment = json['verticalAlignment'];
    text = json['text'];
    eventAction = json['eventAction'];
    parent = json['parent'];
    indexOf = json['indexOf'];

    switch (json['constraint']) {
      case 'North':
        constraint = BorderLayoutConstraints.NORTH;
        break;
      case 'West':
        constraint = BorderLayoutConstraints.WEST;
        break;
      case 'South':
        constraint = BorderLayoutConstraints.SOUTH;
        break;
      case 'East':
        constraint = BorderLayoutConstraints.EAST;
        break;
      default:
        constraint = BorderLayoutConstraints.CENTER;
        break;
    }
  }
}