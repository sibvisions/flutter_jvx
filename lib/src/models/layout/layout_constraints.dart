class LayoutConstraints {
  String id;
  double width;
  double height;
  double? top;
  double? left;
  double? right;
  double? bottom;

  LayoutConstraints(
      {required this.id,
      required this.width,
      required this.height,
      this.top,
      this.left,
      this.right,
      this.bottom});
}
