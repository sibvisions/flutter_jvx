/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

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
    clonedParentData.layoutPosition = pParent.hasPosition
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
