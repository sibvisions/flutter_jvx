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

import 'package:flutter/widgets.dart';

import '../../layout/i_layout.dart';
import '../../util/i_clonable.dart';
import 'layout_position.dart';

enum LayoutState { DIRTY, VALID }

/// [LayoutData] represents the data relevant for layout calculations of a widget.
class LayoutData implements ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The id of the component.
  final String id;

  /// The name of the component.
  final String name;

  /// State of layout
  LayoutState layoutState;

  /// The id of the parent component.
  String? parentId;

  /// The layout of the component.
  ILayout? layout;

  /// The children of the component.
  List<String> children;

  /// The constraints as sent by the server for the component.
  String? constraints;

  /// The minimum size of the component.
  Size? minSize;

  /// The maximum size of the component.
  Size? maxSize;

  /// The preferred size of the component.
  Size? preferredSize;

  /// The calculated size of the component.
  Size? calculatedSize;

  /// The last calculated size of the component.
  Size? lastCalculatedSize;

  /// If a component is fixed size it will not change its size
  /// when its parent changes its size. e.g. A label might want more height,
  /// if it is constrained in width. A table (which is fixed size) will not want more height if it is
  /// constrained in width.
  bool isFixedSize;

  /// The insets of the component.
  EdgeInsets insets;

  /// The actual position of the component inside their parent.
  LayoutPosition? layoutPosition;

  /// The index of the component in relation to its siblings in a flow layout.
  int? indexOf;

  /// When height has been constrained what width did the component take.
  Map<double, double> heightConstrains;

  /// When width has been constrained what height did the component take.
  Map<double, double> widthConstrains;

  /// Time when layout was received from component
  DateTime? _receivedDate;

  set receivedDate(DateTime? date) {
    _receivedDate = date;

    //reset flat because it's already received
    if (_receivedDate != null) {
      preparedForSubmission = false;
    }
  }

  DateTime? get receivedDate => _receivedDate;

  /// This flag means that this object is marked for submission to the widget.
  /// It should get the receive date immediately. There's a delay between mark for submission
  /// and received. It's important to know that submission is "planned"
  /* don't clone/compare this field. */
  bool preparedForSubmission = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [LayoutData].
  LayoutData({
    required this.id,
    required this.name,
    required this.widthConstrains,
    required this.heightConstrains,
    this.layoutState = LayoutState.VALID,
    this.parentId,
    this.children = const [],
    this.constraints,
    this.minSize,
    this.maxSize,
    this.preferredSize,
    this.insets = EdgeInsets.zero,
    this.layoutPosition,
    this.calculatedSize,
    this.lastCalculatedSize,
    this.indexOf,
    this.layout,
    this.isFixedSize = false,
    DateTime? receivedDate
  })
  {
    _receivedDate = receivedDate;
  }

  /// Clones [LayoutData] as a deep copy.
  factory LayoutData.from(LayoutData pLayoutData) {
    return pLayoutData.clone();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Clones [LayoutData] as a deep copy.
  @override
  LayoutData clone() {
    return LayoutData(
      id: id,
      name: name,
      parentId: parentId,
      layout: layout?.clone(),
      children: List.of(children),
      constraints: constraints,
      minSize: minSize != null ? Size.copy(minSize!) : null,
      maxSize: maxSize != null ? Size.copy(maxSize!) : null,
      preferredSize: hasPreferredSize ? Size.copy(preferredSize!) : null,
      calculatedSize: hasCalculatedSize ? Size.copy(calculatedSize!) : null,
      lastCalculatedSize: hasLastCalculatedSize ? Size.copy(lastCalculatedSize!) : null,
      insets: insets != EdgeInsets.zero ? insets.copyWith() : EdgeInsets.zero,
      layoutState: layoutState,
      layoutPosition: layoutPosition?.clone(),
      indexOf: indexOf,
      heightConstrains: Map.of(heightConstrains),
      widthConstrains: Map.of(widthConstrains),
      isFixedSize: isFixedSize,
      receivedDate: receivedDate,
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LayoutData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void applyFromOther(LayoutData pLayoutData) {
    parentId = pLayoutData.parentId;
    layout = pLayoutData.layout?.clone();
    children = List.of(pLayoutData.children);
    constraints = pLayoutData.constraints;
    minSize = pLayoutData.minSize != null ? Size.copy(pLayoutData.minSize!) : null;
    maxSize = pLayoutData.maxSize != null ? Size.copy(pLayoutData.maxSize!) : null;
    preferredSize = pLayoutData.hasPreferredSize ? Size.copy(pLayoutData.preferredSize!) : null;
    calculatedSize = pLayoutData.hasCalculatedSize ? Size.copy(pLayoutData.calculatedSize!) : null;
    lastCalculatedSize = pLayoutData.hasLastCalculatedSize ? Size.copy(pLayoutData.lastCalculatedSize!) : null;
    insets = pLayoutData.insets != EdgeInsets.zero ? pLayoutData.insets.copyWith() : EdgeInsets.zero;
    layoutState = pLayoutData.layoutState;
    layoutPosition = pLayoutData.layoutPosition?.clone();
    indexOf = pLayoutData.indexOf;
    heightConstrains = Map.of(pLayoutData.heightConstrains);
    widthConstrains = Map.of(pLayoutData.widthConstrains);
    isFixedSize = pLayoutData.isFixedSize;
    receivedDate = pLayoutData.receivedDate;
  }

  /// If this component is a parent.
  bool get isParent {
    return layout != null;
  }

  /// If this component is a child and therefore has a parent.
  bool get isChild {
    return parentId != null;
  }

  /// If this component has a position inside their parent.
  bool get hasPosition {
    return layoutPosition != null;
  }

  /// If this component has a [minSize];
  bool get hasMinSize {
    return minSize != null;
  }

  /// If this component has a [maxSize];
  bool get hasMaxSize {
    return maxSize != null;
  }

  /// If this component has a [preferredSize];
  bool get hasPreferredSize {
    return preferredSize != null;
  }

  /// If this component has a [calculatedSize];
  bool get hasCalculatedSize {
    return calculatedSize != null;
  }

  /// If this component has a [lastCalculatedSize];
  bool get hasLastCalculatedSize {
    return lastCalculatedSize != null;
  }

  /// If this component has a new [calculatedSize] that does not equal its [lastCalculatedSize].
  bool get hasNewCalculatedSize {
    return calculatedSize != lastCalculatedSize;
  }

  /// If this component is constrained by its position and has no corresponding entries in its constrain maps.
  bool get isNewlyConstraint {
    if (!hasPreferredSize && !isFixedSize && (isWidthNewlyConstraint || isHeightNewlyConstraint) && !isParent) {
      return true;
    }
    return false;
  }

  /// If this component is constrained by its position width and has no corresponding entries in its width constrain map.
  bool get isWidthNewlyConstraint {
    if (hasPosition) {
      double posWidth = layoutPosition!.width;
      if (isWidthConstrained && widthConstrains[posWidth] == null) {
        return true;
      }
    }
    return false;
  }

  /// If this component is constrained by its position height and has no corresponding entries in its height constrain map.
  bool get isHeightNewlyConstraint {
    if (hasPosition) {
      double posHeight = layoutPosition!.height;
      if (isHeightConstrained && heightConstrains[posHeight] == null) {
        return true;
      }
    }
    return false;
  }

  /// If this component is constrained by its position height
  bool get isHeightConstrained {
    if (hasPosition && hasCalculatedSize) {
      double posHeight = layoutPosition!.height;
      double calcHeight = calculatedSize!.height;
      if (posHeight < calcHeight) {
        return true;
      }
    }
    return false;
  }

  /// If this component is constrained by its position width
  bool get isWidthConstrained {
    if (hasPosition && hasCalculatedSize) {
      double posWidth = layoutPosition!.width;
      double calcWidth = calculatedSize!.width;
      if (posWidth < calcWidth) {
        return true;
      }
    }
    return false;
  }

  /// If this component is constrained by its position
  bool get isConstrained {
    if (isHeightConstrained || isWidthConstrained) {
      return true;
    }
    return false;
  }

  /// Gets the preferred size of a component. The size is between the minimum and maximum size.
  ///
  /// If no preferred size is set, returns the lowest size between the minimum and maximum size.
  Size get bestSize {
    double width = 0;
    double height = 0;

    if (hasPreferredSize) {
      width = preferredSize!.width;
      height = preferredSize!.height;
    } else if (hasCalculatedSize) {
      width = calculatedSize!.width;
      height = calculatedSize!.height;

      // If component has position, see if a constrained position has already been set and replace current height or width
      if (hasPosition) {
        if (widthConstrains.containsKey(layoutPosition!.width)) {
          height = widthConstrains[layoutPosition!.width]!;
        }

        if (heightConstrains.containsKey(layoutPosition!.height)) {
          width = heightConstrains[layoutPosition!.height]!;
        }
      }
    }

    if (hasMinSize) {
      if (minSize!.width > width) {
        width = minSize!.width;
      }

      if (minSize!.height > height) {
        height = minSize!.height;
      }
    }

    if (hasMaxSize) {
      if (maxSize!.width < width) {
        width = maxSize!.width;
      }

      if (maxSize!.height < height) {
        height = maxSize!.height;
      }
    }

    return Size(width, height);
  }
}
