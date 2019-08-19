import 'package:flutter/material.dart';
import 'jvx_layout.dart';
import 'widgets/jvx_form_layout.dart';
import 'widgets/jvx_form_layout_contraint.dart';
import 'widgets/jvx_form_layout_anchor.dart';
import '../component/jvx_component.dart';

class JVxFormLayout extends JVxLayout {
  static final int stretch = 100;
  Key key;
  /// The valid state of anchor calculation. */
  bool _valid = false;
  /// the x-axis alignment (default: {@link JVxConstants#CENTER}). */
	int	horizontalAlignment = stretch;
	/// the y-axis alignment (default: {@link JVxConstants#CENTER}). */
	int	verticalAlignment = stretch;

  /// The left border anchor. */
  JVxAnchor leftAnchor;
  /// The left border anchor. */
  JVxAnchor rightAnchor;
  /// The left border anchor. */
  JVxAnchor topAnchor;
  /// The left border anchor. */
  JVxAnchor bottomAnchor;

  /// The left margin border anchor. */
  JVxAnchor leftMarginAnchor;
  /// The left margin border anchor. */
  JVxAnchor rightMarginAnchor;
  /// The left margin border anchor. */
  JVxAnchor topMarginAnchor;
  /// The left margin border anchor. */
  JVxAnchor bottomMarginAnchor;

  /// All left default anchors. */
  List<JVxAnchor> leftDefaultAnchors;
  /// All top default anchors. */
  List<JVxAnchor> topDefaultAnchors;
  /// All left default anchors. */
  List<JVxAnchor> rightDefaultAnchors;
  /// All top default anchors. */
  List<JVxAnchor> bottomDefaultAnchors;

  /// stores all constraints. */
  Map<JVxComponent, JVxConstraint> _layoutConstraints = <JVxComponent, JVxConstraint>{};

  ///
  /// Gets the margins.
  /// 
  /// @return the margins.
  ///
  EdgeInsets get margins
  {
    return new EdgeInsets.fromLTRB(leftMarginAnchor.position, topMarginAnchor.position, 
    -rightMarginAnchor.position, -bottomMarginAnchor.position);
  }
    
  ///
  /// Sets the margins.
  /// 
  /// @param pMargins the margins.
  ///
  set margins(EdgeInsets pMargins) 
  {
    if (pMargins == null)
    {
      topMarginAnchor.position = 0;
      leftMarginAnchor.position = 0;
      bottomMarginAnchor.position = 0;
      rightMarginAnchor.position = 0;
    }
    else
    {
      topMarginAnchor.position = pMargins.top.round();
      leftMarginAnchor.position = pMargins.left.round();
      bottomMarginAnchor.position = -pMargins.bottom.round();
      rightMarginAnchor.position = -pMargins.right.round();
    }
  }

  JVxFormLayout(this.key) {
    verticalGap = 5;
    horizontalGap = 5;
    leftAnchor = new JVxAnchor(this, JVxAnchor.HORIZONTAL);
    rightAnchor = new JVxAnchor(this, JVxAnchor.HORIZONTAL);
    topAnchor = new JVxAnchor(this, JVxAnchor.VERTICAL);
    bottomAnchor = new JVxAnchor(this, JVxAnchor.VERTICAL);
    leftMarginAnchor = new JVxAnchor.fromAnchorAndPosition(leftAnchor, 10);
    rightMarginAnchor = new JVxAnchor.fromAnchorAndPosition(rightAnchor, -10);
    topMarginAnchor = new JVxAnchor.fromAnchorAndPosition(topAnchor, 10);
    bottomMarginAnchor = new JVxAnchor.fromAnchorAndPosition(bottomAnchor, -10);
    leftDefaultAnchors = new List<JVxAnchor>();
    topDefaultAnchors = new List<JVxAnchor>();
    rightDefaultAnchors = new List<JVxAnchor>();
    bottomDefaultAnchors = new List<JVxAnchor>();
  }

  void addLayoutComponent(JVxComponent pComponent, JVxConstraint pConstraint)
  {
    JVxConstraint constraint;

    if (pConstraint != null)
    {
      constraint = pConstraint;
    }
    else
    {
      constraint = null;
    }
        
    if (constraint == null)
    {
      throw new ArgumentError("Constraint " + pConstraint.toString() + " is not allowed!");
    }
    /*else if (constraint.leftAnchor.layout != this
        || constraint.rightAnchor.layout != this
        || constraint.topAnchor.layout != this
        || constraint.bottomAnchor.layout != this)
    {
      throw new ArgumentError("Constraint " + pConstraint.toString() + " has anchors for an other layout!");
    }*/
    else
    {
      _layoutConstraints.putIfAbsent(pComponent, () => constraint);
      //_layoutConstraints.add(JVxFormLayoutConstraint(child: pComponent.getWidget(), id: constraint));
    }

    _valid = false;
  }

  void removeLayoutComponent(JVxComponent pComponent) 
  {
    _layoutConstraints.remove(pComponent);
    //_layoutConstraints.removeWhere((formLayoutContraints) => formLayoutContraints.child==pComponent.getWidget());
    
    _valid = false;
  }

