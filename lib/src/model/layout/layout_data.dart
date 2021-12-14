import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../util/i_clonable.dart';
import '../../layout/i_layout.dart';
import 'layout_position.dart';

enum LayoutState { DIRTY, VALID }

/// [LayoutData] represents the data relevant for layout calculations of a widget.
class LayoutData implements ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// State of layout
  LayoutState layoutState = LayoutState.VALID;

  /// The id of the component.
  final String id;

  /// The id of the parent component.
  final String? parentId;

  /// The layout of the component.
  ILayout? layout;

  /// The children of the component.
  List<String>? children;

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

  /// The insets of the component.
  EdgeInsets? insets;

  /// The actual position of the component inside their parent.
  LayoutPosition? layoutPosition;

  /// LayoutData for layouts
  String? layoutData;

  /// LayoutString for layouts
  String? layoutString;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [LayoutData].
  LayoutData(
      {required this.id,
      this.layoutData,
      this.parentId,
      this.layout,
      this.children,
      this.constraints,
      this.minSize,
      this.maxSize,
      this.preferredSize,
      this.insets,
      this.layoutPosition,
      this.calculatedSize,
      this.lastCalculatedSize,
      this.layoutString});

  /// Clones [LayoutData] as a deep copy.
  LayoutData.from(LayoutData pLayoutData)
      : id = pLayoutData.id,
        layoutData = pLayoutData.layoutData,
        parentId = pLayoutData.parentId,
        layout = pLayoutData.layout?.clone(),
        children = pLayoutData.children != null ? List.from(pLayoutData.children!) : null,
        constraints = pLayoutData.constraints,
        minSize = pLayoutData.minSize != null ? Size.copy(pLayoutData.minSize!) : null,
        maxSize = pLayoutData.maxSize != null ? Size.copy(pLayoutData.maxSize!) : null,
        preferredSize = pLayoutData.hasPreferredSize ? Size.copy(pLayoutData.preferredSize!) : null,
        calculatedSize = pLayoutData.hasCalculatedSize ? Size.copy(pLayoutData.calculatedSize!) : null,
        // lastCalculatedSize = pLayoutData.hasCalculatedSize ? Size.copy(pLayoutData.lastCalculatedSize!) : null,
        insets = pLayoutData.insets != null ? pLayoutData.insets!.copyWith() : null,
        layoutState = pLayoutData.layoutState,
        layoutString = pLayoutData.layoutString,
        layoutPosition = pLayoutData.layoutPosition != null ? pLayoutData.layoutPosition!.clone() : null;

  /// Creates a bare-bones [LayoutData] object for retrieving in a set.
  LayoutData.fromId({required this.id})
      : layout = null,
        parentId = null;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Clones [LayoutData] as a deep copy.
  @override
  LayoutData clone() {
    return LayoutData.from(this);
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

  /// If this component is a parent.
  bool get isParent {
    return children != null && children!.isNotEmpty && layout != null;
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

  /// If this component has [insets];
  bool get hasInsets {
    return insets != null;
  }

  /// If this componen has a new [calculatedSize] that does not equal its [lastCalculatedSize].
  bool get hasNewCalculatedSize {
    if (calculatedSize == null && lastCalculatedSize == null) {
      return false;
    } else if (calculatedSize != null && lastCalculatedSize == null ||
        calculatedSize == null && lastCalculatedSize != null) {
      return true;
    }

    return calculatedSize!.width != lastCalculatedSize!.width || calculatedSize!.height != lastCalculatedSize!.height;
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

  /// Returns the minimum size. If maximum size is smaller than minimum, returns maximum size. If no minimum size is set, returns `0,0`
  Size get bestMinSize {
    double width = 0;
    double height = 0;

    if (hasMinSize) {
      width = minSize!.width;
      height = minSize!.height;
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
