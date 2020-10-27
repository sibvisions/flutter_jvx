import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/layout_key_manager.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/widgets/co_form_layout_anchor.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/widgets/co_form_layout_constraint.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/widgets/co_form_layout_widget.dart';

import '../../component/component_widget.dart';
import '../../container/co_container_widget.dart';

import 'layout_helper.dart';

class CoFormLayoutContainerWidget extends StatelessWidget {
  final bool valid;

  final int horizontalAlignment;
  final int verticalAlignment;

  final Map<String, CoFormLayoutAnchor> defaultAnchors;
  final Map<String, CoFormLayoutAnchor> anchors;

  final Map<ComponentWidget, String> layoutConstraints;

  final CoContainerWidget container;

  final EdgeInsets margins;
  final int horizontalGap;
  final int verticalGap;

  final LayoutKeyManager keyManager;

  CoFormLayoutContainerWidget({
    Key key,
    this.valid,
    this.layoutConstraints,
    this.container,
    this.keyManager,
    String layoutString,
    String layoutData,
  })  : horizontalAlignment =
            LayoutHelper.getHorizontalAlignmentFromString(layoutString),
        verticalAlignment =
            LayoutHelper.getVerticalAlignmentFromString(layoutString),
        margins = LayoutHelper.getMarginsFromString(layoutString),
        horizontalGap =
            LayoutHelper.getHorizontalGapFromString(layoutString) ?? 5,
        verticalGap = LayoutHelper.getVerticalGapFromString(layoutString) ?? 5,
        anchors = <String, CoFormLayoutAnchor>{},
        defaultAnchors = <String, CoFormLayoutAnchor>{},
        super(key: key) {
    addDefaultAnchors();
    updateLayoutData(layoutData);
  }

  void updateLayoutData(String layoutData) {
    this.anchors.removeWhere((key, value) => true);

    this.anchors.addAll(this.defaultAnchors);

    List<String> anc = layoutData.split(';');

    anc.asMap().forEach((index, a) => addAnchorFromString(a));

    anc.asMap().forEach((index, a) => updateRelatedAnchorFromString(a));
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

  @override
  Widget build(BuildContext context) {
    List<CoFormLayoutConstraintData> children = <CoFormLayoutConstraintData>[];

    this.layoutConstraints.forEach((k, v) {
      if (k.componentModel.isVisible &&
          children.firstWhere(
                  (constraintData) =>
                      (constraintData.child as ComponentWidget)
                          .componentModel
                          .componentId ==
                      k.componentModel.componentId,
                  orElse: () => null) ==
              null) {
        CoFormLayoutConstraint constraint =
            LayoutHelper.getFormLayoutConstraint(this.anchors, v);

        Key key =
            this.keyManager.getKeyByComponentId(k.componentModel.componentId);

        if (key == null) {
          key = this.keyManager.createKey(k.componentModel.componentId);
        }

        if (constraint != null) {
          constraint.comp = k;
          children.add(
              CoFormLayoutConstraintData(key: key, child: k, id: constraint));
        }
      }
    });

    return Container(
      margin: this.margins,
      child: CoFormLayoutWidget(
        container: this.container,
        valid: this.valid,
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
        bottomMarginAnchor: anchors["bm"],
      ),
    );
  }
}
