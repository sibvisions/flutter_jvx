
import 'dart:ui';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';

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
  /// 
  /// Returns `true` if layouting happened and `false` if nothing was layouted.
  List<BaseCommand> registerPreferredSize(String pId, String pParentId, LayoutData pLayoutData);

  /// Saves the [LayoutPosition]s to a parent and their children.
  void saveLayoutPositions(String pParentId, Map<String, LayoutPosition> pPositions, DateTime pStartOfCall);

  /// Applies the [LayoutPosition]s to a parent and their children.
  List<BaseCommand> applyLayoutConstraints(String pParentId);

  /// Calculates the layout.
  List<BaseCommand> calculateLayout(String pParentId);

  Size? screenSize;
}