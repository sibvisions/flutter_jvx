import 'dart:ui';

import '../../model/command/base_command.dart';
import '../../model/layout/layout_data.dart';
import '../service.dart';

/// An [ILayoutService] handles the layouting of components.
abstract class ILayoutService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory ILayoutService() => services<ILayoutService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Basically resets the service
  void clear();

  /// Registers a parent for receiving child constraint changes.
  ///
  /// Returns Command to update UI if, layout has been newly calculated, returns an empty list if nothing happened.
  Future<List<BaseCommand>> reportLayout({required LayoutData pLayoutData});

  /// Registers a preferred size for a child element.
  ///
  /// Returns Command to update UI if, layout has been newly calculated.
  Future<List<BaseCommand>> reportPreferredSize({required LayoutData pLayoutData});

  /// Register a fixed size of a component
  ///
  /// Returns Command to update UI if, layout has been newly calculated.
  Future<List<BaseCommand>> setScreenSize({required String pScreenComponentId, required Size pSize});

  /// Marks Layout as Dirty, used to wait for all changing components to re-register themselves to avoid unnecessary re-renders.
  Future<bool> markLayoutAsDirty({required String pComponentId});

  /// Removes a component from the layouting system.
  /// Returns `true` if removed and `false` if nothing was removed.
  Future<bool> removeLayout({required String pComponentId});

  /// If any parent is currently layouting.
  Future<bool> layoutInProcess();

  Future<bool> setValid({required bool isValid});

  /// If it is allowed to layout.
  Future<bool> isValid();

  /// Deletes Screen layout data, and all descendants.
  Future<bool> deleteScreen({required String pComponentId});
}
