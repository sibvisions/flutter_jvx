import '../../service/api/shared/api_object_property.dart';
import 'filter.dart';
import 'i_api_request.dart';

class ApiSelectRecordRequest implements IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  /// Data provider to change selected row of
  final String dataProvider;

  /// Filter
  final Filter? filter;

  final int selectedRow;

  final bool fetch;

  final bool reload;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiSelectRecordRequest({
    required this.clientId,
    required this.dataProvider,
    required this.selectedRow,
    this.fetch = false,
    this.reload = false,
    this.filter,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.rowNumber: selectedRow,
        ApiObjectProperty.fetch: fetch,
        ApiObjectProperty.reload: reload,
        ApiObjectProperty.filter: filter?.toJson(),
      };
}
