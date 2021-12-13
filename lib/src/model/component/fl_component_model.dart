import 'package:flutter/material.dart';

import '../../../util/size_util.dart';
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

  // Styling
  /// If the component is visible.
  final bool? isVisible;

  /// Creates a [FlComponentModel] from a json.
  FlComponentModel.fromJson(Map<String, dynamic> json)
      : name = json[ApiObjectProperty.name],
        className = json[ApiObjectProperty.className],
        parent = json[ApiObjectProperty.parent],
        id = json[ApiObjectProperty.id],
        constraints = json[ApiObjectProperty.constraints],
        preferredSize = SizeUtil.fromString(json[ApiObjectProperty.preferredSize]),
        minimumSize = SizeUtil.fromString(json[ApiObjectProperty.minimumSize]),
        maximumSize = SizeUtil.fromString(json[ApiObjectProperty.maximumSize]),
        isVisible = json[ApiObjectProperty.visible];

  /// Updates the component model with new properties. If no property is passed, uses the old value.
  FlComponentModel.updatedProperties(FlComponentModel oldModel, dynamic json)
      : name = oldModel.name,
        id = oldModel.id,
        className = oldModel.className,
        parent = json[ApiObjectProperty.parent] ?? oldModel.parent,
        constraints = json[ApiObjectProperty.constraints] ?? oldModel.constraints,
        preferredSize = json[ApiObjectProperty.preferredSize] ?? oldModel.preferredSize,
        minimumSize = json[ApiObjectProperty.minimumSize] ?? oldModel.minimumSize,
        maximumSize = json[ApiObjectProperty.maximumSize] ?? oldModel.maximumSize,
        isVisible = json[ApiObjectProperty.visible] ?? oldModel.isVisible;

  FlComponentModel updateComponent(FlComponentModel oldModel, dynamic json);
}
