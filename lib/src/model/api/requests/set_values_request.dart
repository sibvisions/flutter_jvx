import '../api_object_property.dart';

class SetValuesRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the current session
  final String clientId;

  /// DataRow or DataProvider of the component
  final String dataProvider;

  /// Id of the component
  final String componentId;

  /// List of columns, order of which corresponds to order of values list
  final List<String> columnNames;

  /// List of values, order of which corresponds to order of columnsName list
  final List<dynamic> values;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SetValuesRequest(
      {required this.componentId,
      required this.clientId,
      required this.dataProvider,
      required this.columnNames,
      required this.values});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.componentId: componentId,
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.values: values
      };
}
