class Margins {

  /// The top margin
  final double marginTop;

  /// The left margin
  final double marginLeft;

  /// The bottom margin
  final double marginBottom;

  /// The right margin
  final double marginRight;


  Margins({
    required this.marginBottom,
    required this.marginLeft,
    required this.marginRight,
    required this.marginTop
  });

  Margins.fromList({required List<String> marginList}) :
    marginTop = double.parse(marginList[0]),
    marginLeft = double.parse(marginList[1]),
    marginBottom = double.parse(marginList[2]),
    marginRight = double.parse(marginList[3]);
}