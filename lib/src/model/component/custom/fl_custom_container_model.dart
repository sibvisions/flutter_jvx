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

part of 'package:flutter_jvx/src/model/component/fl_component_model.dart';

class FlCustomContainerModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String? dataProvider;

  String? columnName;

  bool saveLock = false;

  bool editLock = true;

  Map<String, dynamic> properties = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCustomContainerModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlCustomContainerModel get defaultModel => FlCustomContainerModel();

  @override
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    properties = newJson;

    // Currently only used for signature pad
    dataProvider = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.dataRow,
      defaultValue: defaultModel.dataProvider,
      currentValue: dataProvider,
    );
    columnName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.columnName,
      defaultValue: defaultModel.columnName,
      currentValue: columnName,
    );
    saveLock = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.saveLock,
      defaultValue: defaultModel.saveLock,
      currentValue: saveLock,
    );
    editLock = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.editLock,
      defaultValue: defaultModel.editLock,
      currentValue: editLock,
    );
  }
}
