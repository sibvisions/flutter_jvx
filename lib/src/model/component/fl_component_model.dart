import 'package:flutter/material.dart';

import '../../../util/constants/i_color.dart';
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
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The default model to reset values to.
  FlComponentModel get defaultModel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Applies property values from the json sent by the mobile server.
  /// Only applies properties if they exist in the json,
  /// otherwise uses their initiated default values.
  void applyFromJson(Map<String, dynamic> pJson) {
    id = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.id,
      pDefault: defaultModel.id,
      pCurrent: id,
    );
    name = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.name,
      pDefault: defaultModel.name,
      pCurrent: name,
    );
    className = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.className,
      pDefault: defaultModel.className,
      pCurrent: className,
    );
    parent = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.parent,
      pDefault: defaultModel.parent,
      pCurrent: parent,
    );
    isRemoved = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.remove,
      pDefault: defaultModel.isRemoved,
      pCurrent: isRemoved,
      pConversion: ParseUtil.parseBool,
    );
    isVisible = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.visible,
      pDefault: defaultModel.isVisible,
      pCurrent: isVisible,
    );
    isEnabled = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.enabled,
      pDefault: defaultModel.isEnabled,
      pCurrent: isEnabled,
    );
    isFocusable = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.focusable,
      pDefault: defaultModel.isFocusable,
      pCurrent: isFocusable,
    );
    constraints = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.constraints,
      pDefault: defaultModel.constraints,
      pCurrent: constraints,
    );
    indexOf = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.indexOf,
      pDefault: defaultModel.indexOf,
      pCurrent: indexOf,
    );
    tabIndex = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.tabIndex,
      pDefault: defaultModel.tabIndex,
      pCurrent: tabIndex,
    );
    preferredSize = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.preferredSize,
      pDefault: defaultModel.preferredSize,
      pCurrent: preferredSize,
      pConversion: ParseUtil.parseSize,
    );
    minimumSize = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.minimumSize,
      pDefault: defaultModel.minimumSize,
      pCurrent: minimumSize,
      pConversion: ParseUtil.parseSize,
    );
    maximumSize = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.maximumSize,
      pDefault: defaultModel.maximumSize,
      pCurrent: maximumSize,
      pConversion: ParseUtil.parseSize,
    );
    bounds = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.bounds,
      pDefault: defaultModel.bounds,
      pCurrent: bounds,
      pConversion: ParseUtil.parseBounds,
    );
    background = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.background,
      pDefault: defaultModel.background,
      pCurrent: background,
      pConversion: ParseUtil.parseServerColor,
    );
    foreground = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.foreground,
      pDefault: defaultModel.foreground,
      pCurrent: foreground,
      pConversion: ParseUtil.parseServerColor,
    );
    verticalAlignment = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.verticalAlignment,
      pDefault: defaultModel.verticalAlignment,
      pCurrent: verticalAlignment,
      pConversion: VerticalAlignmentE.fromDynamic,
    );
    horizontalAlignment = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.horizontalAlignment,
      pDefault: defaultModel.horizontalAlignment,
      pCurrent: horizontalAlignment,
      pConversion: HorizontalAlignmentE.fromDynamic,
    );
    toolTipText = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.toolTipText,
      pDefault: defaultModel.toolTipText,
      pCurrent: toolTipText,
    );
    classNameEventSourceRef = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.classNameEventSourceRef,
      pDefault: defaultModel.classNameEventSourceRef,
      pCurrent: classNameEventSourceRef,
    );

    _parseFont(pJson, defaultModel);
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
      overflow: TextOverflow.ellipsis,
    );
  }

  dynamic getPropertyValue({
    required Map<String, dynamic> pJson,
    required String pKey,
    required dynamic pDefault,
    required dynamic pCurrent,
    dynamic Function(dynamic)? pConversion,
  }) {
    return ParseUtil.getPropertyValue(
      pJson: pJson,
      pKey: pKey,
      pDefault: pDefault,
      pCurrent: pCurrent,
      pConversion: pConversion,
    );
  }

  void _parseFont(Map<String, dynamic> pJson, FlComponentModel pDefaultModel) {
    if (pJson.containsKey(ApiObjectProperty.font)) {
      dynamic value = pJson[ApiObjectProperty.font];
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
