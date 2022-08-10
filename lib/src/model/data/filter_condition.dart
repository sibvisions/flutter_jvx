import '../../../util/parse_util.dart';
import '../../service/api/shared/api_object_property.dart';

enum OperatorType { AND, OR }

enum CompareType {
  EQUALS,
  LIKE,
  LIKE_IGNORE_CASE,
  LIKE_REVERSE,
  LIKE_REVERSE_IGNORE_CASE,
  LESS,
  LESS_EQUALS,
  GREATER,
  GREATER_EQUALS,
  CONTAINS_IGNORE_CASE,
  STARTS_WITH_IGNORE_CASE,
  ENDS_WITH_IGNORE_CASE
}

class FilterCondition {
  String? columnName;
  dynamic value;
  OperatorType? operatorType = OperatorType.AND;
  CompareType? compareType = CompareType.EQUALS;
  bool? not;
  FilterCondition? condition;
  List<FilterCondition> conditions = [];

  FilterCondition({
    this.columnName,
    this.value,
    this.operatorType,
    this.compareType,
    this.not,
    this.condition,
    this.conditions = const [],
  });

  FilterCondition.fromJson(Map<String, dynamic> pJson) {
    columnName = pJson[ApiObjectProperty.columnName];
    value = pJson[ApiObjectProperty.value];
    not = pJson[ApiObjectProperty.not];

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ApiObjectProperty.columnName: columnName,
      ApiObjectProperty.value: value,
      ApiObjectProperty.operatorType: ParseUtil.propertyAsString(operatorType?.toString()),
      ApiObjectProperty.compareType: ParseUtil.propertyAsString(compareType?.toString()),
      ApiObjectProperty.not: value,
      ApiObjectProperty.condition: condition?.toJson(),
      ApiObjectProperty.conditions: conditions.map<Map<String, dynamic>>((c) => c.toJson()).toList()
    };
  }
}
