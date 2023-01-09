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

import 'package:flutter/animation.dart';

import '../../../../../service/api/shared/api_object_property.dart';
import '../../../../../service/config/config_controller.dart';
import '../cell_editor_model.dart';
import 'column_view.dart';
import 'link_reference.dart';

class FlLinkedCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LinkReference linkReference = LinkReference();

  ColumnView? columnView;

  dynamic additionalCondition;

  String? displayReferencedColumnName;

  String? displayConcatMask;

  String? searchColumnMapping;

  bool searchTextAnywhere = true;

  bool searchInAllTableColumns = false;

  bool sortByColumnName = false;

  bool tableHeaderVisible = true;

  bool validationEnabled = true;

  bool doNotClearColumnNames = true;

  bool tableReadonly = true;

  Size? popupSize;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlLinkedCellEditorModel get defaultModel => FlLinkedCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    linkReference = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.linkReference,
        pDefault: defaultModel.linkReference,
        pCurrent: linkReference,
        pConversion: (value) => LinkReference.fromJson(value));

    columnView = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.columnView,
        pDefault: defaultModel.columnView,
        pCurrent: columnView,
        pConversion: (value) => ColumnView.fromJson(value));

    displayReferencedColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.displayReferencedColumnName,
      pDefault: defaultModel.displayReferencedColumnName,
      pCurrent: displayReferencedColumnName,
    );

    additionalCondition = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.additionalCondition,
      pDefault: defaultModel.additionalCondition,
      pCurrent: additionalCondition,
    );

    displayConcatMask = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.displayConcatMask,
      pDefault: defaultModel.displayConcatMask,
      pCurrent: displayConcatMask,
    );

    searchColumnMapping = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.searchColumnMapping,
      pDefault: defaultModel.searchColumnMapping,
      pCurrent: searchColumnMapping,
    );

    searchTextAnywhere = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.searchTextAnywhere,
      pDefault: defaultModel.searchTextAnywhere,
      pCurrent: searchTextAnywhere,
    );

    searchInAllTableColumns = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.searchInAllTableColumns,
      pDefault: defaultModel.searchInAllTableColumns,
      pCurrent: searchInAllTableColumns,
    );

    sortByColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.sortByColumnName,
      pDefault: defaultModel.sortByColumnName,
      pCurrent: sortByColumnName,
    );

    tableHeaderVisible = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.tableHeaderVisible,
      pDefault: defaultModel.tableHeaderVisible,
      pCurrent: tableHeaderVisible,
    );

    validationEnabled = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.validationEnabled,
      pDefault: defaultModel.validationEnabled,
      pCurrent: validationEnabled,
    );

    tableReadonly = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.tableReadonly,
      pDefault: defaultModel.tableReadonly,
      pCurrent: tableReadonly,
    );

    popupSize = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.popupSize,
      pDefault: defaultModel.popupSize,
      pCurrent: popupSize,
      pConversion: (pJson) => _parsePopupSize(pJson),
    );
  }

  Size? _parsePopupSize(Map<String, dynamic> pJson) {
    if (!pJson.containsKey("width") || !pJson.containsKey("height")) {
      return null;
    }

    num width = pJson['width'];
    num height = pJson['height'];
    return Size(width.toDouble(), height.toDouble()) * ConfigController().getScaling();
  }
}
