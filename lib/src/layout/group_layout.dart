import 'dart:ui';

import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import 'i_layout.dart';

class GroupLayout implements ILayout {
  double groupHeaderHeight;

  ILayout originalLayout;

  GroupLayout({required this.originalLayout, required this.groupHeaderHeight});

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    LayoutData clonedParentData = pParent.clone();

    /// If it does not have a calc size, then we have to have it calculate as infinite
    clonedParentData.layoutPosition = pParent.hasCalculatedSize
        ? LayoutPosition(
            width: pParent.layoutPosition!.width,
            height: pParent.layoutPosition!.height - groupHeaderHeight,
            top: 0,
            left: 0,
            isComponentSize: true)
        : null;

    originalLayout.calculateLayout(clonedParentData, pChildren);

    clonedParentData.calculatedSize =
        Size(clonedParentData.calculatedSize!.width, clonedParentData.calculatedSize!.height + groupHeaderHeight);
    clonedParentData.layoutPosition = pParent.layoutPosition;
    pParent.applyFromOther(clonedParentData);
  }

  @override
  ILayout clone() {
    return GroupLayout(originalLayout: originalLayout.clone(), groupHeaderHeight: groupHeaderHeight);
  }
}
