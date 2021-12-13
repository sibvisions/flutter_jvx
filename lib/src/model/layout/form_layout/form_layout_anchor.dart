enum Orientation { HORIZONTAL, VERTICAL }

class FormLayoutAnchor {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of anchor
  final String name;

  /// String of anchor, data gets extracted from it.
  final String anchorData;

  /// The name of the related anchor to the current anchor.
  final String? relatedAnchorName;

  /// The orientation of this anchor.
  final Orientation orientation;

  /// true, if this anchor should be auto sized.
  final bool autoSize;

  /// The related anchor to the current anchor.
  FormLayoutAnchor? relatedAnchor;

  /// If autoSize has already been calculated.
  bool autoSizeCalculated;

  /// True, if the relative anchor is not calculated.
  bool firstCalculation;

  /// True, if the anchor is not calculated by components preferred size.
  bool relative;

  /// The position of this anchor.
  double position;

  FormLayoutAnchor(
      {required this.name,
      required this.orientation,
      required this.autoSize,
      required this.position,
      required this.firstCalculation,
      required this.autoSizeCalculated,
      required this.anchorData,
      required this.relative,
      this.relatedAnchor,
      this.relatedAnchorName});

  FormLayoutAnchor.fromAnchorData({required String pAnchorData})
      : anchorData = pAnchorData,
        name = pAnchorData.split(",")[0],
        relatedAnchorName = pAnchorData.split(",")[1],
        autoSize = pAnchorData.split(",")[3] == "a",
        autoSizeCalculated = false,
        firstCalculation = true,
        relative = false,
        position = double.parse(pAnchorData.split(",")[4]),
        orientation = getOrientationFromData(anchorName: pAnchorData.split(",")[0]);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns wether the orientation of the anchor is horizontal or vertical
  static Orientation getOrientationFromData({required String anchorName}) {
    if (anchorName.startsWith("l") || anchorName.startsWith("r")) {
      return Orientation.HORIZONTAL;
    } else {
      return Orientation.VERTICAL;
    }
  }

  /// Returns the absolute position of this Anchor in this FormLayout.
  /// The position is only correct if the layout is valid.
  double getAbsolutePosition() {
    FormLayoutAnchor? iRelatedAnchor = relatedAnchor;
    if (iRelatedAnchor != null) {
      return iRelatedAnchor.getAbsolutePosition() + position;
    } else {
      return position;
    }
  }

  /// Gets the related border anchor to this anchor.
  FormLayoutAnchor getBorderAnchor() {
    FormLayoutAnchor start = this;
    while (start.relatedAnchor != null) {
      start = start.relatedAnchor!;
    }
    return start;
  }

  /// Gets the related unused auto size anchor.
  FormLayoutAnchor getRelativeAnchor() {
    FormLayoutAnchor? start = this;
    while (start != null && !start.relative && start.relatedAnchor != null) {
      start = start.relatedAnchor;
    }
    return start ?? this;
  }
}
