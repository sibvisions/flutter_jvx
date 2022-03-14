import 'dart:developer';
import 'dart:ui';

import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import 'i_layout.dart';

class TabLayout implements ILayout {
  // int selectedIndex;

  double tabHeaderHeight;

  TabLayout({required this.tabHeaderHeight}); //, required this.selectedIndex});

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    LayoutPosition? childrenPosition;
    if (pParent.hasPosition) {
      double width = pParent.layoutPosition!.width;
      double height = pParent.layoutPosition!.height - tabHeaderHeight;
      log("${pParent.layoutPosition!.height}");
      childrenPosition = LayoutPosition(width: width, height: height, top: 0, left: 0, isComponentSize: true);
    }

    double calcWidth = 0.0;
    double calcHeight = 0.0;
    for (LayoutData childData in pChildren) {
      if (childData.hasCalculatedSize) {
        if (childData.calculatedSize!.width > calcWidth) {
          calcWidth = childData.calculatedSize!.width;
        }
        if (childData.calculatedSize!.height > calcHeight) {
          calcHeight = childData.calculatedSize!.height;
        }
      }

      childData.layoutPosition = childrenPosition;

      // if (childData.indexOf == selectedIndex) {
      //   childData.layoutPosition = childrenPosition;
      // } else {
      //   childData.layoutPosition = LayoutPosition(width: 0, height: 0, top: 0, left: 0, isComponentSize: true);
      // }
    }

    pParent.calculatedSize = Size(calcWidth, calcHeight + tabHeaderHeight);
  }

  @override
  ILayout clone() {
    return TabLayout(tabHeaderHeight: tabHeaderHeight); //, selectedIndex: selectedIndex);
  }
}
