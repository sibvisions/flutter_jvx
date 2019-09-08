import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'jvx_layout.dart';
import 'widgets/jvx_form_layout.dart';
import 'widgets/jvx_form_layout_contraint.dart';
import 'widgets/jvx_form_layout_anchor.dart';
import '../component/jvx_component.dart';

class JVxFormLayout extends JVxLayout<String> {
  static final int stretch = 100;
  Key key;
  /// The valid state of anchor calculation. */
  bool _valid = false;
  /// the x-axis alignment (default: {@link JVxConstants#CENTER}). */
	int	horizontalAlignment = stretch;
	/// the y-axis alignment (default: {@link JVxConstants#CENTER}). */
	int	verticalAlignment = stretch;

  Map<String,JVxAnchor> defaultAnchors = Map<String, JVxAnchor>();
  Map<String,JVxAnchor> anchors = Map<String, JVxAnchor>();

  /// stores all constraints. */
  Map<JVxComponent, String> _layoutConstraints = <JVxComponent, String>{};

  ///
  /// Gets the margins.
  /// 
  /// @return the margins.
  ///
  EdgeInsets get margins
  {
    return new EdgeInsets.fromLTRB(anchors["lm"].position, anchors["tm"].position, 
    -anchors["rm"].position, -anchors["bm"].position);
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
      defaultAnchors["tm"].position = 0;
      defaultAnchors["lm"].position = 0;
      defaultAnchors["bm"].position = 0;
      defaultAnchors["rm"].position = 0;
    }
    else
    {
      defaultAnchors["tm"].position = pMargins.top.round();
      defaultAnchors["lm"].position = pMargins.left.round();
      defaultAnchors["bm"].position = -pMargins.bottom.round();
      defaultAnchors["rm"].position = -pMargins.right.round();
    }
  }

  JVxFormLayout(this.key) {
    init();
  }

  JVxFormLayout.fromLayoutString(String layoutString) {
    init();
    parseFromString(layoutString);
    List<String> parameter = layoutString?.split(",");

    horizontalAlignment = int.parse(parameter[7]);
    verticalAlignment = int.parse(parameter[8]);
  }

  void init() {
    verticalGap = 5;
    horizontalGap = 5;
    addDefaultAnchors();
  }

  void generateAnchors() {
    anchors = Map<String, JVxAnchor>.from(defaultAnchors);

    this._layoutConstraints.forEach((k,v) {
      List<String> anchors = v.split(";");
      if (anchors.length==4) {
        anchors.asMap().forEach((index,a) {
          if(index % 2 == 0) {
            addAnchorFromString(a, JVxAnchor.VERTICAL);
          } else {
            addAnchorFromString(a, JVxAnchor.HORIZONTAL);
          }
        });
      }
    });

    this._layoutConstraints.forEach((k,v) {
      List<String> anchors = v.split(";");
      if (anchors.length==4) {
        anchors.asMap().forEach((index,a) {
          if(index % 2 == 0) {
            updateRelatedAnchorFromString(a, JVxAnchor.VERTICAL);
          } else {
            updateRelatedAnchorFromString(a, JVxAnchor.HORIZONTAL);
          }
        });
      }
    });
  }

  void addAnchorFromString(String pAnchor, int orientation) {
    List<String> values = pAnchor.split(",");
    
    if (values.length!=4) {
      return;
    }

    JVxAnchor anchor;
    
    if (anchors.containsKey(values[0])) {
      anchor = anchors[values[0]];
    } else {
      anchor = JVxAnchor(this, orientation, values[0]);
    }
    
    if (values[1]!="-" && anchors.containsKey(values[1])) {
      anchor.relatedAnchor = anchors[values[1]];
    }

    if (values[3]=="a") {
      anchor.autoSize = true;
    } else {
      anchor.position = int.parse(values[3]);
    }

    anchors.putIfAbsent(values[0], () => anchor);
  }

  void updateRelatedAnchorFromString(String pAnchor, int orientation) {
    List<String> values = pAnchor.split(",");

    if (values.length!=4) {
      return;
    }

    JVxAnchor anchor = anchors[values[0]];
    if (values[1]!="-") {
      if (anchors.containsKey(values[1])) {
        anchor.relatedAnchor = anchors[values[1]];
        anchors.putIfAbsent(values[0], () => anchor);
      } else {
        JVxAnchor anchor = JVxAnchor(this, orientation, values[1]);
        anchors.putIfAbsent(values[1], () => anchor);
        updateRelatedAnchorFromString(pAnchor, orientation);
        //throw new ArgumentError("Related anchor (Name: '" + values[1] + "') not found!");
      }
    }
  }

  void addDefaultAnchors() {
    defaultAnchors.putIfAbsent("l", () => JVxAnchor(this, JVxAnchor.HORIZONTAL, "l"));
    defaultAnchors.putIfAbsent("r", () => JVxAnchor(this, JVxAnchor.HORIZONTAL, "r"));
    defaultAnchors.putIfAbsent("t", () => JVxAnchor(this, JVxAnchor.VERTICAL, "t"));
    defaultAnchors.putIfAbsent("b", () => JVxAnchor(this, JVxAnchor.VERTICAL, "b"));
    defaultAnchors.putIfAbsent("lm", () => JVxAnchor.fromAnchorAndPosition(defaultAnchors["l"], 10, "lm"));
    defaultAnchors.putIfAbsent("rm", () => JVxAnchor.fromAnchorAndPosition(defaultAnchors["r"], -10, "rm"));
    defaultAnchors.putIfAbsent("tm", () => JVxAnchor.fromAnchorAndPosition(defaultAnchors["t"], 10, "tm"));
    defaultAnchors.putIfAbsent("bm", () => JVxAnchor.fromAnchorAndPosition(defaultAnchors["b"], -10, "bm"));
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
        defaultAnchors.add(new JVxAnchor.fromAnchorAndPosition(defaultAnchors[size - 1], gap, "noname"));
      }
      defaultAnchors.add(new JVxAnchor.fromAnchor(defaultAnchors[size], "noname"));
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
  JVxFormLayoutConstraint createConstraint(int pColumn, int pRow)
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
  JVxFormLayoutConstraint createConstraintWithBeginEnd(int pBeginColumn, int pBeginRow, int pEndColumn, int pEndRow)
  {
    List<JVxAnchor> leftDefaultAnchors = new List<JVxAnchor>();
    List<JVxAnchor> topDefaultAnchors = new List<JVxAnchor>();
    List<JVxAnchor> rightDefaultAnchors = new List<JVxAnchor>();
    List<JVxAnchor> bottomDefaultAnchors = new List<JVxAnchor>();
    JVxAnchor leftMarginAnchor = new JVxAnchor.fromAnchorAndPosition(anchors["l"], 10, "lm");
    JVxAnchor rightMarginAnchor = new JVxAnchor.fromAnchorAndPosition(anchors["r"], -10, "rm");
    JVxAnchor topMarginAnchor = new JVxAnchor.fromAnchorAndPosition(anchors["t"], 10, "tm");
    JVxAnchor bottomMarginAnchor = new JVxAnchor.fromAnchorAndPosition(anchors["b"], -10, "bm");
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
    return new JVxFormLayoutConstraint(top[0], 
                left[0], 
                bottom[1], 
                right[1]);
  }

  void addLayoutComponent(IComponent pComponent, String pConstraint)
  {
        
    if (pConstraint == null || pConstraint.isEmpty)
    {
      throw new ArgumentError("Constraint " + pConstraint.toString() + " is not allowed!");
    }
    else
    {
      _layoutConstraints.putIfAbsent(pComponent, () => pConstraint);
    }

    _valid = false;
  }

  void removeLayoutComponent(IComponent pComponent) 
  {
    _layoutConstraints.remove(pComponent);
    //_layoutConstraints.removeWhere((formLayoutContraints) => formLayoutContraints.child==pComponent.getWidget());
    
    _valid = false;
  }

    @override
  String getConstraints(IComponent comp) {
    return _layoutConstraints[comp];
  }


  JVxFormLayoutConstraint getConstraintsFromString(String pConstraints) {
    List<String> anchors = pConstraints.split(";");

    if (anchors.length==4) {
      JVxAnchor topAnchor = getAnchorFromString(anchors[0], JVxAnchor.VERTICAL);
      JVxAnchor leftAnchor = getAnchorFromString(anchors[1], JVxAnchor.HORIZONTAL);
      JVxAnchor bottomAnchor = getAnchorFromString(anchors[2], JVxAnchor.VERTICAL);
      JVxAnchor rightAnchor = getAnchorFromString(anchors[3], JVxAnchor.HORIZONTAL);

      if (topAnchor!=null && leftAnchor!=null && bottomAnchor!= null && rightAnchor!= null) {
        return JVxFormLayoutConstraint(topAnchor, leftAnchor, bottomAnchor, rightAnchor);
      }
    }

    return null;
  }

  JVxAnchor getAnchorFromString(String pAnchor, int orientation) {
    List<String> values = pAnchor.split(",");
    return anchors[values[0]];
  }

  Widget getWidget() {

    List<JVxFormLayoutConstraintData> children = new List<JVxFormLayoutConstraintData>();
    this.generateAnchors();

    this._layoutConstraints.forEach((k, v) {
      if (k.isVisible) {
        //JVxFormLayoutConstraint constraint1;
        JVxFormLayoutConstraint constraint2;
        
        //constraint1 =  createConstraint(i, 0);
        constraint2 = this.getConstraintsFromString(v);

        //print("contraint1:");
        //JVxFormLayout.LogPrint(constraint1.toJson().toString());
        //print("contraint2:");
        //JVxFormLayout.LogPrint(constraint2.toJson().toString());

        //if (constraint1.toJson().toString()!=constraint2.toJson().toString()) {
        //  print ("Constraints not equal!!!!");
        //} else {
        //  print ("constraints are equal!!!");
        //}

        if (constraint2 !=null) {
          children.add(
            new JVxFormLayoutConstraintData(child: k.getWidget(), 
                  id: constraint2));
        }
      }
    });

    return JVxFormLayoutWidget(
      key: key,
      valid: this._valid,
      children: children,
      hgap: this.horizontalGap,
      vgap: this.verticalGap,
      horizontalAlignment: this.horizontalAlignment,
      verticalAlignment: this.verticalAlignment,
      leftAnchor: anchors["l"],
      rightAnchor: anchors["r"],
      topAnchor: anchors["t"],
      bottomAnchor: anchors["b"],
      leftMarginAnchor: anchors["lm"],
      rightMarginAnchor: anchors["rm"],
      topMarginAnchor: anchors["tm"],
      bottomMarginAnchor: anchors["bm"]);
  }
}