import 'package:flutter/material.dart';
import '../component/i_component.dart';
import 'i_alignment_constants.dart';
import '../container/i_container.dart';
import 'co_layout.dart';
import 'widgets/co_form_layout_widget.dart';
import 'widgets/co_form_layout_contraint.dart';
import 'widgets/co_form_layout_anchor.dart';
import '../component/component.dart';

class CoFormLayout extends CoLayout<String> {
  Key key = UniqueKey();

  /// The valid state of anchor calculation. */
  bool _valid = false;

  /// the x-axis alignment (default: {@link JVxConstants#CENTER}). */
  int horizontalAlignment = IAlignmentConstants.ALIGN_CENTER;

  /// the y-axis alignment (default: {@link JVxConstants#CENTER}). */
  int verticalAlignment = IAlignmentConstants.ALIGN_CENTER;

  Map<String, CoFormLayoutAnchor> defaultAnchors =
      Map<String, CoFormLayoutAnchor>();
  Map<String, CoFormLayoutAnchor> anchors = Map<String, CoFormLayoutAnchor>();

  /// stores all constraints. */
  Map<Component, String> _layoutConstraints = <Component, String>{};

  CoFormLayout(Key key) : super(key) {
    init();
  }

  CoFormLayout.fromLayoutString(
      IContainer pContainer, String layoutString, String layoutData)
      : super.fromLayoutString(pContainer, layoutString, layoutData) {
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
    this.anchors = Map<String, CoFormLayoutAnchor>.from(defaultAnchors);

    List<String> anc = layoutData.split(";");

    anc.asMap().forEach((index, a) {
      addAnchorFromString(a);
    });

    anc.asMap().forEach((index, a) {
      updateRelatedAnchorFromString(a);
    });
  }

  void addAnchorFromString(String pAnchor) {
    List<String> values = pAnchor.split(",");

    if (values.length < 4) {
      throw new ArgumentError(
          "CoFormLayout: The anchor data parsed from json is less then 4 items! AnchorData: " +
              pAnchor);
    } else if (values.length < 5) {
      print(
          "CoFormLayout: The anchor data parsed from json is less then 5 items! AnchorData: " +
              pAnchor);
    }

    CoFormLayoutAnchor anchor;

    if (anchors.containsKey(values[0])) {
      anchor = anchors[values[0]];
    } else {
      int orientation = CoFormLayoutAnchor.VERTICAL;

      if (values[0].startsWith("h") ||
          values[0].startsWith("l") ||
          values[0].startsWith("r")) {
        orientation = CoFormLayoutAnchor.HORIZONTAL;
      }

      anchor = CoFormLayoutAnchor(this, orientation, values[0]);
    }

    if (values[3] == "a") {
      if (values.length > 4 && values[4].length > 0) {
        anchor.position = int.parse(values[4]);
      }
      anchor.autoSize = true;
    } else {
      anchor.position = int.parse(values[3]);
    }

    if (values[1] != "-" && anchors.containsKey(values[1])) {
      anchor.relatedAnchor = anchors[values[1]];
    }

    anchors.putIfAbsent(values[0], () => anchor);
  }

  void updateRelatedAnchorFromString(String pAnchor) {
    List<String> values = pAnchor.split(",");

    CoFormLayoutAnchor anchor = anchors[values[0]];
    if (values[1] != "-") {
      if (anchors.containsKey(values[1])) {
        anchor.relatedAnchor = anchors[values[1]];
        anchors.putIfAbsent(values[0], () => anchor);
      } else {
        throw new ArgumentError("CoFormLayout: Related anchor (Name: '" +
            values[1] +
            "') not found!");
      }
    }
  }

  void addDefaultAnchors() {
    defaultAnchors.putIfAbsent("l",
        () => CoFormLayoutAnchor(this, CoFormLayoutAnchor.HORIZONTAL, "l"));
    defaultAnchors.putIfAbsent("r",
        () => CoFormLayoutAnchor(this, CoFormLayoutAnchor.HORIZONTAL, "r"));
    defaultAnchors.putIfAbsent(
        "t", () => CoFormLayoutAnchor(this, CoFormLayoutAnchor.VERTICAL, "t"));
    defaultAnchors.putIfAbsent(
        "b", () => CoFormLayoutAnchor(this, CoFormLayoutAnchor.VERTICAL, "b"));
    defaultAnchors.putIfAbsent(
        "lm",
        () => CoFormLayoutAnchor.fromAnchorAndPosition(
            defaultAnchors["l"], 10, "lm"));
    defaultAnchors.putIfAbsent(
        "rm",
        () => CoFormLayoutAnchor.fromAnchorAndPosition(
            defaultAnchors["r"], -10, "rm"));
    defaultAnchors.putIfAbsent(
        "tm",
        () => CoFormLayoutAnchor.fromAnchorAndPosition(
            defaultAnchors["t"], 10, "tm"));
    defaultAnchors.putIfAbsent(
        "bm",
        () => CoFormLayoutAnchor.fromAnchorAndPosition(
            defaultAnchors["b"], -10, "bm"));
  }

  void addLayoutComponent(IComponent pComponent, String pConstraint) {
    if (pConstraint == null || pConstraint.isEmpty) {
      throw new ArgumentError(
          "Constraint " + pConstraint.toString() + " is not allowed!");
    } else {
      _layoutConstraints.putIfAbsent(pComponent, () => pConstraint);
    }

    _valid = false;
  }

  void removeLayoutComponent(IComponent pComponent) {
    _layoutConstraints.removeWhere((c, s) =>
        c.componentId.toString() == pComponent.componentId.toString());
    _valid = false;
  }

  @override
  String getConstraints(IComponent comp) {
    return _layoutConstraints[comp];
  }

  CoFormLayoutConstraint getConstraintsFromString(String pConstraints) {
    List<String> anc = pConstraints.split(";");

    if (anc.length == 4) {
      CoFormLayoutAnchor topAnchor = anchors[anc[0]];
      CoFormLayoutAnchor leftAnchor = anchors[anc[1]];
      CoFormLayoutAnchor bottomAnchor = anchors[anc[2]];
      CoFormLayoutAnchor rightAnchor = anchors[anc[3]];

      if (topAnchor != null &&
          leftAnchor != null &&
          bottomAnchor != null &&
          rightAnchor != null) {
        return CoFormLayoutConstraint(
            topAnchor, leftAnchor, bottomAnchor, rightAnchor);
      }
    }

    return null;
  }

  Widget getWidget() {
    List<CoFormLayoutConstraintData> children =
        new List<CoFormLayoutConstraintData>();

    this._layoutConstraints.forEach((k, v) {
      if (k.isVisible) {
        CoFormLayoutConstraint constraint = this.getConstraintsFromString(v);

        if (constraint != null) {
          constraint.comp = k;
          children.add(new CoFormLayoutConstraintData(
              child: k.getWidget(), id: constraint));
        }
      }
    });

    return Container(
        child: CoFormLayoutWidget(
            key: key,
            container: container,
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
            bottomMarginAnchor: anchors["bm"]));
  }
}
