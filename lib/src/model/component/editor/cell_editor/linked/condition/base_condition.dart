/*
 * Copyright 2023 SIB Visions GmbH
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

import '../../../../../../service/api/shared/api_object_property.dart';
import 'compare_condition.dart';
import 'operator_condition.dart';

abstract class BaseCondition {
  final String type;

  BaseCondition(this.type);

  BaseCondition.fromJson(Map<String, dynamic> json) : type = json[ApiObjectProperty.type];

  static BaseCondition? parseCondition(Map<String, dynamic>? json) {
    if (json == null) return null;

    var type = json[ApiObjectProperty.type];
    if (type is String) {
      switch (type.toLowerCase()) {
        case "and":
          return OperatorCondition.fromJson(json);
        case "equals":
          return CompareCondition.fromJson(json);
      }
    }
    return null;
  }
}
