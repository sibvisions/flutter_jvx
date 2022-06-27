import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/label/fl_label_model.dart';
import 'package:flutter_client/util/constants/i_color.dart';

import '../../../util/constants/i_font.dart';
import '../../../util/parse_util.dart';
import '../api/api_object_property.dart';
import '../layout/alignments.dart';
import '../layout/layout_position.dart';

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

  /// The index of the component in relation to its siblings.
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
  Color? background;

  /// The foreground color.
  Color? foreground;

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
  String? toolTipText;

  /// The last changed model keys.
  Set<String> lastChangedProperties = {};

  /// Class Name Reference
  String? classNameEventSourceRef;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a [FlComponentModel].
  ///
  /// Always initiate a model first, then call [applyFromJson].
  FlComponentModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "Instance of $runtimeType with id: $id ";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Applies property values from the json sent by the mobile server.
  /// Only applies properties if they exist in the json,
  /// otherwise uses their initiated default values.
  void applyFromJson(Map<String, dynamic> pJson) {
    FlComponentModel defaultModel = FlLabelModel();

    id = _valueToSet(
      pJson,
      ApiObjectProperty.id,
      defaultModel.id,
      id,
    );
    name = _valueToSet(
      pJson,
      ApiObjectProperty.name,
      defaultModel.name,
      name,
    );
    className = _valueToSet(
      pJson,
      ApiObjectProperty.className,
      defaultModel.className,
      className,
    );
    parent = _valueToSet(
      pJson,
      ApiObjectProperty.parent,
      defaultModel.parent,
      parent,
    );
    isRemoved = _valueToSet(
      pJson,
      ApiObjectProperty.remove,
      defaultModel.isRemoved,
      isRemoved,
      ParseUtil.parseBool,
    );
    isVisible = _valueToSet(
      pJson,
      ApiObjectProperty.visible,
      defaultModel.isVisible,
      isVisible,
    );
    isEnabled = _valueToSet(
      pJson,
      ApiObjectProperty.enabled,
      defaultModel.isEnabled,
      isEnabled,
    );
    isFocusable = _valueToSet(
      pJson,
      ApiObjectProperty.focusable,
      defaultModel.isFocusable,
      isFocusable,
    );
    constraints = _valueToSet(
      pJson,
      ApiObjectProperty.constraints,
      defaultModel.constraints,
      constraints,
    );
    indexOf = _valueToSet(
      pJson,
      ApiObjectProperty.indexOf,
      defaultModel.indexOf,
      indexOf,
    );
    tabIndex = _valueToSet(
      pJson,
      ApiObjectProperty.tabIndex,
      defaultModel.tabIndex,
      tabIndex,
    );
    preferredSize = _valueToSet(
      pJson,
      ApiObjectProperty.preferredSize,
      defaultModel.preferredSize,
      preferredSize,
      ParseUtil.parseSize,
    );
    minimumSize = _valueToSet(
      pJson,
      ApiObjectProperty.minimumSize,
      defaultModel.minimumSize,
      minimumSize,
      ParseUtil.parseSize,
    );
    maximumSize = _valueToSet(
      pJson,
      ApiObjectProperty.maximumSize,
      defaultModel.maximumSize,
      maximumSize,
      ParseUtil.parseSize,
    );
    bounds = _valueToSet(
      pJson,
      ApiObjectProperty.bounds,
      defaultModel.bounds,
      bounds,
      ParseUtil.parseBounds,
    );
    background = _valueToSet(
      pJson,
      ApiObjectProperty.background,
      defaultModel.background,
      background,
      ParseUtil.parseServerColor,
    );
    foreground = _valueToSet(
      pJson,
      ApiObjectProperty.foreground,
      defaultModel.foreground,
      foreground,
      ParseUtil.parseServerColor,
    );
    verticalAlignment = _valueToSet(
      pJson,
      ApiObjectProperty.verticalAlignment,
      defaultModel.verticalAlignment,
      verticalAlignment,
      VerticalAlignmentE.fromDynamic,
    );
    horizontalAlignment = _valueToSet(
      pJson,
      ApiObjectProperty.horizontalAlignment,
      defaultModel.horizontalAlignment,
      horizontalAlignment,
      HorizontalAlignmentE.fromDynamic,
    );
    toolTipText = _valueToSet(
      pJson,
      ApiObjectProperty.toolTipText,
      defaultModel.toolTipText,
      toolTipText,
    );
    classNameEventSourceRef = _valueToSet(
      pJson,
      ApiObjectProperty.classNameEventSourceRef,
      defaultModel.classNameEventSourceRef,
      classNameEventSourceRef,
    );

    _parseFont(pJson, ApiObjectProperty.font, defaultModel);
  }

  /// If this component is used in a cell editor, some values are overriden.
  void applyCellEditorOverrides(Map<String, dynamic> pJson) {
    var jsonCellEditorHorizontalAlignment = pJson[ApiObjectProperty.cellEditorHorizontalAlignment];
    if (jsonCellEditorHorizontalAlignment != null) {
      horizontalAlignment = HorizontalAlignment.values[jsonCellEditorHorizontalAlignment];
    }

    var jsonCellEditorVerticalAlignment = pJson[ApiObjectProperty.cellEditorVerticalAlignment];
    if (jsonCellEditorVerticalAlignment != null) {
      verticalAlignment = VerticalAlignment.values[jsonCellEditorVerticalAlignment];
    }

    var jsonCellEditorBackground = pJson[ApiObjectProperty.cellEditorBackground];
    if (jsonCellEditorBackground != null) {
      background = ParseUtil.parseServerColor(jsonCellEditorBackground)!;
    }

    var jsonCellEditorForeground = pJson[ApiObjectProperty.cellEditorForeground];
    if (jsonCellEditorForeground != null) {
      foreground = ParseUtil.parseServerColor(jsonCellEditorForeground)!;
    }

    var jsonCellEditorFont = pJson[ApiObjectProperty.cellEditorFont];
    if (jsonCellEditorFont != null) {
      var fontValuesList = (jsonCellEditorFont as String).split(",");
      if (fontValuesList.isNotEmpty && fontValuesList.length == 3) {
        fontName = fontValuesList[0];
        fontSize = int.parse(fontValuesList[2]);
        isBold = (int.parse(fontValuesList[1]) & IFont.TEXT_BOLD) == IFont.TEXT_BOLD;
        isItalic = (int.parse(fontValuesList[1]) & IFont.TEXT_ITALIC) == IFont.TEXT_ITALIC;
      }
    }
  }

  /// Returns the textstyle of the component.
  TextStyle getTextStyle(
      {Color? pForeground, double? pFontSize, FontStyle? pFontStyle, FontWeight? pFontWeight, String? pFontFamily}) {
    return TextStyle(
      color: pForeground ?? (isEnabled ? foreground : IColorConstants.COMPONENT_DISABLED),
      fontSize: pFontSize ?? fontSize.toDouble(),
      fontStyle: pFontStyle ?? (isItalic ? FontStyle.italic : FontStyle.normal),
      fontWeight: pFontWeight ?? (isBold ? FontWeight.bold : FontWeight.normal),
      fontFamily: pFontFamily ?? fontName,
    );
  }

  dynamic _valueToSet(
    Map<String, dynamic> pJson,
    String pKey,
    dynamic pDefault,
    dynamic pCurrent, [
    dynamic Function(dynamic)? pConversion,
  ]) {
    if (pJson.containsKey(pKey)) {
      dynamic value = pJson[pKey];
      if (value != null) {
        if (pConversion != null) {
          return pConversion.call(value);
        } else {
          return value;
        }
      } else {
        return pDefault;
      }
    }
    return pCurrent;
  }

  void _parseFont(Map<String, dynamic> pJson, String pKey, FlComponentModel pDefaultModel) {
    if (pJson.containsKey(pKey)) {
      dynamic value = pJson[pKey];
      if (value != null) {
        var fontValuesList = (value as String).split(",");
        if (fontValuesList.isNotEmpty && fontValuesList.length == 3) {
          fontName = fontValuesList[0];
          fontSize = int.parse(fontValuesList[2]);
          isBold = (int.parse(fontValuesList[1]) & IFont.TEXT_BOLD) == IFont.TEXT_BOLD;
          isItalic = (int.parse(fontValuesList[1]) & IFont.TEXT_ITALIC) == IFont.TEXT_ITALIC;
        }
      } else {
        fontName = pDefaultModel.fontName;
        fontSize = pDefaultModel.fontSize;
        isBold = pDefaultModel.isBold;
        isItalic = pDefaultModel.isItalic;
      }
    }
  }
}
