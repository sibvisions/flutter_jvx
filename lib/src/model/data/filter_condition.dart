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

import '../../service/api/shared/api_object_property.dart';
import '../../util/parse_util.dart';

enum OperatorType {
  And,
  Or,
}

enum CompareType {
  Equals,
  Like,
  LikeIgnoreCase,
  // LikeReverse,
  // LikeReverseIgnoreCase,
  Less,
  LessEquals,
  Greater,
  GreaterEquals,
  // ContainsIgnoreCase,
  // StartsWithIgnoreCase,
  // EndsWithIgnoreCase,
}

class FilterCondition {
  late final String? columnName;
  late final dynamic value;
  late final OperatorType operatorType;
  late final CompareType compareType;
  late final bool not;
  late final List<FilterCondition> conditions;

  FilterCondition({
    this.columnName,
    this.value,
    this.operatorType = OperatorType.And,
    this.compareType = CompareType.Equals,
    this.not = false,
    FilterCondition? condition,
    this.conditions = const [],
  }) {
    if (condition != null) {
      conditions.insert(0, condition);
    }
  }

  FilterCondition.fromJson(Map<String, dynamic> pJson) {
    columnName = pJson[ApiObjectProperty.columnName];
    value = pJson[ApiObjectProperty.value];
    not = pJson[ApiObjectProperty.not] ?? false;

    operatorType = ParseUtil.getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.operatorType,
      pDefault: OperatorType.And,
      pCurrent: operatorType,
      pConversion: (value) => OperatorType.values.firstWhere((e) => e.name == value),
    );
    compareType = ParseUtil.getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.compareType,
      pDefault: CompareType.Equals,
      pCurrent: compareType,
      pConversion: (value) => CompareType.values.firstWhere((e) => e.name == value),
    );

    if (pJson.containsKey(ApiObjectProperty.condition)) {
      conditions.add(FilterCondition.fromJson(pJson[ApiObjectProperty.condition]));
    }
    if (pJson.containsKey(ApiObjectProperty.conditions)) {
      pJson[ApiObjectProperty.conditions].forEach((c) => conditions.add(FilterCondition.fromJson(c)));
    }
  }

  Map<String, dynamic> toJson() => {
        ApiObjectProperty.columnName: columnName,
        ApiObjectProperty.value: value,
        ApiObjectProperty.operatorType: ParseUtil.propertyAsString(operatorType.name),
        ApiObjectProperty.compareType: ParseUtil.propertyAsString(compareType.name),
        ApiObjectProperty.not: not,
        ApiObjectProperty.conditions: conditions.map<Map<String, dynamic>>((c) => c.toJson()).toList()
      };

  /// Collects recursively all values
  List<dynamic> getValues() => _collectValues([this]);

  /// Recursively collects the values from the sub conditions.
  static List<dynamic> _collectValues(List<FilterCondition> subConditions) {
    var list = [];
    for (var subCondition in subConditions) {
      if (subCondition.columnName != null) {
        list.add(subCondition.value);
      }
      list.addAll(_collectValues(subCondition.conditions));
    }
    return list;
  }
}
