import 'dart:developer';

import 'package:flutter_client/src/model/layout/form_layout/form_layout_anchor.dart';

class FLCalculateDependentUtil {

  /// Calculates the preferred size of relative anchors.
  static void calculateRelativeAnchor({required FormLayoutAnchor leftTopAnchor, required FormLayoutAnchor rightBottomAnchor, required double preferredSize}) {
    if(leftTopAnchor.relative) {
      FormLayoutAnchor? rightBottom = rightBottomAnchor.getRelativeAnchor();
      if (rightBottom != leftTopAnchor) {
        double pref = rightBottom.getAbsolutePosition() - rightBottomAnchor.getAbsolutePosition() + preferredSize;
        double size = 0;
        if(rightBottom.relatedAnchor != null && leftTopAnchor.relatedAnchor != null){
          size = rightBottom.relatedAnchor!.getAbsolutePosition() - leftTopAnchor.relatedAnchor!.getAbsolutePosition();
        }
        double pos = pref - size;

        if(pos < 0){
          pos /= 2;
        } else {
          pos -= pos/2;
        }

        if(rightBottom.firstCalculation || pos > rightBottom.position){
          rightBottom.firstCalculation = false;
          rightBottom.position = pos;
        }
        pos = pref - size - pos;
        if(leftTopAnchor.firstCalculation || pos > leftTopAnchor.position){
          leftTopAnchor.firstCalculation = false;
          leftTopAnchor.position = -pos;
        }
      }
    }
  }
}