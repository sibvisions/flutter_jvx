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
      anchors["tm"].position = 0;
      anchors["lm"].position = 0;
      anchors["bm"].position = 0;
      anchors["rm"].position = 0;
    }
    else
    {
      anchors["tm"].position = pMargins.top.round();
      anchors["lm"].position = pMargins.left.round();
      anchors["bm"].position = -pMargins.bottom.round();
      anchors["rm"].position = -pMargins.right.round();
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

  void addDefaultAnchors() {
    anchors.putIfAbsent("l", () => JVxAnchor(this, JVxAnchor.HORIZONTAL));
    anchors.putIfAbsent("r", () => JVxAnchor(this, JVxAnchor.HORIZONTAL));
    anchors.putIfAbsent("t", () => JVxAnchor(this, JVxAnchor.VERTICAL));
    anchors.putIfAbsent("b", () => JVxAnchor(this, JVxAnchor.VERTICAL));
    anchors.putIfAbsent("lm", () => JVxAnchor.fromAnchorAndPosition(anchors["l"], 10));
    anchors.putIfAbsent("rm", () => JVxAnchor.fromAnchorAndPosition(anchors["r"], -10));
    anchors.putIfAbsent("tm", () => JVxAnchor.fromAnchorAndPosition(anchors["t"], 10));
    anchors.putIfAbsent("bm", () => JVxAnchor.fromAnchorAndPosition(anchors["b"], -10));
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
    
    if (values.length!=4) {
      return null;
    }

    JVxAnchor anchor = JVxAnchor(this, orientation);
    if (values[1]!="-" && anchors.containsKey(values[1])) {
      anchor.relatedAnchor = anchors[values[1]];
    }

    if (values[3]=="a") {
      anchor.autoSize = true;
    } else {
      anchor.position = int.parse(values[3]);
    }
    anchors.putIfAbsent(values[0], () => anchor);
    return anchor;

  }

  Widget getWidget() {

    List<JVxFormLayoutConstraintData> children = new List<JVxFormLayoutConstraintData>();

    for (int i=0; i<this._layoutConstraints.keys.length;i++) {
      JVxFormLayoutConstraint constraint = this.getConstraintsFromString(this._layoutConstraints.values.elementAt(i));
      if (constraint!=null) {
        children.add(
          new JVxFormLayoutConstraintData(child: this._layoutConstraints.keys.elementAt(i).getWidget(), 
                     id: constraint));
      }
    }

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