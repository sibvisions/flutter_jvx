import "../jvx_form_layout.dart";

//****************************************************************
// Subclass definition
//****************************************************************

///
/// The Anchor gives the possible horizontal and vertical positions.
///
/// @author Martin Handsteiner, ported by Jürgen Hörmann
///

class JVxAnchor {
  /// Constant for horizontal anchors.
  static const HORIZONTAL = 0;

  /// Constant for vertical anchors.
  static const VERTICAL = 1;
  
  /// The name of this anchor.
  String name;

  /// The layout for this anchor.
  JVxFormLayout layout;

  /// The orientation of this anchor.
  int orientation = 0;

  /// The related anchor to this anchor.
  JVxAnchor relatedAnchor;

  /// true, if this anchor should be auto sized.
  bool autoSize = false;


  /// The position of this anchor.
  bool autoSizeCalculated = false;

  /// The position of this anchor.
  int _position = 0;

  ///
  /// Sets the position of this Anchor.
  /// It is not allowed to set the position of a border anchor.
  ///
  /// @param pPosition the position to set
  ///
  set position(int pPosition) {
    /*if (relatedAnchor == null) {
      throw new ArgumentError("Position of border anchor may not be set!");
    }
    else {*/
      _position = pPosition;
    //}
  }
  get position {
    return _position;
  }

  /// True, if the anchor is not calculated by components preferred size.
  bool relative = false;

  /// True, if the relative anchor is not calculated.
  bool firstCalculation = false;

  bool isBorderAnchor() => relatedAnchor == null;

  JVxAnchor(this.layout, this.orientation, this.name) {
    relatedAnchor = null;
    autoSize = false;
    _position = 0;
  }

  JVxAnchor.fromAnchor(pRelatedAnchor, this.name) {
    layout = pRelatedAnchor.layout;
    orientation = pRelatedAnchor.orientation;
    relatedAnchor = pRelatedAnchor;
    autoSize = true;
    _position = 0;
  }

  JVxAnchor.fromAnchorAndPosition(pRelatedAnchor, int pPosition, this.name) {
    layout = pRelatedAnchor.layout;
    orientation = pRelatedAnchor.orientation;
    relatedAnchor = pRelatedAnchor;
    autoSize = false;
    _position = pPosition;
  }

  ///
  /// true, if pRelatedAnchor has a cycle reference to this anchor.
  ///
  /// @param pRelatedAnchor the relatedAnchor to set.
  /// @return true, if pRelatedAnchor has a cycle reference to this anchor.
  ///
  bool hasCycleReference(JVxAnchor pRelatedAnchor) {
    do {
      if (pRelatedAnchor == this) {
        return true;
      }
      pRelatedAnchor = pRelatedAnchor.relatedAnchor;
    }
    while (pRelatedAnchor != null);

    return false;
  }

  ///
  /// Sets the related Anchor.
  /// It is only allowed to choose an anchor with same orientation from the same layout.
  ///
  /// @param pRelatedAnchor the relatedAnchor to set.
  ///
  void setRelatedAnchor(JVxAnchor pRelatedAnchor) {
    if (layout != pRelatedAnchor.layout ||
        orientation != pRelatedAnchor.orientation) {
      throw new ArgumentError(
          "The related anchor must have the same layout and the same orientation!");
    }
    else if (hasCycleReference(pRelatedAnchor)) {
      throw new ArgumentError(
          "The related anchor has a cycle reference to this anchor!");
    }
    else {
      relatedAnchor = pRelatedAnchor;
    }
  }

  ///
  /// Returns the absolute position of this Anchor in this FormLayout.
  /// The position is only correct if the layout is valid.
  ///
  /// @return the absolute position.
  ///
  int getAbsolutePosition() {
    if (relatedAnchor == null) {
      return _position;
    }
    else {
      return relatedAnchor.getAbsolutePosition() + _position;
    }
  }

  ///
  /// Gets the related border anchor to this anchor.
  ///
  /// @return the related border anchor.
  ///
  JVxAnchor getBorderAnchor() {
    JVxAnchor borderAnchor = this;
    while (borderAnchor.relatedAnchor != null) {
      borderAnchor = borderAnchor.relatedAnchor;
    }
    return borderAnchor;
  }

  ///
  /// Gets the related unused auto size anchor.
  ///
  /// @return the related unused auto size anchor.
  ///
  JVxAnchor getRelativeAnchor() {
    JVxAnchor relativeAnchor = this;
    while (relativeAnchor != null && !relativeAnchor.relative) {
      relativeAnchor = relativeAnchor.relatedAnchor;
    }
    return relativeAnchor;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'position': _position,
    'orientation': orientation,
    'autoSize': autoSize,
    'relative': relative,
    'autoSizeCalculated': autoSizeCalculated,
    'firstCalculation': firstCalculation,
    'relatedAnchor': relatedAnchor?.toJson(),
    'layout': layout?.toString(),
    'isBorderAnchor': isBorderAnchor(),
    'hashCode': this.hashCode.toString(),
  };
}