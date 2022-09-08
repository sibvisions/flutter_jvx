class PopupSize {
  int? width;
  int? height;

  PopupSize();

  PopupSize.fromJson(Map<String, dynamic> json)
      : width = json['width'],
        height = json['height'];

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
      };
}
