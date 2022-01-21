import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/layout/alignments.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';
import 'package:flutter_client/util/constants/i_font.dart';
import '../../../util/parse_util.dart';

import '../api/api_object_property.dart';

/// The base component model.
abstract class FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Basic Data
  /// The component id.
  String id = "";

  /// The unique component name.
  String name = "";

  /// The classname of the component.
  String className = "";

  /// The id of the parent component.
  String? parent;

  /// If this component is currently removed, defaults to false
  bool isRemoved = false;

  /// If the component is visible.
  bool isVisible = true;

  /// If the component is enabled.
  bool isEnabled = true;

  /// If the component is focusable.
  bool isFocusable = true;

  // Layout Data
  /// The constraints string.
  String? constraints;

  /// The index of the component in relation to its siblings in a flow layout.
  int indexOf = 0;

  /// The desired tab index;
  int? tabIndex;

  // Size Data
  /// The preferred size of the component as sent by the server.
  Size? preferredSize;

  /// The minimum size of the component.
  Size? minimumSize;

  /// The maximum size of the component.
  Size? maximumSize;

  /// The bounds wanted by the component.
  LayoutPosition? bounds;

  // Style Data
  /// The background color.
  Color background = Colors.white;

  /// The foreground color.
  Color foreground = Colors.black;

  /// The vertical alignment.
  VerticalAlignment verticalAlignment = VerticalAlignment.CENTER;

  /// The horizontal alignment
  HorizontalAlignment horizontalAlignment = HorizontalAlignment.CENTER;

  /// The font of the component.
  String fontName = "Default";

  /// The size of the component.
  int fontSize = 12;

  /// If the component is bold;
  bool isBold = false;

  /// If the component is italic.
  bool isItalic = false;

  /// The tooltip text of the component.
  String? tooltipText;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a [FlComponentModel].
  FlComponentModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "Instance of $runtimeType with id: $id ";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void applyFromJson(Map<String, dynamic> pJson) {
    var jsonId = pJson[ApiObjectProperty.id];
    if (jsonId != null) {
      id = jsonId;
    }
    var jsonName = pJson[ApiObjectProperty.name];
    if (jsonName != null) {
      name = jsonName;
    }
    var jsonClassName = pJson[ApiObjectProperty.className];
    if (jsonClassName != null) {
      className = jsonClassName;
    }
    var jsonParent = pJson[ApiObjectProperty.parent];
    if (jsonParent != null) {
      parent = jsonParent;
    }
    var jsonIsRemoved = pJson[ApiObjectProperty.remove];
    if (jsonIsRemoved != null) {
      isRemoved = ParseUtil.parseBoolFromString(pBoolString: jsonIsRemoved)!;
    }
    var jsonIsVisible = pJson[ApiObjectProperty.visible];
    if (jsonIsVisible != null) {
      isVisible = jsonIsVisible;
    }
    var jsonIsEnabled = pJson[ApiObjectProperty.enabled];
    if (jsonIsEnabled != null) {
      isEnabled = jsonIsEnabled;
    }
    var jsonIsFocusable = pJson[ApiObjectProperty.focusable];
    if (jsonIsFocusable != null) {
      isFocusable = jsonIsFocusable;
    }
    var jsonConstraints = pJson[ApiObjectProperty.constraints];
    if (jsonConstraints != null) {
      constraints = jsonConstraints;
    }
    var jsonIndexOf = pJson[ApiObjectProperty.indexOf];
    if (jsonIndexOf != null) {
      indexOf = jsonIndexOf;
    }
    var jsonTabIndex = pJson[ApiObjectProperty.tabIndex];
    if (jsonTabIndex != null) {
      tabIndex = jsonTabIndex;
    }
    var jsonPreferredSize = pJson[ApiObjectProperty.preferredSize];
    if (jsonPreferredSize != null) {
      preferredSize = ParseUtil.parseSizeFromString(pSizeString: jsonPreferredSize)!;
    }
    var jsonMinimumSize = pJson[ApiObjectProperty.minimumSize];
    if (jsonMinimumSize != null) {
      minimumSize = ParseUtil.parseSizeFromString(pSizeString: jsonMinimumSize)!;
    }
    var jsonMaximumSize = pJson[ApiObjectProperty.maximumSize];
    if (jsonMaximumSize != null) {
      maximumSize = ParseUtil.parseSizeFromString(pSizeString: jsonMaximumSize)!;
    }
    var jsonBounds = pJson[ApiObjectProperty.bounds];
    if (jsonBounds != null) {
      bounds = ParseUtil.parseBounds(pValue: jsonBounds);
    }
    var jsonBackground = pJson[ApiObjectProperty.background];
    if (jsonBackground != null) {
      background = ParseUtil.parseHexColor(jsonBackground)!;
    }
    var jsonForeground = pJson[ApiObjectProperty.foreground];
    if (jsonForeground != null) {
      foreground = ParseUtil.parseHexColor(jsonForeground)!;
    }
    var jsonVerticalAlignment = pJson[ApiObjectProperty.verticalAlignment];
    if (jsonVerticalAlignment != null) {
      verticalAlignment = VerticalAlignment.values[jsonVerticalAlignment];
    }
    var jsonHorizontalAlignment = pJson[ApiObjectProperty.horizontalAlignment];
    if (jsonHorizontalAlignment != null) {
      horizontalAlignment = HorizontalAlignment.values[jsonHorizontalAlignment];
    }
    var fontValues = pJson[ApiObjectProperty.font];
    if (fontValues != null) {
      var fontValuesList = (fontValues as String).split(",");
      if (fontValuesList.isNotEmpty && fontValuesList.length == 3) {
        fontName = fontValuesList[0];
        fontSize = int.parse(fontValuesList[2]);
        isBold = (int.parse(fontValuesList[1]) & IFont.TEXT_BOLD) == IFont.TEXT_BOLD;
        isItalic = (int.parse(fontValuesList[1]) & IFont.TEXT_ITALIC) == IFont.TEXT_ITALIC;
      }
    }
    var jsonTooltipText = pJson[ApiObjectProperty.toolTipText];
    if (jsonTooltipText != null) {
      tooltipText = jsonTooltipText;
    }
  }
}
