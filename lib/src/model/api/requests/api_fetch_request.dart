import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';

class ApiFetchRequest implements IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  final List<String>? columnNames;

  final bool? includeMetaData;

  final int fromRow;

  final int rowCount;

  final String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFetchRequest({
    required this.clientId,
    required this.fromRow,
    required this.rowCount,
    required this.dataProvider,
    this.includeMetaData,
    this.columnNames,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.includeMetaData: includeMetaData,
        ApiObjectProperty.fromRow: fromRow,
        ApiObjectProperty.rowCount: rowCount,
        ApiObjectProperty.dataProvider: dataProvider,
      };
}
