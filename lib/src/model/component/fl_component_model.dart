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

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../components/dummy/fl_dummy_widget.dart';
import '../../components/panel/group/fl_group_panel_wrapper.dart';
import '../../components/panel/tabset/fl_tab_panel_wrapper.dart';
import '../../flutter_ui.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/config/i_config_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/i_types.dart';
import '../../util/icon_util.dart';
import '../../util/jvx_colors.dart';
import '../../util/parse_util.dart';
import '../layout/alignments.dart';
import '../layout/layout_position.dart';
import '../response/record_format.dart';
import 'editor/cell_editor/cell_editor_model.dart';
import 'i_font_style.dart';

part 'button/fl_button_model.dart';
part 'button/fl_popup_menu_button_model.dart';
part 'button/fl_popup_menu_item_model.dart';
part 'button/fl_popup_menu_model.dart';
part 'button/fl_radio_button_model.dart';
part 'button/fl_separator.dart';
part 'button/fl_toggle_button_model.dart';
part 'chart/fl_chart_model.dart';
part 'check_box/fl_check_box_model.dart';
part 'custom/fl_custom_container_model.dart';
part 'dummy/fl_dummy_model.dart';
part 'editor/cell_editor/date/fl_date_editor_model.dart';
part 'editor/cell_editor/fl_image_cell_editor_model.dart';
part 'editor/cell_editor/linked/fl_linked_editor_model.dart';
part 'editor/fl_editor_model.dart';
part 'editor/text_area/fl_text_area_model.dart';
part 'editor/password_field/fl_password_field_model.dart';
part 'editor/text_field/fl_text_field_model.dart';
part 'gauge/fl_gauge_model.dart';
part 'icon/fl_icon_model.dart';
part 'label/fl_label_model.dart';
part 'map/fl_map_model.dart';
part 'panel/fl_group_panel_model.dart';
part 'panel/fl_panel_model.dart';
part 'panel/fl_split_panel_model.dart';
part 'panel/fl_tab_panel_model.dart';
part 'table/fl_table_model.dart';
part 'tree/fl_tree_model.dart';

