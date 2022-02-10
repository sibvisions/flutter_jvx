import 'dart:math';

import 'i_layout.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';

class ScrollLayout implements ILayout {
  ILayout originalLayout;

  ScrollLayout(this.originalLayout);

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    LayoutData clonedParentData = pParent.clone();

    /// If it does not have a calc size, then we have to have it calculate as infinite
    clonedParentData.layoutPosition = pParent.hasCalculatedSize
        ? LayoutPosition(
            width: widthOfScrollPanel(pParent),
            height: heightOfScrollPanel(pParent),
            top: 0,
            left: 0,
            isComponentSize: true)
        : null;

    originalLayout.calculateLayout(clonedParentData, pChildren);

    clonedParentData.layoutPosition = pParent.layoutPosition;
    pParent.applyFromOther(clonedParentData);
  }

  @override
  ILayout clone() {
    return ScrollLayout(originalLayout.clone());
  }

  double widthOfScrollPanel(LayoutData layoutData) {
    double width = 0.0;

    if (layoutData.hasPosition) {
      width = max(width, layoutData.layoutPosition!.width);
    }

    if (layoutData.hasCalculatedSize) {
      width = max(width, layoutData.calculatedSize!.width);
    }

    return width;
  }

  double heightOfScrollPanel(LayoutData layoutData) {
    double height = 0.0;

    if (layoutData.hasPosition) {
      height = max(height, layoutData.layoutPosition!.height);
    }

    if (layoutData.hasCalculatedSize) {
      height = max(height, layoutData.calculatedSize!.height);
    }

    return height;
  }
}
