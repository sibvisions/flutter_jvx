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
import 'fl_image_cell_editor_model.dart';
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

  /// The preferred editor mode
  int preferredEditorMode = DOUBLE_CLICK;

  /// If this editor should open in a popup
  bool autoOpenPopup = false;

  /// Styles
  Set<String> styles = {};

  /// If this editor should have a clear icon.
  bool get hideClearIcon => styles.contains(FlComponentModel.STYLE_NO_CLEAR_ICON);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [ICellEditorModel] with default values
  ICellEditorModel();

  factory ICellEditorModel.fromJson(Map<String, dynamic>? pJson) {
    if (pJson == null) return ICellEditorModel();

    ICellEditorModel? model;
    switch (pJson[ApiObjectProperty.className]) {
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

    model.applyFromJson(pJson);
    return model;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditorModel get defaultModel => ICellEditorModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void applyFromJson(Map<String, dynamic> pJson) {
    // ClassName
    className = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.className,
      pDefault: defaultModel.className,
      pCurrent: className,
    );

    // ContentType
    contentType = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.contentType,
      pDefault: defaultModel.contentType,
      pCurrent: contentType,
    );

    // HorizontalAlignment
    horizontalAlignment = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.horizontalAlignment,
      pDefault: defaultModel.horizontalAlignment,
      pCurrent: horizontalAlignment,
      pCondition: (pValue) => pValue < HorizontalAlignment.values.length && pValue >= 0,
      pConversion: HorizontalAlignmentE.fromDynamic,
    );

    // VerticalAlignment
    verticalAlignment = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.verticalAlignment,
      pDefault: defaultModel.verticalAlignment,
      pCurrent: verticalAlignment,
      pCondition: (pValue) => pValue < VerticalAlignment.values.length && pValue >= 0,
      pConversion: VerticalAlignmentE.fromDynamic,
    );

    // DirectCellEditor
    directCellEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.directCellEditor,
      pDefault: defaultModel.directCellEditor,
      pCurrent: directCellEditor,
    );

    // PreferredEditorMode
    preferredEditorMode = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.preferredEditorMode,
      pDefault: defaultModel.preferredEditorMode,
      pCurrent: preferredEditorMode,
    );

    // AutoOpenPopup
    autoOpenPopup = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.autoOpenPopup,
      pDefault: defaultModel.autoOpenPopup,
      pCurrent: autoOpenPopup,
    );

    // Styles
    styles = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.style,
      pDefault: defaultModel.styles,
      pConversion: _parseStyle,
      pCurrent: styles,
    );
  }

  T getPropertyValue<T>({
    required Map<String, dynamic> pJson,
    required String pKey,
    required T pDefault,
    required T pCurrent,
    T Function(dynamic)? pConversion,
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

  Set<String> _parseStyle(dynamic pStyle) {
    String sStyle = (pStyle as String);

    return sStyle.split(",").toSet();
  }
}
