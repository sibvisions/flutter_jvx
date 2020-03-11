
class Action {
  String componentId;
  String label;

  Action({this.componentId, this.label});

  Action.fromJson(Map<String, dynamic> json)
    : componentId = json['componentId'],
      label = json['label']!=null?json['label']:null;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'componentId': componentId,
    'label': label
  };
}