  ///
  /// Creates the default anchors.
  /// 
  /// @param pLeftTopDefaultAnchors the vector to store the anchors.
  /// @param pRightBottomDefaultAnchors the vector to store the anchors.
  /// @param pLeftTopAnchor the left or top margin anchor.
  /// @param pRightBottomAnchor the right or bottom margin anchor.
  /// @param pColumnOrRow the column or the row.
  /// @param pGap the horizontal or vertical gap.
  /// @return the leftTop and rightBottom Anchors.
  ///
  List<JVxAnchor> createDefaultAnchors(List<JVxAnchor> pLeftTopDefaultAnchors, 
    									  List<JVxAnchor> pRightBottomDefaultAnchors, 
    		                              JVxAnchor pLeftTopAnchor, 
    		                              JVxAnchor pRightBottomAnchor, 
    		                              int pColumnOrRow,
    		                              int pGap)
  {
    List<JVxAnchor> defaultAnchors;
    JVxAnchor anchor;
    int gap;
    bool rightBottom = pColumnOrRow < 0;
    if (rightBottom)
    {
        pColumnOrRow = (-pColumnOrRow - 1) * 2;
        defaultAnchors = pRightBottomDefaultAnchors;
        anchor = pRightBottomAnchor;
        gap = -pGap;
    }
    else
    {
        pColumnOrRow *= 2;
        defaultAnchors = pLeftTopDefaultAnchors;
        anchor = pLeftTopAnchor;
        gap = pGap;
    }
    int size = defaultAnchors.length;
    while (pColumnOrRow >= size)
    {
      if (size == 0)
      {
        defaultAnchors.add(anchor);
      }
      else
      {
        defaultAnchors.add(new JVxAnchor.fromAnchorAndPosition(defaultAnchors[size - 1], gap));
      }
      defaultAnchors.add(new JVxAnchor.fromAnchor(defaultAnchors[size]));
      size = defaultAnchors.length;
    }
    if (rightBottom)
    {
        return [defaultAnchors[pColumnOrRow + 1], defaultAnchors[pColumnOrRow]];
    }
    else
    {
        return [defaultAnchors[pColumnOrRow], defaultAnchors[pColumnOrRow + 1]]; 
    }
  }

  ///
	/// Creates the default constraints for the given column and row.
  /// 
	/// @param pColumn the column.
	/// @param pRow the row.
	/// @return the constraints for the given component.
	///
  JVxConstraint createConstraint(int pColumn, int pRow)
  {
    return createConstraintWithBeginEnd(pColumn, pRow, pColumn, pRow);
  }

  ///
  /// Creates the default constraints for the given column and row.
  /// 
	/// @param pBeginColumn the begin column.
  /// @param pBeginRow the begin row.
	/// @param pEndColumn the end column.
	/// @param pEndRow the end row.
	/// @return the constraints for the given component.
	///
  JVxConstraint createConstraintWithBeginEnd(int pBeginColumn, int pBeginRow, int pEndColumn, int pEndRow)
  {
    List<JVxAnchor> left = createDefaultAnchors(leftDefaultAnchors, rightDefaultAnchors, leftMarginAnchor, rightMarginAnchor, pBeginColumn, horizontalGap);
    List<JVxAnchor> right;
    if (pBeginColumn == pEndColumn)
    {
      right = left;
    }
    else
    {
      right = createDefaultAnchors(leftDefaultAnchors, rightDefaultAnchors, leftMarginAnchor, rightMarginAnchor, pEndColumn, horizontalGap);
    }
    
    List<JVxAnchor> top = createDefaultAnchors(topDefaultAnchors, bottomDefaultAnchors, topMarginAnchor, bottomMarginAnchor, pBeginRow, verticalGap);
    List<JVxAnchor> bottom;
    if (pBeginRow == pEndRow)
    {
      bottom = top;
    }
    else
    {
      bottom = createDefaultAnchors(topDefaultAnchors, bottomDefaultAnchors, topMarginAnchor, bottomMarginAnchor, pEndRow, verticalGap);
    }
    return new JVxConstraint(top[0], 
                left[0], 
                bottom[1], 
                right[1]);
  }

  Widget getWidget() {

    List<JVxFormLayoutConstraint> children = new List<JVxFormLayoutConstraint>();

    for (int i=0; i<this._layoutConstraints.keys.length;i++) {
      children.add(
        new JVxFormLayoutConstraint(child: this._layoutConstraints.keys.elementAt(i).getWidget(), 
                     id: this._layoutConstraints.values.elementAt(i)));
    }

    return JVxFormLayoutWidget(
      key: key,
      valid: this._valid,
      children: children,
      hgap: this.horizontalGap,
      vgap: this.verticalGap,
      horizontalAlignment: this.horizontalAlignment,
      verticalAlignment: this.verticalAlignment,
      leftAnchor: this.leftAnchor,
      rightAnchor: this.rightAnchor,
      topAnchor: this.topAnchor,
      bottomAnchor: this.bottomAnchor,
      leftMarginAnchor: this.leftMarginAnchor,
      rightMarginAnchor: this.rightMarginAnchor,
      topMarginAnchor: this.topMarginAnchor,
      bottomMarginAnchor: this.bottomMarginAnchor);
  }
}