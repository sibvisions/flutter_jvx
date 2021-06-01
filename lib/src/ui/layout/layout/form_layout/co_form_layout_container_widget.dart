import 'dart:developer';

import 'package:flutter/material.dart';

import '../../widgets/co_form_layout_constraint.dart';
import '../../widgets/co_form_layout_widget.dart';
import '../co_layout_widget.dart';
import 'form_layout_model.dart';

class CoFormLayoutContainerWidget extends CoLayoutWidget {
  final FormLayoutModel layoutModel;

  CoFormLayoutContainerWidget({required this.layoutModel})
      : super(layoutModel: layoutModel);

  @override
  CoFormLayoutContainerWidgetState createState() =>
      CoFormLayoutContainerWidgetState();
}

class CoFormLayoutContainerWidgetState
    extends CoLayoutWidgetState<CoFormLayoutContainerWidget> {
  int count = 0;

  List<CoFormLayoutConstraintData> _getConstraintData() {
    List<CoFormLayoutConstraintData> data = <CoFormLayoutConstraintData>[];

    widget.layoutModel.layoutConstraints.forEach((k, v) {
      CoFormLayoutConstraint? constraint =
          widget.layoutModel.getConstraintsFromString(v);

      if (constraint != null && k.componentModel.isVisible) {
        constraint.comp = k;
        data.add(CoFormLayoutConstraintData(id: constraint, child: k));
      }
    });

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: layoutKey,
      child: CoFormLayoutWidget(
          container: widget.layoutModel.container,
          valid: widget.layoutModel.valid,
          children: _getConstraintData(),
          hgap: widget.layoutModel.horizontalGap,
          vgap: widget.layoutModel.verticalGap,
          horizontalAlignment: widget.layoutModel.horizontalAlignment,
          verticalAlignment: widget.layoutModel.verticalAlignment,
          leftAnchor: widget.layoutModel.anchors["l"],
          rightAnchor: widget.layoutModel.anchors["r"],
          topAnchor: widget.layoutModel.anchors["t"],
          bottomAnchor: widget.layoutModel.anchors["b"],
          leftMarginAnchor: widget.layoutModel.anchors["lm"],
          rightMarginAnchor: widget.layoutModel.anchors["rm"],
          topMarginAnchor: widget.layoutModel.anchors["tm"],
          bottomMarginAnchor: widget.layoutModel.anchors["bm"]),
    );
  }
}
