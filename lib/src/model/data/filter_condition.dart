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

enum OperatorType { AND, OR }

enum CompareType {
  EQUALS,
  LIKE,
  LIKE_IGNORE_CASE,
  // LIKE_REVERSE,
  // LIKE_REVERSE_IGNORE_CASE,
  LESS,
  LESS_EQUALS,
  GREATER,
  GREATER_EQUALS,
  // CONTAINS_IGNORE_CASE,
  // STARTS_WITH_IGNORE_CASE,
  // ENDS_WITH_IGNORE_CASE,
}

class FilterCondition {
  String? columnName;
  dynamic value;
  late OperatorType operatorType;
  late CompareType compareType;
  late bool not;
  FilterCondition? condition;
  List<FilterCondition> conditions = [];

  FilterCondition({
    this.columnName,
    this.value,
    this.operatorType = OperatorType.AND,
    this.compareType = CompareType.EQUALS,
    this.not = false,
    this.condition,
    this.conditions = const [],
  });

  FilterCondition.fromJson(Map<String, dynamic> pJson) {
    columnName = pJson[ApiObjectProperty.columnName];
    value = pJson[ApiObjectProperty.value];
    not = pJson[ApiObjectProperty.not] ?? false;

    operatorType = ParseUtil.getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.operatorType,
      pDefault: OperatorType.AND,
      pCurrent: operatorType,
      pConversion: (value) => OperatorType.values[value],
    );
    compareType = ParseUtil.getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.compareType,
      pDefault: CompareType.EQUALS,
      pCurrent: compareType,
      pConversion: (value) => CompareType.values[value],
    );

    if (pJson.containsKey(ApiObjectProperty.condition)) {
      condition = FilterCondition.fromJson(pJson[ApiObjectProperty.condition]);
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
        ApiObjectProperty.not: value,
        ApiObjectProperty.condition: condition?.toJson(),
        ApiObjectProperty.conditions: conditions.map<Map<String, dynamic>>((c) => c.toJson()).toList()
      };

  /// Collects recursively all values
  List<dynamic> getValues() {
    return _collectSubValues([this]);
  }

  /// Collects the values from the sub conditions recursively
  static List<dynamic> _collectSubValues(List<FilterCondition> subConditions) {
    var list = [];
    for (var subCondition in subConditions) {
      if (subCondition.columnName != null) {
        list.add(subCondition.value);
      }
      list.addAll(_collectSubValues([
        if (subCondition.condition != null) subCondition.condition!,
        ...subCondition.conditions,
      ]));
    }
    return list;
  }
}
