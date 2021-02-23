class SoAction {
  String componentId;
  String label;
  String classNameEventSourceRef;

  SoAction({this.componentId, this.label, this.classNameEventSourceRef});

  SoAction.fromJson(Map<String, dynamic> json)
      : componentId = json['componentId'],
        label = json['label'] != null ? json['label'] : null;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'componentId': componentId, 'label': label};
}
