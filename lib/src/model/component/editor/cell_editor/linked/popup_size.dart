class PopupSize {
  int? width;
  int? height;

  PopupSize();

  PopupSize.fromJson(Map<String, dynamic> json)
      : width = json['width'],
        height = json['height'];

  Map<String, dynamic> toJson() => <String, dynamic>{'width': width, 'height': height};
}
