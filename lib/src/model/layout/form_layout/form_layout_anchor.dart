/* 
 * Copyright 2022 SIB Visions GmbH
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

import '../alignments.dart';

class FormLayoutAnchor {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of anchor
  final String name;

  /// String of anchor, data gets extracted from it.
  final String anchorData;

  /// The name of the related anchor to the current anchor.
  final String? relatedAnchorName;

  /// The orientation of this anchor.
  final AlignmentOrientation orientation;

  /// true, if this anchor should be auto sized.
  final bool autoSize;

  /// The related anchor to the current anchor.
  FormLayoutAnchor? relatedAnchor;

  /// If autoSize has already been calculated.
  bool autoSizeCalculated;

  /// True, if the relative anchor is not calculated.
  bool firstCalculation;

  /// True, if the anchor is not calculated by components preferred size.
  bool relative;

  /// The position of this anchor.
  double position;

  /*
  FormLayout Änderungen von Martin bzgl Gaps der Anchor.
  /// True, if the anchor is used by a visible component.
  bool used = false;
  */

  FormLayoutAnchor(
      {required this.name,
      required this.orientation,
      required this.autoSize,
      required this.position,
      required this.firstCalculation,
      required this.autoSizeCalculated,
      required this.anchorData,
      required this.relative,
      this.relatedAnchor,
      this.relatedAnchorName});

  FormLayoutAnchor.fromAnchorData({required String pAnchorData})
      : anchorData = pAnchorData,
        name = pAnchorData.split(",")[0],
        relatedAnchorName = pAnchorData.split(",")[1],
        autoSize = pAnchorData.split(",")[3] == "a",
        autoSizeCalculated = false,
        firstCalculation = true,
        relative = false,
        position = double.parse(pAnchorData.split(",")[4]),
        orientation = getOrientationFromData(anchorName: pAnchorData.split(",")[0]);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns wether the orientation of the anchor is horizontal or vertical
  static AlignmentOrientation getOrientationFromData({required String anchorName}) {
    if (anchorName.startsWith("l") || anchorName.startsWith("r")) {
      return AlignmentOrientation.HORIZONTAL;
    } else {
      return AlignmentOrientation.VERTICAL;
    }
  }

  /// Returns the absolute position of this Anchor in this FormLayout.
  /// The position is only correct if the layout is valid.
  double getAbsolutePosition() {
    FormLayoutAnchor? iRelatedAnchor = relatedAnchor;
    if (iRelatedAnchor != null) {
      return iRelatedAnchor.getAbsolutePosition() + position;
    } else {
      return position;
    }
  }

  /// Gets the related border anchor to this anchor.
  FormLayoutAnchor getBorderAnchor() {
    FormLayoutAnchor start = this;
    while (start.relatedAnchor != null) {
      start = start.relatedAnchor!;
    }
    return start;
  }

  /// Gets the related unused auto size anchor.
  FormLayoutAnchor getRelativeAnchor() {
    FormLayoutAnchor? start = this;
    while (start != null && !start.relative && start.relatedAnchor != null) {
      start = start.relatedAnchor;
    }
    return start ?? this;
  }
}
