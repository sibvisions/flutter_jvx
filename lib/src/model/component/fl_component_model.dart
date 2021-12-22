import 'package:flutter/material.dart';
import 'package:flutter_client/util/parse_util.dart';

import '../api/api_object_property.dart';

/// The base component model.
abstract class FlComponentModel {
  // Basic Data
  /// The component id.
  final String id;

  /// The unique component name.
  final String name;

  /// The classname of the component.
  final String className;

  /// The constraints string.
  final String? constraints;

  /// The id of the parent component.
  final String? parent;
  // Sizes
  /// The preferred size of the component as sent by the server.
  final Size? preferredSize;

  /// The minimum size of the component.
  final Size? minimumSize;

  /// The maximum size of the component.
  final Size? maximumSize;

  /// If this component is currently removed, defaults to false
  final bool isRemoved;

  /// If the component is visible.
  final bool isVisible;

  /// The index of the component in relation to its siblings in a flow layout.
  final int? indexOf;

  /// Creates a [FlComponentModel] from a json.
  FlComponentModel.fromJson(Map<String, dynamic> json)
      : name = json[ApiObjectProperty.name],
        className = json[ApiObjectProperty.className],
        parent = json[ApiObjectProperty.parent],
        id = json[ApiObjectProperty.id],
        constraints = json[ApiObjectProperty.constraints],
        preferredSize = ParseUtil.parseSizeFromString(pSizeString: json[ApiObjectProperty.preferredSize]),
        minimumSize = ParseUtil.parseSizeFromString(pSizeString: json[ApiObjectProperty.minimumSize]),
        maximumSize = ParseUtil.parseSizeFromString(pSizeString: json[ApiObjectProperty.maximumSize]),
        isVisible = json[ApiObjectProperty.visible] ?? true,
        isRemoved = ParseUtil.parseBoolFromString(pBoolString: json[ApiObjectProperty.remove]) ?? false,
        indexOf = json[ApiObjectProperty.indexOf];

  /// Updates the component model with new properties. If no property is passed, uses the old value.
  FlComponentModel.updatedProperties(FlComponentModel oldModel, dynamic json)
      : name = oldModel.name,
        id = oldModel.id,
        className = oldModel.className,
        parent = json[ApiObjectProperty.parent] ?? oldModel.parent,
        constraints = json[ApiObjectProperty.constraints] ?? oldModel.constraints,
        preferredSize =
            ParseUtil.parseSizeFromString(pSizeString: json[ApiObjectProperty.preferredSize]) ?? oldModel.preferredSize,
        minimumSize =
            ParseUtil.parseSizeFromString(pSizeString: json[ApiObjectProperty.minimumSize]) ?? oldModel.minimumSize,
        maximumSize =
            ParseUtil.parseSizeFromString(pSizeString: json[ApiObjectProperty.maximumSize]) ?? oldModel.maximumSize,
        isVisible = json[ApiObjectProperty.visible] ?? oldModel.isVisible,
        isRemoved = ParseUtil.parseBoolFromString(pBoolString: json[ApiObjectProperty.remove]) ?? oldModel.isRemoved,
        indexOf = json[ApiObjectProperty.indexOf] ?? oldModel.indexOf;

  FlComponentModel updateComponent(FlComponentModel oldModel, dynamic json);

  @override
  String toString() {
    return "Instance of $runtimeType with id: $id ";
  }
}
