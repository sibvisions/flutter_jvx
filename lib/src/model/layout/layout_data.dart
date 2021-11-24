import 'dart:ui';

import '../../layout/i_layout.dart';
import '../../../util/i_clonable.dart';

import 'layout_position.dart';

/// [LayoutData] represents the data relevant for layout calculations of a widget.
class LayoutData implements ICloneable{
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The id of the component.
  final String id;

  /// The id of the parent component.
  final String? parentId;

  /// The layout of the component.
  final ILayout? layout;

  /// The children of the component.
  List<LayoutData>? children;

  /// The constraints as sent by the server.
  String? constraints;

  /// The minimum size of the component.
  Size? minSize;

  /// The maximum size of the component.
  Size? maxSize;

  /// The preferred size of the component.
  Size? preferredSize;

  /// The actual position of the component inside their parent.
  LayoutPosition? layoutPosition;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [LayoutData].
  LayoutData(
      {required this.id,
      this.parentId,
      this.layout,
      this.children,
      this.constraints,
      this.minSize,
      this.maxSize,
      this.preferredSize,
      this.layoutPosition});

  /// Clones [LayoutData] as a deep copy.
  LayoutData.from(LayoutData pLayoutData)
      : id = pLayoutData.id,
        parentId = pLayoutData.parentId,
        layout = pLayoutData.layout?.clone(),
        children = pLayoutData.children != null ? List.from(pLayoutData.children!) : null,
        constraints = pLayoutData.constraints,
        minSize = pLayoutData.minSize != null ? Size.copy(pLayoutData.minSize!) : null,
        maxSize = pLayoutData.maxSize != null ? Size.copy(pLayoutData.maxSize!) : null,
        preferredSize = pLayoutData.preferredSize != null ? Size.copy(pLayoutData.preferredSize!) : null,
        layoutPosition = pLayoutData.layoutPosition != null ? pLayoutData.layoutPosition!.clone() : null;


  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Clones [LayoutData] as a deep copy.
  @override
  LayoutData clone() {
    return LayoutData.from(this);
  }

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
}
