import 'dart:collection';
import 'dart:developer';

import '../../../src/model/layout/form_layout/form_layout_anchor.dart';

class FLCalculateAnchorsUtil {


  /// Gets all non-calculated auto size anchors between start and end anchor
  static List<FormLayoutAnchor> getAutoSizeAnchorsBetween({required FormLayoutAnchor pStartAnchor, required FormLayoutAnchor pEndAnchor, required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors = [];
    FormLayoutAnchor? startAnchor = pStartAnchor;
    while(startAnchor != null && startAnchor != pEndAnchor){
      if(startAnchor.autoSize && !startAnchor.autoSizeCalculated){
        autoSizeAnchors.add(startAnchor);
      }
      startAnchor = startAnchor.relatedAnchor;
    }

    // If the anchors are not dependent on each other return an empty array!
    if(startAnchor == null){
      return [];
    }
    return autoSizeAnchors;
  }

  /// Init component auto size position of anchor.
  static void initAutoSizeRelative({required FormLayoutAnchor pStartAnchor, required FormLayoutAnchor pEndAnchor, required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors = getAutoSizeAnchorsBetween(pStartAnchor: pStartAnchor, pEndAnchor: pEndAnchor, pAnchors: pAnchors);
    for(FormLayoutAnchor anchor in autoSizeAnchors){
      anchor.relative = false;
    }
  }

  /// Calculates the preferred size of component auto size anchors.
  static void calculateAutoSize({required FormLayoutAnchor leftTopAnchor, required FormLayoutAnchor rightBottomAnchor, required double preferredSize,
      required double autoSizeCount, required HashMap<String, FormLayoutAnchor> pAnchors }) {

    List<FormLayoutAnchor> autoSizeAnchors = getAutoSizeAnchorsBetween(pStartAnchor: leftTopAnchor, pEndAnchor: rightBottomAnchor, pAnchors: pAnchors);
    if(autoSizeAnchors.length == autoSizeCount){
      double fixedSize = rightBottomAnchor.getAbsolutePosition() - leftTopAnchor.getAbsolutePosition();
      for(FormLayoutAnchor anchor in autoSizeAnchors){
        fixedSize += anchor.position;
      }
      double diffSize = (preferredSize - fixedSize + autoSizeCount -1) / autoSizeCount;
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        if(diffSize > -anchor.position){
          anchor.position = -diffSize;
        }
        anchor.firstCalculation = false;
      }
    }

    autoSizeAnchors = getAutoSizeAnchorsBetween(pStartAnchor: rightBottomAnchor, pEndAnchor: leftTopAnchor, pAnchors: pAnchors);
    if(autoSizeAnchors.length == autoSizeCount){
      double fixedSize = rightBottomAnchor.getAbsolutePosition() - leftTopAnchor.getAbsolutePosition();
      for(FormLayoutAnchor anchor in autoSizeAnchors){
        fixedSize -= anchor.position;
      }
      double diffSize = (preferredSize - fixedSize + autoSizeCount - 1) /autoSizeCount;
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        if(diffSize > anchor.position){
          anchor.position = diffSize;
        }
        anchor.firstCalculation = false;
      }
    }
  }

  /// Marks all touched AutoSize anchors as calculated
  static double finishAutoSizeCalculation({required FormLayoutAnchor leftTopAnchor, required FormLayoutAnchor rightBottomAnchor, required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors = getAutoSizeAnchorsBetween(pStartAnchor: leftTopAnchor, pEndAnchor: rightBottomAnchor, pAnchors: pAnchors);
    double counter = 0;
    for (FormLayoutAnchor anchor in autoSizeAnchors) {
      if(!anchor.firstCalculation){
        anchor.autoSizeCalculated = true;
        counter++;
      }
    }
    return autoSizeAnchors.length - counter;
  }

  /// Clears auto size position of anchors
  static void clearAutoSize({required HashMap<String, FormLayoutAnchor> pAnchors}){
    pAnchors.forEach((anchorName, anchor) {
      anchor.relative = anchor.autoSize;
      anchor.autoSizeCalculated = false;
      anchor.firstCalculation = true;
      if(anchor.autoSize){
        anchor.position = 0;
      }
    });
  }




}