import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/widgets/co_form_layout_anchor.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/widgets/co_form_layout_constraint.dart';

import '../../../ui/layout/i_alignment_constants.dart';
import '../widgets/co_border_layout_constraint.dart';

class LayoutHelper {
  static EdgeInsets getMarginsFromString(String layout) {
    List<String> parameter = layout?.split(",");

    double top = double.parse(parameter[1]);
    double left = double.parse(parameter[2]);
    double bottom = double.parse(parameter[3]);
    double right = double.parse(parameter[4]);

    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  static int getHorizontalGapFromString(String layout) {
    List<String> parameter = layout?.split(",");
    return int.parse(parameter[5]);
  }

  static int getVerticalGapFromString(String layout) {
    List<String> parameter = layout?.split(",");
    return int.parse(parameter[6]);
  }

  static CoBorderLayoutConstraints getBorderLayoutConstraint(
      String constraint) {
    switch (constraint) {
      case 'North':
        return CoBorderLayoutConstraints.North;
      case 'South':
        return CoBorderLayoutConstraints.South;
      case 'East':
        return CoBorderLayoutConstraints.East;
      case 'West':
        return CoBorderLayoutConstraints.West;
      case 'Center':
        return CoBorderLayoutConstraints.Center;
    }

    return null;
  }

  static CoFormLayoutConstraint getFormLayoutConstraint(
      Map<String, CoFormLayoutAnchor> anchors, String pConstraints) {
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

  static int getHorizontalAlignmentFromString(String layoutString) {
    List<String> parameter = layoutString?.split(",");

    return int.parse(parameter[7]) ?? IAlignmentConstants.ALIGN_CENTER;
  }

  static int getVerticalAlignmentFromString(String layoutString) {
    List<String> parameter = layoutString?.split(",");

    return int.parse(parameter[7]) ?? IAlignmentConstants.ALIGN_CENTER;
  }
}
