import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';

import "jvx_form_layout_anchor.dart";


class JVxFormLayoutConstraint {
  /// The top anchor.
  JVxAnchor _topAnchor;
  /// The left anchor.
  JVxAnchor _leftAnchor;
  /// The bottom anchor.
  JVxAnchor _bottomAnchor;
  /// The right anchor.
  JVxAnchor _rightAnchor;

  JVxComponent comp;

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
  JVxFormLayoutConstraint(JVxAnchor pTopAnchor, JVxAnchor pLeftAnchor, JVxAnchor pBottomAnchor, JVxAnchor pRightAnchor) {
    if (pLeftAnchor == null && pRightAnchor != null)
    {
      pLeftAnchor = new JVxAnchor.fromAnchor(pRightAnchor, "l");
    }
    else if (pRightAnchor == null && pLeftAnchor != null)
    {
      pRightAnchor = new JVxAnchor.fromAnchor(pLeftAnchor, "r");
    }
    if (pTopAnchor == null && pBottomAnchor != null)
    {
      pTopAnchor = new JVxAnchor.fromAnchor(pBottomAnchor, "t");
    }
    else if (pBottomAnchor == null && pTopAnchor != null)
    {
      pBottomAnchor = new JVxAnchor.fromAnchor(pTopAnchor, "b");
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
  JVxFormLayoutConstraint.fromTopLeftAnchor(JVxAnchor pTopAnchor, JVxAnchor pLeftAnchor)
  {
    JVxFormLayoutConstraint(pTopAnchor, pLeftAnchor, null, null);
  }

  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  /// User-defined methods
  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ///
  /// Returns the left anchor.
  ///
  /// @return the left anchor.
  ///
  JVxAnchor get leftAnchor
  {
    return _leftAnchor;
  }

  ///
  /// Sets the left anchor.
  ///
  /// @param pLeftAnchor left to set
  ///
  set leftAnchor(JVxAnchor pLeftAnchor)
  {
    if (pLeftAnchor == null && _rightAnchor != null)
    {
      _leftAnchor = new JVxAnchor.fromAnchor(_rightAnchor, "l");
    }
    else if (pLeftAnchor.orientation == JVxAnchor.VERTICAL)
    {
      throw new ArgumentError("A vertical anchor can not be used as left anchor!");
    }
    else
    {
      _leftAnchor = pLeftAnchor;
    }
  }

  ///
  /// Returns the right anchor.
  ///
  /// @return the right anchor.
  ///
  JVxAnchor get rightAnchor
  {
    return _rightAnchor;
  }

  ///
  /// Sets the right anchor.
  ///
  /// @param pRightAnchor the right anchor.
  ///
  set rightAnchor(JVxAnchor pRightAnchor)
  {
    if (pRightAnchor == null && _leftAnchor != null)
    {
      _rightAnchor = new JVxAnchor.fromAnchor(_leftAnchor, "r");
    }
    else if (pRightAnchor.orientation == JVxAnchor.VERTICAL)
    {
      throw new ArgumentError("A vertical anchor can not be used as right anchor!");
    }
    else
    {
      _rightAnchor = pRightAnchor;
    }
  }

  ///
  /// Returns the top anchor.
  ///
  /// @return the top anchor.
  ///
  JVxAnchor get topAnchor
  {
    return _topAnchor;
  }

  ///
  /// Sets the top anchor.
  ///
  /// @param pTopAnchor the top anchor
  ///
  set topAnchor(JVxAnchor pTopAnchor)
  {
    if (pTopAnchor == null && _bottomAnchor != null)
    {
      _topAnchor = new JVxAnchor.fromAnchor(_bottomAnchor, "t");
    }
    else if (pTopAnchor.orientation == JVxAnchor.HORIZONTAL)
    {
      throw new ArgumentError("A horizontal anchor can not be used as top anchor!");
    }
    else
    {
      _topAnchor = pTopAnchor;
    }
  }

  ///
  /// Returns the bottom anchor.
  ///
  /// @return the bottom anchor.
  ///
  JVxAnchor get bottomAnchor
  {
    return _bottomAnchor;
  }

  ///
  /// Sets the bottom anchor.
  ///
  /// @param pBottomAnchor the bottom to set
  ///
  set bottomAnchor(JVxAnchor pBottomAnchor)
  {
    if (pBottomAnchor == null && _topAnchor != null)
    {
      _bottomAnchor = new JVxAnchor.fromAnchor(_topAnchor, "b");
    }
    else if (pBottomAnchor.orientation == JVxAnchor.HORIZONTAL)
    {
      throw new ArgumentError("A vertical anchor can not be used as bottom anchor!");
    }
    else
    {
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