/// The base component model.
abstract class FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The style if an editor should not have a clear button.
  static const String STYLE_NO_CLEAR_ICON = "f_no_clear";

  /// If the component has disabled the mobile scaling
  static const String STYLE_NO_SCALING = "f_no_scaling";

  /// The marker of icon styles.
  static const String STYLE_ICON_MARKER = "f_icon";

  /// The icon on the left side of the component.
  static const String STYLE_PREFIX_ICON = "${STYLE_ICON_MARKER}_prefix_";

  /// The icon on the right side of the component.
  static const String STYLE_SUFFIX_ICON = "${STYLE_ICON_MARKER}_suffix_";

  /// The color of the border.
  static const String STYLE_BORDER_COLOR = "f_border_color_";

  /// The color of the border when focused.
  static const String STYLE_BORDER_COLOR_FOCUSED = "f_border_focused_color_";

  /// The color of the border when disabled.
  static const String STYLE_BORDER_COLOR_DISABLED = "f_border_disabled_color_";

  /// The color of the text.
  static const String STYLE_TEXT_COLOR = "f_text_color_";

  /// The color of the text when disabled.
  static const String STYLE_TEXT_COLOR_DISABLED = "f_text_disabled_color_";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Basic Data

  /// The json base data
  Map<String, dynamic>? jsonBase;

  // The merges json data
  Map<String, dynamic> jsonMerge = {};

  /// The component id.
  String id = "";

  /// The unique component name.
  ///
  /// Example in case of a screen [FlPanelModel]:
  /// "Sec-BL"
  String name = "";

  /// The classname of the component.
  String className = "";

  /// The id of the parent component.
  String? parent;

  /// If this component is currently removed, defaults to false
  bool isRemoved = false;

  /// If this component is indefinitely removed, defaults to false
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
  Size? _preferredSize;

  /// The preferred size of the component as sent by the server.
  // ignore: unnecessary_getters_setters
  Size? get preferredSize => _preferredSize;

  /// The preferred size of the component as sent by the server.
  set preferredSize(Size? value) {
    _preferredSize = value;
  }

  /// The minimum size of the component.
  Size? _minimumSize;

  /// The minimum size of the component.
  // ignore: unnecessary_getters_setters
  Size? get minimumSize => _minimumSize;

  /// The minimum size of the component.
  set minimumSize(Size? minimumSize) {
    _minimumSize = minimumSize;
  }

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
  JVxFont? font;

  /// The tooltip text of the component.
  String? toolTipText;

  /// The last changed model keys.
  Set<String> lastChangedProperties = {};

  /// Class Name Reference
  String? classNameEventSourceRef;

  /// Styles
  Set<String> styles = {};

  /// If the component sends focus gained events.
  bool eventFocusGained = false;

  /// If the component sends focus lost events.
  bool eventFocusLost = false;

  /// If the component sends mouse entered events.
  bool eventMousePressed = false;

  /// If the component sends mouse exited events.
  bool eventMouseReleased = false;

  /// If the component sends mouse clicked events.
  bool eventMouseClicked = false;

  /// The aria label.
  String ariaLabel = "";

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
  void applyFromJson(Map<String, dynamic> newJson) {
    jsonBase = newJson;

    //merge to get all properties
    jsonMerge.addAll(newJson);

    id = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.id,
      defaultValue: defaultModel.id,
      currentValue: id,
    );
    name = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.name,
      defaultValue: defaultModel.name,
      currentValue: name,
    );
    // Styles have to be read as one of the first properties, as styles can influence how some properties are read/converted
    // E.g. Scaling can be disabled by a style, which influences how the size is read
    styles = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.style,
      defaultValue: defaultModel.styles,
      conversion: _parseStyle,
      currentValue: styles,
    );
    className = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.className,
      defaultValue: defaultModel.className,
      currentValue: className,
    );
    parent = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.parent,
      defaultValue: defaultModel.parent,
      currentValue: parent,
    );
    isRemoved = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.remove,
      defaultValue: defaultModel.isRemoved,
      currentValue: isRemoved,
      conversion: (e) => ParseUtil.parseBool(e)!,
    );
    isDestroyed = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.destroy,
      defaultValue: defaultModel.isDestroyed,
      currentValue: isDestroyed,
      conversion: (e) => ParseUtil.parseBool(e)!,
    );
    isVisible = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.visible,
      defaultValue: defaultModel.isVisible,
      currentValue: isVisible,
    );
    isEnabled = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.enabled,
      defaultValue: defaultModel.isEnabled,
      currentValue: isEnabled,
    );
    isFocusable = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.focusable,
      defaultValue: defaultModel.isFocusable,
      currentValue: isFocusable,
    );
    constraints = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.constraints,
      defaultValue: defaultModel.constraints,
      currentValue: constraints,
    );
    indexOf = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.indexOf,
      defaultValue: defaultModel.indexOf,
      currentValue: indexOf,
    );
    tabIndex = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.tabIndex,
      defaultValue: defaultModel.tabIndex,
      currentValue: tabIndex,
    );
    preferredSize = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.preferredSize,
      defaultValue: defaultModel._preferredSize,
      currentValue: _preferredSize,
      conversion: _parseSize,
    );
    minimumSize = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.minimumSize,
      defaultValue: defaultModel._minimumSize,
      currentValue: _minimumSize,
      conversion: _parseSize,
    );
    maximumSize = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.maximumSize,
      defaultValue: defaultModel.maximumSize,
      currentValue: maximumSize,
      conversion: _parseSize,
    );
    bounds = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.bounds,
      defaultValue: defaultModel.bounds,
      currentValue: bounds,
      conversion: ParseUtil.parseBounds,
    );
    background = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.background,
      defaultValue: defaultModel.background,
      currentValue: background,
      conversion: ParseUtil.parseBackgroundColor,
    );
    foreground = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.foreground,
      defaultValue: defaultModel.foreground,
      currentValue: foreground,
      conversion: ParseUtil.parseColor,
    );
    verticalAlignment = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.verticalAlignment,
      defaultValue: defaultModel.verticalAlignment,
      currentValue: verticalAlignment,
      condition: (value) => value < VerticalAlignment.values.length && value >= 0,
      conversion: VerticalAlignmentE.fromDynamic,
    );
    horizontalAlignment = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.horizontalAlignment,
      defaultValue: defaultModel.horizontalAlignment,
      currentValue: horizontalAlignment,
      condition: (value) => value < HorizontalAlignment.values.length && value >= 0,
      conversion: HorizontalAlignmentE.fromDynamic,
    );
    toolTipText = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.toolTipText,
      defaultValue: defaultModel.toolTipText,
      currentValue: toolTipText,
    );
    classNameEventSourceRef = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.classNameEventSourceRef,
      defaultValue: defaultModel.classNameEventSourceRef,
      currentValue: classNameEventSourceRef,
    );
    eventFocusGained = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.eventFocusGained,
      defaultValue: defaultModel.eventFocusGained,
      conversion: (e) => ParseUtil.parseBool(e)!,
      currentValue: eventFocusGained,
    );
    eventFocusLost = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.eventFocusLost,
      defaultValue: defaultModel.eventFocusLost,
      conversion: (e) => ParseUtil.parseBool(e)!,
      currentValue: eventFocusLost,
    );
    eventMousePressed = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.eventMousePressed,
      defaultValue: defaultModel.eventMousePressed,
      conversion: (e) => ParseUtil.parseBool(e)!,
      currentValue: eventMousePressed,
    );
    eventMouseReleased = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.eventMouseReleased,
      defaultValue: defaultModel.eventMouseReleased,
      conversion: (e) => ParseUtil.parseBool(e)!,
      currentValue: eventMouseReleased,
    );
    eventMouseClicked = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.eventMouseClicked,
      defaultValue: defaultModel.eventMouseClicked,
      conversion: (e) => ParseUtil.parseBool(e)!,
      currentValue: eventMouseClicked,
    );
    font = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.font,
      defaultValue: defaultModel.font,
      conversion: (value) => JVxFont.fromString(cast<String?>(value)),
      currentValue: font,
    );
    ariaLabel = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.ariaLabel,
      defaultValue: defaultModel.ariaLabel,
      currentValue: ariaLabel,
    );
  }

  /// If this component is used in a cell editor, some values are overriden.
  void applyCellEditorOverrides(Map<String, dynamic> json) {
    Map<String, dynamic> overrideJson = {};

    if (json.containsKey(ApiObjectProperty.cellEditorHorizontalAlignment)) {
      overrideJson[ApiObjectProperty.horizontalAlignment] = json[ApiObjectProperty.cellEditorHorizontalAlignment];
    }
    if (json.containsKey(ApiObjectProperty.cellEditorVerticalAlignment)) {
      overrideJson[ApiObjectProperty.verticalAlignment] = json[ApiObjectProperty.cellEditorVerticalAlignment];
    }
    if (json.containsKey(ApiObjectProperty.cellEditorBackground)) {
      overrideJson[ApiObjectProperty.background] = json[ApiObjectProperty.cellEditorBackground];
    }
    if (json.containsKey(ApiObjectProperty.cellEditorForeground)) {
      overrideJson[ApiObjectProperty.foreground] = json[ApiObjectProperty.cellEditorForeground];
    }
    if (json.containsKey(ApiObjectProperty.cellEditorFont)) {
      overrideJson[ApiObjectProperty.font] = json[ApiObjectProperty.cellEditorFont];
    }
    if (json.containsKey(ApiObjectProperty.cellEditorStyle)) {
      overrideJson[ApiObjectProperty.style] = json[ApiObjectProperty.cellEditorStyle];
    }
    if (json.containsKey(ApiObjectProperty.cellEditorEditable)) {
      overrideJson[ApiObjectProperty.editable] = json[ApiObjectProperty.cellEditorEditable];
    }

    if (overrideJson.isNotEmpty) {
      applyFromJson(overrideJson);
    }
  }

  /// Returns the [TextStyle] of the component.
  TextStyle createTextStyle({
    Color? foreground,
    double? fontSize,
    FontStyle? fontStyle,
    FontWeight? fontWeight,
    String? fontFamily
  }) {
    return TextStyle(
      color: foreground ?? (isEnabled ? foreground : JVxColors.toggleColor(JVxColors.COMPONENT_DISABLED)),
      fontSize: fontSize ?? font?.fontSize.toDouble(),
      fontStyle: fontStyle ?? (font?.isItalic == true ? FontStyle.italic : FontStyle.normal),
      fontWeight: fontWeight ?? (font?.isBold == true ? FontWeight.bold : FontWeight.normal),
      fontFamily: fontFamily ?? font?.fontName,
      overflow: TextOverflow.ellipsis,
    );
  }

  T getPropertyValue<T>({
    required Map<String, dynamic> json,
    required String key,
    required T defaultValue,
    required T currentValue,
    T Function(dynamic)? conversion,
    bool Function(dynamic)? condition,
  }) {
    return ParseUtil.getPropertyValue(
      json: json,
      key: key,
      defaultValue: defaultValue,
      currentValue: currentValue,
      valueConversion: conversion,
      condition: condition,
    );
  }

  Set<String> _parseStyle(dynamic style) {
    return (style as String).split(",").toSet();
  }

  /// Parses a [Size] object from a string, will only parse correctly if provided string was formatted :
  /// "x,y" - e.g. "200,400" -> Size(200,400), if provided String was null, returned size will also be null
  Size _parseSize(dynamic size) {
    List<String> split = size.split(",");

    double width = double.parse(split[0]);
    double height = double.parse(split[1]);

    return Size(width, height) * scaling;
  }

  void applyCellFormat(CellFormat cellFormat) {
    background = cellFormat.background ?? background;
    foreground = cellFormat.foreground ?? foreground;
    font = cellFormat.font ?? font;
  }

  bool get scalingEnabled => !styles.contains(STYLE_NO_SCALING);

  double get scaling => scalingEnabled ? IConfigService().getScaling() : 1.0;

  /// If the component exists in the storage service.
  bool get exists => IStorageService().getComponentModel(componentId: id) != null;
}
