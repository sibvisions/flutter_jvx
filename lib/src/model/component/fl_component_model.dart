/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../layout/alignments.dart';
import '../layout/layout_position.dart';
import '../response/dal_fetch_response.dart';
import 'i_font_style.dart';

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

  /// If this component is indef removed, defaults to false
  bool isDestroyed = false;

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
  int fontSize = 14;

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

  /// Screen long name
  String? screenLongName;

  /// Styles
  Set<String> styles = {};

  /// If the component sends focus gained events.
  bool eventFocusGained = false;

  /// If the component sends focus lost events.
  bool eventFocusLost = false;

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
    return "$runtimeType{id: $id}";
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
    isDestroyed = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.destroy,
      pDefault: defaultModel.isDestroyed,
      pCurrent: isDestroyed,
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
      pConversion: _parseSize,
    );
    minimumSize = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.minimumSize,
      pDefault: defaultModel.minimumSize,
      pCurrent: minimumSize,
      pConversion: _parseSize,
    );
    maximumSize = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.maximumSize,
      pDefault: defaultModel.maximumSize,
      pCurrent: maximumSize,
      pConversion: _parseSize,
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
      pConversion: ParseUtil.parseBackgroundColor,
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
      pCondition: (pValue) => pValue < VerticalAlignment.values.length && pValue >= 0,
      pConversion: VerticalAlignmentE.fromDynamic,
    );
    horizontalAlignment = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.horizontalAlignment,
      pDefault: defaultModel.horizontalAlignment,
      pCurrent: horizontalAlignment,
      pCondition: (pValue) => pValue < HorizontalAlignment.values.length && pValue >= 0,
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
    styles = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.style,
      pDefault: defaultModel.styles,
      pConversion: _parseStyle,
      pCurrent: styles,
    );

    eventFocusGained = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.eventFocusGained,
      pDefault: defaultModel.eventFocusGained,
      pConversion: ParseUtil.parseBool,
      pCurrent: eventFocusGained,
    );

    eventFocusLost = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.eventFocusLost,
      pDefault: defaultModel.eventFocusLost,
      pConversion: ParseUtil.parseBool,
      pCurrent: eventFocusLost,
    );

    _parseFont(pJson, defaultModel);
  }

  /// If this component is used in a cell editor, some values are overriden.
  void applyCellEditorOverrides(Map<String, dynamic> pJson) {
    Map<String, dynamic> overrideJson = {};
    if (pJson.containsKey(ApiObjectProperty.cellEditorHorizontalAlignment)) {
      overrideJson[ApiObjectProperty.horizontalAlignment] = pJson[ApiObjectProperty.cellEditorHorizontalAlignment];
    }
    if (pJson.containsKey(ApiObjectProperty.cellEditorVerticalAlignment)) {
      overrideJson[ApiObjectProperty.verticalAlignment] = pJson[ApiObjectProperty.cellEditorVerticalAlignment];
    }
    if (pJson.containsKey(ApiObjectProperty.cellEditorBackground)) {
      overrideJson[ApiObjectProperty.background] = pJson[ApiObjectProperty.cellEditorBackground];
    }
    if (pJson.containsKey(ApiObjectProperty.cellEditorForeground)) {
      overrideJson[ApiObjectProperty.foreground] = pJson[ApiObjectProperty.cellEditorForeground];
    }
    if (pJson.containsKey(ApiObjectProperty.cellEditorFont)) {
      overrideJson[ApiObjectProperty.font] = pJson[ApiObjectProperty.cellEditorFont];
    }
    if (pJson.containsKey(ApiObjectProperty.cellEditorStyle)) {
      overrideJson[ApiObjectProperty.style] = pJson[ApiObjectProperty.cellEditorStyle];
    }
    applyFromJson(overrideJson);
  }

  /// Returns the textstyle of the component.
  TextStyle createTextStyle(
      {Color? pForeground, double? pFontSize, FontStyle? pFontStyle, FontWeight? pFontWeight, String? pFontFamily}) {
    return TextStyle(
      color: pForeground ?? (isEnabled ? foreground : JVxColors.toggleColor(JVxColors.COMPONENT_DISABLED)),
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
    bool Function(dynamic)? pCondition,
  }) {
    return ParseUtil.getPropertyValue(
      pJson: pJson,
      pKey: pKey,
      pDefault: pDefault,
      pCurrent: pCurrent,
      pConversion: pConversion,
      pCondition: pCondition,
    );
  }

  void _parseFont(Map<String, dynamic> pJson, FlComponentModel pDefaultModel) {
    if (pJson.containsKey(ApiObjectProperty.font)) {
      String? value = pJson[ApiObjectProperty.font];
      if (value != null) {
        JVxFont font = JVxFont.fromString(value);
        fontName = font.fontName;
        fontSize = font.fontSize;
        isBold = font.isBold;
        isItalic = font.isItalic;
      } else {
        fontName = pDefaultModel.fontName;
        fontSize = pDefaultModel.fontSize;
        isBold = pDefaultModel.isBold;
        isItalic = pDefaultModel.isItalic;
      }
    }
  }

  Set<String> _parseStyle(dynamic pStyle) {
    String sStyle = (pStyle as String);

    return sStyle.split(",").toSet();
  }

  /// Parses a [Size] object from a string, will only parse correctly if provided string was formatted :
  /// "x,y" - e.g. "200,400" -> Size(200,400), if provided String was null, returned size will also be null
  static Size _parseSize(dynamic pSize) {
    List<String> split = pSize.split(",");

    double width = double.parse(split[0]);
    double height = double.parse(split[1]);

    return Size(width, height) * ConfigController().getScaling();
  }

  void applyCellFormat(CellFormat cellFormat) {
    background = cellFormat.background ?? background;
    foreground = cellFormat.foreground ?? foreground;
    isBold = cellFormat.font?.isBold ?? isBold;
    isItalic = cellFormat.font?.isItalic ?? isItalic;
    fontName = cellFormat.font?.fontName ?? fontName;
    fontSize = cellFormat.font?.fontSize ?? fontSize;
  }
}
