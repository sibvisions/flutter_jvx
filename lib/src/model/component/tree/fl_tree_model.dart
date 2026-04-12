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

class FlTreeModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  List<String> dataProviders = [];

  bool detectEndNode = true;

  @override
  Size? get preferredSize {
    return _preferredSize ?? const Size(250, 300);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTreeModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTreeModel get defaultModel => FlTreeModel();

  @override
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    dataProviders = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.dataBooks,
      defaultValue: defaultModel.dataProviders,
      currentValue: dataProviders,
      conversion: (value) => List<String>.from(value),
    );

    detectEndNode = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.detectEndNode,
      defaultValue: defaultModel.detectEndNode,
      currentValue: detectEndNode,
    );
  }
}
