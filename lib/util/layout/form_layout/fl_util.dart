import 'dart:collection';

import '../../../src/layout/form_layout.dart';
import '../../../src/model/layout/form_layout/form_layout_anchor.dart';
import '../../../src/model/layout/form_layout/form_layout_constraints.dart';
import '../../../src/model/layout/layout_data.dart';

/// Util Methods for [FormLayout]
class FLUtil {

  /// Parses all anchors from layoutData and establishes relatedAnchors
  static HashMap<String, FormLayoutAnchor> getAnchors(String layoutData) {
    HashMap<String, FormLayoutAnchor> anchors = HashMap();

    // Parse layoutData to get Anchors
    final List<String> splitAnchors = layoutData.split(";");
    for (var stringAnchor in splitAnchors) {
      String name = stringAnchor.substring(0, stringAnchor.indexOf(","));
      anchors[name] = FormLayoutAnchor.fromAnchorData(pAnchorData: stringAnchor);
    }

    // Establish relatedAnchors
    anchors.forEach((anchorName, anchor) {
      anchor.relatedAnchor = anchors[anchor.relatedAnchorName];
    });
    return anchors;
  }

  /// Creates [FormLayoutConstraints] for every [LayoutData] (child)
  static HashMap<String, FormLayoutConstraints> getComponentConstraints(HashMap<String, LayoutData> components, HashMap<String, FormLayoutAnchor> anchors) {
    HashMap<String, FormLayoutConstraints> componentConstraints = HashMap();

    components.forEach((key, value) {
      List<String> anchorNames = value.constraints!.split(";");
      // Get Anchors
      FormLayoutAnchor topAnchor = anchors[anchorNames[0]]!;
      FormLayoutAnchor leftAnchor = anchors[anchorNames[1]]!;
      FormLayoutAnchor bottomAnchor = anchors[anchorNames[2]]!;
      FormLayoutAnchor rightAnchor = anchors[anchorNames[3]]!;
      // Build Constraint
      FormLayoutConstraints constraint = FormLayoutConstraints(bottomAnchor: bottomAnchor, leftAnchor: leftAnchor, rightAnchor: rightAnchor, topAnchor: topAnchor);
      componentConstraints[value.id] = constraint;
    });
    return componentConstraints;
  }

  /// Parses alignmentString to [VerticalAlignment]
  static VerticalAlignment getVerticalAlignment(String alignment){
    switch(alignment){
      case("0") :
        return VerticalAlignment.top;
      case("1") :
        return VerticalAlignment.center;
      case("2") :
        return VerticalAlignment.bottom;
      default :
        return VerticalAlignment.stretch;
    }
  }

  /// Parses alignmentString to [HorizontalAlignment]
  static HorizontalAlignment getHorizontalAlignment(String alignment){
    switch(alignment){
      case("0") :
        return HorizontalAlignment.left;
      case("1") :
        return HorizontalAlignment.center;
      case("2") :
        return HorizontalAlignment.right;
      default :
        return HorizontalAlignment.stretch;
    }
  }



}