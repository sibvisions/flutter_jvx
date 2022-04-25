import 'dart:math';

import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import 'i_layout.dart';

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

  static double widthOfScrollPanel(LayoutData layoutData) {
    double width = 0.0;

    if (layoutData.hasPosition) {
      width = max(width, layoutData.layoutPosition!.width);
    }

    if (layoutData.hasCalculatedSize) {
      width = max(width, layoutData.calculatedSize!.width);
    }

    if (layoutData.hasMinSize) {
      width = max(width, layoutData.minSize!.width);
    }

    if (layoutData.hasMaxSize) {
      width = min(width, layoutData.maxSize!.width);
    }

    return width;
  }

  static double heightOfScrollPanel(LayoutData layoutData) {
    double height = 0.0;

    if (layoutData.hasPosition) {
      height = max(height, layoutData.layoutPosition!.height);
    }

    if (layoutData.hasCalculatedSize) {
      height = max(height, layoutData.calculatedSize!.height);
    }

    if (layoutData.hasMinSize) {
      height = max(height, layoutData.minSize!.height);
    }

    if (layoutData.hasMaxSize) {
      height = min(height, layoutData.maxSize!.height);
    }

    return height;
  }
}
