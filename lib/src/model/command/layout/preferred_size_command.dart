import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'layout_command.dart';

class PreferredSizeCommand extends LayoutCommand {
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  /// Component id.
  final String componentId;

  /// Id of the parent component.
  final String parentId;

  /// Contains the current [LayoutData] for the component.
  final LayoutData layoutData;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  PreferredSizeCommand({
    required this.layoutData,
    required this.parentId,
    required this.componentId,
    required String reason,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  @override
  String get logString => "PreferredSizeCommand | Component: $componentId | Parent: $parentId | Reason $reason";

}
