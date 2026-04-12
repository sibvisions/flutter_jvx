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

import '../../../../service/api/shared/api_object_property.dart';
import '../../../../service/api/shared/fl_component_classname.dart';
import '../../../../util/parse_util.dart';
import '../../../layout/alignments.dart';
import '../../fl_component_model.dart';
import 'date/fl_date_cell_editor_model.dart';
import 'fl_check_box_cell_editor_model.dart';
import 'fl_choice_cell_editor_model.dart';
import 'fl_number_cell_editor_model.dart';
import 'linked/fl_linked_cell_editor_model.dart';

class ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Open Editor on double click. This should be the default behaviour.
  static const int DOUBLE_CLICK = 0;

  /// Open Editor with single click.
  static const int SINGLE_CLICK = 1;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The class name of the editor.
  String className = "";

  /// Description of the content
  String? contentType;

  /// The horizontal alignment of the editor.
  HorizontalAlignment horizontalAlignment = HorizontalAlignment.LEFT;

  /// The vertical alignment of the editor.
  VerticalAlignment verticalAlignment = VerticalAlignment.TOP;

  /// If this editor should be shown inside a table.
  bool directCellEditor = false;

  /// The preferred editor mode.
  int preferredEditorMode = DOUBLE_CLICK;

  /// If this editor should open in a popup.
  bool autoOpenPopup = false;

  /// Styles.
  Set<String> styles = {};

  /// If this editor should have a clear icon.
  bool get hideClearIcon => styles.contains(FlComponentModel.STYLE_NO_CLEAR_ICON);

  /// If this editor should show copy icon.
  bool get showCopy => styles.contains(FlTextFieldModel.STYLE_COPY);

  /// If this editor should show plain text icon.
  bool get showPlainText => styles.contains(FlPasswordFieldModel.STYLE_PLAIN_TEXT);

  /// If this editor should show password strength.
  bool get showPasswordStrength => styles.contains(FlPasswordFieldModel.STYLE_PASSWORD_STRENGTH);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [ICellEditorModel] with default values
  ICellEditorModel();

  factory ICellEditorModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ICellEditorModel();

    ICellEditorModel? model;
    switch (json[ApiObjectProperty.className]) {
      case FlCellEditorClassname.CHECK_BOX_CELL_EDITOR:
        model = FlCheckBoxCellEditorModel();
        break;
      case FlCellEditorClassname.NUMBER_CELL_EDITOR:
        model = FlNumberCellEditorModel();
        break;
      case FlCellEditorClassname.IMAGE_VIEWER:
        model = FlImageCellEditorModel();
        break;
      case FlCellEditorClassname.CHOICE_CELL_EDITOR:
        model = FlChoiceCellEditorModel();
        break;
      case FlCellEditorClassname.DATE_CELL_EDITOR:
        model = FlDateCellEditorModel();
        break;
      case FlCellEditorClassname.LINKED_CELL_EDITOR:
        model = FlLinkedCellEditorModel();
        break;

      case FlCellEditorClassname.TEXT_CELL_EDITOR:
      default:
        model = ICellEditorModel();
    }

    model.applyFromJson(json);
    return model;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditorModel get defaultModel => ICellEditorModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void applyFromJson(Map<String, dynamic> newJson) {
    // ClassName
    className = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.className,
      defaultValue: defaultModel.className,
      currentValue: className,
    );

    // ContentType
    contentType = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.contentType,
      defaultValue: defaultModel.contentType,
      currentValue: contentType,
    );

    // HorizontalAlignment
    horizontalAlignment = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.horizontalAlignment,
      defaultValue: defaultModel.horizontalAlignment,
      currentValue: horizontalAlignment,
      condition: (value) => value < HorizontalAlignment.values.length && value >= 0,
      conversion: HorizontalAlignmentE.fromDynamic,
    );

    // VerticalAlignment
    verticalAlignment = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.verticalAlignment,
      defaultValue: defaultModel.verticalAlignment,
      currentValue: verticalAlignment,
      condition: (value) => value < VerticalAlignment.values.length && value >= 0,
      conversion: VerticalAlignmentE.fromDynamic,
    );

    // DirectCellEditor
    directCellEditor = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.directCellEditor,
      defaultValue: defaultModel.directCellEditor,
      currentValue: directCellEditor,
    );

    // PreferredEditorMode
    preferredEditorMode = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.preferredEditorMode,
      defaultValue: defaultModel.preferredEditorMode,
      currentValue: preferredEditorMode,
    );

    // AutoOpenPopup
    autoOpenPopup = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.autoOpenPopup,
      defaultValue: defaultModel.autoOpenPopup,
      currentValue: autoOpenPopup,
    );

    // Styles
    styles = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.style,
      defaultValue: defaultModel.styles,
      conversion: _parseStyle,
      currentValue: styles,
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
    if (style == null) {
      return {};
    }

    String sStyle = (style as String);

    if (sStyle.isEmpty) {
      return {};
    }

    return sStyle.split(",").toSet();
  }

}
