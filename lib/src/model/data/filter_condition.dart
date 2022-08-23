import '../../../util/parse_util.dart';
import '../../service/api/shared/api_object_property.dart';

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ApiObjectProperty.columnName: columnName,
      ApiObjectProperty.value: value,
      ApiObjectProperty.operatorType: ParseUtil.propertyAsString(operatorType.name),
      ApiObjectProperty.compareType: ParseUtil.propertyAsString(compareType.name),
      ApiObjectProperty.not: value,
      ApiObjectProperty.condition: condition?.toJson(),
      ApiObjectProperty.conditions: conditions.map<Map<String, dynamic>>((c) => c.toJson()).toList()
    };
  }

  /// Collects recursively all values
  List<dynamic> getValues() {
    //condition.value is only 1 level deep supported
    return [
      value,
      if (condition?.value != null) condition?.value,
      ..._collectSubValues(conditions),
    ];
  }

  /// Collects the values from the sub conditions recursively
  static List<dynamic> _collectSubValues(List<FilterCondition> subConditions) {
    var list = [];
    for (var subCondition in subConditions) {
      list.add(subCondition.value);
      list.addAll(_collectSubValues(subCondition.conditions));
    }
    return list;
  }
}
