import "jvx_form_layout_anchor.dart";


class Constraint {
  /// The top anchor.
  Anchor _topAnchor;
  /// The left anchor.
  Anchor _leftAnchor;
  /// The bottom anchor.
  Anchor _bottomAnchor;
  /// The right anchor.
  Anchor _rightAnchor;

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
  Constraint(Anchor pTopAnchor, Anchor pLeftAnchor, Anchor pBottomAnchor, Anchor pRightAnchor) {
    if (pLeftAnchor == null && pRightAnchor != null)
    {
      pLeftAnchor = new Anchor.fromAnchor(pRightAnchor);
    }
    else if (pRightAnchor == null && pLeftAnchor != null)
    {
      pRightAnchor = new Anchor.fromAnchor(pLeftAnchor);
    }
    if (pTopAnchor == null && pBottomAnchor != null)
    {
      pTopAnchor = new Anchor.fromAnchor(pBottomAnchor);
    }
    else if (pBottomAnchor == null && pTopAnchor != null)
    {
      pBottomAnchor = new Anchor.fromAnchor(pTopAnchor);
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
  Constraint.fromTopLeftAnchor(Anchor pTopAnchor, Anchor pLeftAnchor)
  {
    Constraint(pTopAnchor, pLeftAnchor, null, null);
  }

  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  /// User-defined methods
  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ///
  /// Returns the left anchor.
  ///
  /// @return the left anchor.
  ///
  Anchor get leftAnchor
  {
    return _leftAnchor;
  }

  ///
  /// Sets the left anchor.
  ///
  /// @param pLeftAnchor left to set
  ///
  set leftAnchor(Anchor pLeftAnchor)
  {
    if (pLeftAnchor == null && _rightAnchor != null)
    {
      _leftAnchor = new Anchor.fromAnchor(_rightAnchor);
    }
    else if (pLeftAnchor.orientation == Anchor.VERTICAL)
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
  Anchor get rightAnchor
  {
    return _rightAnchor;
  }

  ///
  /// Sets the right anchor.
  ///
  /// @param pRightAnchor the right anchor.
  ///
  set rightAnchor(Anchor pRightAnchor)
  {
    if (pRightAnchor == null && _leftAnchor != null)
    {
      _rightAnchor = new Anchor.fromAnchor(_leftAnchor);
    }
    else if (pRightAnchor.orientation == Anchor.VERTICAL)
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
  Anchor get topAnchor
  {
    return _topAnchor;
  }

  ///
  /// Sets the top anchor.
  ///
  /// @param pTopAnchor the top anchor
  ///
  set topAnchor(Anchor pTopAnchor)
  {
    if (pTopAnchor == null && _bottomAnchor != null)
    {
      _topAnchor = new Anchor.fromAnchor(_bottomAnchor);
    }
    else if (pTopAnchor.orientation == Anchor.HORIZONTAL)
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
  Anchor get bottomAnchor
  {
    return _bottomAnchor;
  }

  ///
  /// Sets the bottom anchor.
  ///
  /// @param pBottomAnchor the bottom to set
  ///
  set bottomAnchor(Anchor pBottomAnchor)
  {
    if (pBottomAnchor == null && _topAnchor != null)
    {
      _bottomAnchor = new Anchor.fromAnchor(_topAnchor);
    }
    else if (pBottomAnchor.orientation == Anchor.HORIZONTAL)
    {
      throw new ArgumentError("A vertical anchor can not be used as bottom anchor!");
    }
    else
    {
      _bottomAnchor = pBottomAnchor;
    }
  }

}

