import '../../component/properties.dart';

enum CompareType {
  EQUALS,
  LIKE,
  // LIKE_IGNORE_CASE,
  // LIKE_REVERSE,
  // LIKE_REVERSE_IGNORE_CASE,
  LESS,
  LESS_EQUALS,
  GREATER,
  GREATER_EQUALS,
  // CONTAINS_IGNORE_CASE,
  // START_WITH_IGNORE_CASE,
  // ENDS_WITH_IGNORE_CASE
}

enum OperatorType { AND, OR }

class FilterCondition {
  dynamic columnName;
  dynamic value;
  CompareType compareType;
  OperatorType operatorType;
  bool not;
  FilterCondition condition;
  List<FilterCondition> conditions;

  FilterCondition({this.columnName, this.value, this.compareType});

  FilterCondition.fromJson(Map<String, dynamic> json) {
    columnName = json['columnName'];
    value = json['value'];
    not = json['not'];
    if (json['condition'] != null)
      condition = FilterCondition.fromJson(json['condition']);
    if (json['conditions'] != null)
      json['conditions']
          .forEach((c) => conditions.add(FilterCondition.fromJson(c)));
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'columnName': columnName,
      'value': value,
      'compareType': compareType != null
          ? Properties.propertyAsString(compareType.toString())
          : null,
      'operatorType': operatorType != null
          ? Properties.propertyAsString(operatorType.toString())
          : null,
      'not': value,
      'condition': condition != null ? condition.toJson() : null,
      'conditions':
          conditions.map<Map<String, dynamic>>((c) => c.toJson()).toList()
    };
  }
}
