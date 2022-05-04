import 'package:flutter_client/src/model/api/api_object_property.dart';

class CompareType {
  static const String EQUALS = "equals";
  static const String LIKE = "like";
  static const String LIKE_IGNORE_CASE = "LikeIgnoreCase";
  static const String LIKE_REVERSE = "LikeReverse";
  static const String LIKE_REVERSE_IGNORE_CASE = "LikeReverseIgnoreCase";
  static const String LESS = "Less";
  static const String LESS_EQUALS = "LessEquals";
  static const String GREATER = "Greater";
  static const String GREATER_EQUALS = "GreaterEquals";
  static const String CONTAINS_IGNORE_CASE = "ContainsIgnoreCase";
  static const String STARTS_WITH_IGNORE_CASE = "StartsWithIgnoreCase";
  static const String ENDS_WITH_IGNORE_CASE = "EndsWithIgnoreCase";
}

class OperatorType {
  static const String OR = "Or";
  static const String AND = "And";
}

class ApiFilterModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the column from the value
  final String columnName;

  /// Value used for filtering
  final dynamic value;

  /// See [CompareType] class for all available
  final String? compareType;

  /// See [OperatorType] class for all available
  final String? operatorType;

  final bool not;

  ApiFilterModel? condition;

  List<ApiFilterModel>? conditions;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFilterModel({
    required this.columnName,
    required this.value,
    required this.compareType,
    required this.operatorType,
    this.not = false,
    this.condition,
    this.conditions,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Map<String, dynamic> toJson() => {
        ApiObjectProperty.columnName: columnName,
        ApiObjectProperty.value: value,
        ApiObjectProperty.compareType: compareType,
        ApiObjectProperty.operatorType: operatorType,
        ApiObjectProperty.not: not,
        ApiObjectProperty.condition: condition,
        ApiObjectProperty.conditions: conditions,
      };
}
