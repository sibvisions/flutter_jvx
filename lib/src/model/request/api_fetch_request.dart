import '../../service/api/shared/api_object_property.dart';
import 'i_session_request.dart';

class ApiFetchRequest extends ISessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<String>? columnNames;

  final bool? includeMetaData;

  final int fromRow;

  final int rowCount;

  final String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFetchRequest({
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
        ...super.toJson(),
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.includeMetaData: includeMetaData,
        ApiObjectProperty.fromRow: fromRow,
        ApiObjectProperty.rowCount: rowCount,
        ApiObjectProperty.dataProvider: dataProvider,
      };
}
