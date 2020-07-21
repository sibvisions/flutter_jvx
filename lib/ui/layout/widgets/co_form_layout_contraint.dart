import '../../component/component.dart';
import 'co_form_layout_anchor.dart';

class CoFormLayoutConstraint {
  /// The top anchor.
  CoFormLayoutAnchor _topAnchor;

  /// The left anchor.
  CoFormLayoutAnchor _leftAnchor;

  /// The bottom anchor.
  CoFormLayoutAnchor _bottomAnchor;

  /// The right anchor.
  CoFormLayoutAnchor _rightAnchor;

  Component comp;

  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  /// Initialization
  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ///
  /// Constructs Constraints with the given anchors as bounds.
  /// @param pTopAnchor the left anchor.
  /// @param pLeftAnchor the left anchor.
  /// @param pBottomAnchor the left anchor.
  /// @param pRightAnchor the left anchor.
  ///
  CoFormLayoutConstraint(
      CoFormLayoutAnchor pTopAnchor,
      CoFormLayoutAnchor pLeftAnchor,
      CoFormLayoutAnchor pBottomAnchor,
      CoFormLayoutAnchor pRightAnchor) {
    if (pLeftAnchor == null && pRightAnchor != null) {
      pLeftAnchor = new CoFormLayoutAnchor.fromAnchor(pRightAnchor, "l");
    } else if (pRightAnchor == null && pLeftAnchor != null) {
      pRightAnchor = new CoFormLayoutAnchor.fromAnchor(pLeftAnchor, "r");
    }
    if (pTopAnchor == null && pBottomAnchor != null) {
      pTopAnchor = new CoFormLayoutAnchor.fromAnchor(pBottomAnchor, "t");
    } else if (pBottomAnchor == null && pTopAnchor != null) {
      pBottomAnchor = new CoFormLayoutAnchor.fromAnchor(pTopAnchor, "b");
    }

    leftAnchor = pLeftAnchor;
    rightAnchor = pRightAnchor;
    topAnchor = pTopAnchor;
    bottomAnchor = pBottomAnchor;
  }

  ///
  /// Constructs Constraints with the given anchors as bounds.
  /// @param pTopAnchor the left anchor.
  /// @param pLeftAnchor the left anchor.
  ///
  CoFormLayoutConstraint.fromTopLeftAnchor(
      CoFormLayoutAnchor pTopAnchor, CoFormLayoutAnchor pLeftAnchor) {
    CoFormLayoutConstraint(pTopAnchor, pLeftAnchor, null, null);
  }

  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  /// User-defined methods
  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ///
  /// Returns the left anchor.
  ///
  /// @return the left anchor.
  ///
  CoFormLayoutAnchor get leftAnchor {
    return _leftAnchor;
  }

  ///
  /// Sets the left anchor.
  ///
  /// @param pLeftAnchor left to set
  ///
  set leftAnchor(CoFormLayoutAnchor pLeftAnchor) {
    if (pLeftAnchor == null && _rightAnchor != null) {
      _leftAnchor = new CoFormLayoutAnchor.fromAnchor(_rightAnchor, "l");
    } else if (pLeftAnchor.orientation == CoFormLayoutAnchor.VERTICAL) {
      throw new ArgumentError(
          "A vertical anchor can not be used as left anchor!");
    } else {
      _leftAnchor = pLeftAnchor;
    }
  }

  ///
  /// Returns the right anchor.
  ///
  /// @return the right anchor.
  ///
  CoFormLayoutAnchor get rightAnchor {
    return _rightAnchor;
  }

  ///
  /// Sets the right anchor.
  ///
  /// @param pRightAnchor the right anchor.
  ///
  set rightAnchor(CoFormLayoutAnchor pRightAnchor) {
    if (pRightAnchor == null && _leftAnchor != null) {
      _rightAnchor = new CoFormLayoutAnchor.fromAnchor(_leftAnchor, "r");
    } else if (pRightAnchor.orientation == CoFormLayoutAnchor.VERTICAL) {
      throw new ArgumentError(
          "A vertical anchor can not be used as right anchor!");
    } else {
      _rightAnchor = pRightAnchor;
    }
  }

  ///
  /// Returns the top anchor.
  ///
  /// @return the top anchor.
  ///
  CoFormLayoutAnchor get topAnchor {
    return _topAnchor;
  }

  ///
  /// Sets the top anchor.
  ///
  /// @param pTopAnchor the top anchor
  ///
  set topAnchor(CoFormLayoutAnchor pTopAnchor) {
    if (pTopAnchor == null && _bottomAnchor != null) {
      _topAnchor = new CoFormLayoutAnchor.fromAnchor(_bottomAnchor, "t");
    } else if (pTopAnchor.orientation == CoFormLayoutAnchor.HORIZONTAL) {
      throw new ArgumentError(
          "A horizontal anchor can not be used as top anchor!");
    } else {
      _topAnchor = pTopAnchor;
    }
  }

  ///
  /// Returns the bottom anchor.
  ///
  /// @return the bottom anchor.
  ///
  CoFormLayoutAnchor get bottomAnchor {
    return _bottomAnchor;
  }

  ///
  /// Sets the bottom anchor.
  ///
  /// @param pBottomAnchor the bottom to set
  ///
  set bottomAnchor(CoFormLayoutAnchor pBottomAnchor) {
    if (pBottomAnchor == null && _topAnchor != null) {
      _bottomAnchor = new CoFormLayoutAnchor.fromAnchor(_topAnchor, "b");
    } else if (pBottomAnchor.orientation == CoFormLayoutAnchor.HORIZONTAL) {
      throw new ArgumentError(
          "A vertical anchor can not be used as bottom anchor!");
    } else {
      _bottomAnchor = pBottomAnchor;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bottomAnchor': bottomAnchor.toJson(),
        'leftAnchor': leftAnchor.toJson(),
        'rightAnchor': rightAnchor.toJson(),
        'topAnchor': topAnchor.toJson(),
        'hashCode': this.hashCode.toString(),
      };
}
