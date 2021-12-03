
import 'package:flutter/material.dart';

import '../../model/layout/layout_position.dart';
import '../../layout/i_layout.dart';

/// An [ILayoutService] handles the layouting of components.
abstract class ILayoutService {
  /// Registers a parent for receiving child constraint changes.
  ///
  /// Returns `true` if registered as a new parent and `false` if it was replaced.
  bool registerAsParent(String pId, List<String> pChildrenIds, ILayout pLayout);

  /// Removes a parent.
  ///
  /// Returns `true` if removed and `false` if nothing was removed.
  bool removeAsParent(String pParentId);

  /// Registers a preferred size for a child element.
  void registerPreferredSize(String pId, String pParentId, Size pSize, String pConstraints);

  /// Applies the [LayoutPosition]s to a parent and their children.
  void applyLayoutConstraints(String pParentId, Map<String, LayoutPosition> pPositions, DateTime pStartOfCall);
}