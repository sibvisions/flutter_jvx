import 'dart:ui';

import '../../model/command/base_command.dart';
import '../../model/layout/layout_data.dart';

/// An [ILayoutService] handles the layouting of components.
abstract class ILayoutService {
  /// Registers a parent for receiving child constraint changes.
  ///
  /// Returns Command to update UI if, layout has been newly calculated, returns an empty list if nothing happened.
  List<BaseCommand> registerAsParent({required LayoutData pLayoutData});

  /// Removes a parent.
  ///
  /// Returns `true` if removed and `false` if nothing was removed.
  bool removeAsParent(String pParentId);

  /// Registers a preferred size for a child element.
  ///
  /// Returns Command to update UI if, layout has been newly calculated.
  List<BaseCommand> registerPreferredSize(String pId, LayoutData pLayoutData);

  /// Register a fixed size of a component
  ///
  /// Returns Command to update UI if, layout has been newly calculated.
  List<BaseCommand> setComponentSize({required String id, required Size size});

  /// Marks Layout as Dirty, used to wait for all changing components to re-register themselves to avoid unnecessary re-renders.
  void markLayoutAsDirty({required String id});
}
