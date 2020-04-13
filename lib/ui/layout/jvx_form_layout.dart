import 'package:flutter/material.dart';
import '../../ui/component/i_component.dart';
import '../../ui/layout/i_alignment_constants.dart';
import 'jvx_layout.dart';
import 'widgets/jvx_form_layout.dart';
import 'widgets/jvx_form_layout_contraint.dart';
import 'widgets/jvx_form_layout_anchor.dart';
import '../component/jvx_component.dart';

class JVxFormLayout extends JVxLayout<String> {
  Key key = UniqueKey();
  /// The valid state of anchor calculation. */
  bool _valid = false;
  /// the x-axis alignment (default: {@link JVxConstants#CENTER}). */
	int	horizontalAlignment = IAlignmentConstants.ALIGN_CENTER;
	/// the y-axis alignment (default: {@link JVxConstants#CENTER}). */
	int	verticalAlignment = IAlignmentConstants.ALIGN_CENTER;

  Map<String,JVxAnchor> defaultAnchors = Map<String, JVxAnchor>();
  Map<String,JVxAnchor> anchors = Map<String, JVxAnchor>();

  /// stores all constraints. */
  Map<JVxComponent, String> _layoutConstraints = <JVxComponent, String>{};

  ///
  /// Gets the margins.
  /// 
  /// @return the margins.
  ///
  /*EdgeInsets get margins
  {
    return new EdgeInsets.fromLTRB(anchors["lm"].position.toDouble(), anchors["tm"].position.toDouble(), 
    -anchors["rm"].position.toDouble(), -anchors["bm"].position.toDouble());
  }*/
    
  ///
  /// Sets the margins.
  /// 
  /// @param pMargins the margins.
  ///
  /*set margins(EdgeInsets pMargins) 
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
  }*/

  JVxFormLayout(this.key) {
    init();
  }

  JVxFormLayout.fromLayoutString(String layoutString, String layoutData) {
    init();
    updateLayoutString(layoutString);
    updateLayoutData(layoutData);
  }

  void init() {
    verticalGap = 5;
    horizontalGap = 5;
    addDefaultAnchors();
  }

  @override
  void updateLayoutString(String layoutString) {
    super.updateLayoutString(layoutString);
    parseFromString(layoutString);
    List<String> parameter = layoutString?.split(",");

    horizontalAlignment = int.parse(parameter[7]);
    verticalAlignment = int.parse(parameter[8]);
  }

@override
  void updateLayoutData(String layoutData) {
    super.updateLayoutData(layoutData);
    this.anchors = Map<String, JVxAnchor>.from(defaultAnchors);
    
    List<String> anc = layoutData.split(";");

    anc.asMap().forEach((index,a) {
      addAnchorFromString(a);
    });

    anc.asMap().forEach((index,a) {
      updateRelatedAnchorFromString(a);
    });
  }

  void addAnchorFromString(String pAnchor) {
    List<String> values = pAnchor.split(",");
    
    if (values.length<4) {
      throw new ArgumentError("JVxFormLayout: The anchor data parsed from json is less then 4 items! AnchorData: " + pAnchor);
    } else if (values.length<5) {
      print("JVxFormLayout: The anchor data parsed from json is less then 5 items! AnchorData: " + pAnchor);
    }

    JVxAnchor anchor;
    
    if (anchors.containsKey(values[0])) {
      anchor = anchors[values[0]];
    } else {
      int orientation = JVxAnchor.VERTICAL;

      if (values[0].startsWith("h") || values[0].startsWith("l") || values[0].startsWith("r")) {
        orientation = JVxAnchor.HORIZONTAL;
      }

      anchor = JVxAnchor(this, orientation, values[0]);
    }
    
    if (values[3]=="a") {
      
      if (values.length>4 && values[4].length>0) {
        anchor.position = int.parse(values[4]);
      }
      anchor.autoSize = true;
    } else {
      anchor.position = int.parse(values[3]);
    }

    if (values[1]!="-" && anchors.containsKey(values[1])) {
      anchor.relatedAnchor = anchors[values[1]];
    }

    anchors.putIfAbsent(values[0], () => anchor);
  }

  void updateRelatedAnchorFromString(String pAnchor) {
    List<String> values = pAnchor.split(",");

    JVxAnchor anchor = anchors[values[0]];
    if (values[1]!="-") {
      if (anchors.containsKey(values[1])) {
        anchor.relatedAnchor = anchors[values[1]];
        anchors.putIfAbsent(values[0], () => anchor);
      } else {
        throw new ArgumentError("JVxFormLayout: Related anchor (Name: '" + values[1] + "') not found!");
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
    _layoutConstraints.removeWhere((c, s) => c.componentId.toString() == pComponent.componentId.toString());
    _valid = false;
  }

  @override
  String getConstraints(IComponent comp) {
    return _layoutConstraints[comp];
  }


  JVxFormLayoutConstraint getConstraintsFromString(String pConstraints) {
    List<String> anc = pConstraints.split(";");

    if (anc.length==4) {
      JVxAnchor topAnchor = anchors[anc[0]];
      JVxAnchor leftAnchor = anchors[anc[1]];
      JVxAnchor bottomAnchor = anchors[anc[2]];
      JVxAnchor rightAnchor = anchors[anc[3]];

      if (topAnchor!=null && leftAnchor!=null && bottomAnchor!= null && rightAnchor!= null) {
        return JVxFormLayoutConstraint(topAnchor, leftAnchor, bottomAnchor, rightAnchor);
      }
    }

    return null;
  }

  Widget getWidget() {

    List<JVxFormLayoutConstraintData> children = new List<JVxFormLayoutConstraintData>();

    this._layoutConstraints.forEach((k, v) {
      if (k.isVisible) {
        JVxFormLayoutConstraint constraint = this.getConstraintsFromString(v);

        if (constraint !=null) {
          constraint.comp = k;
          children.add(
            new JVxFormLayoutConstraintData(child: k.getWidget(), 
                  id: constraint));
        }
      }
    });

    return Container(
      child: JVxFormLayoutWidget(
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
        bottomMarginAnchor: anchors["bm"])
      );
  }
}