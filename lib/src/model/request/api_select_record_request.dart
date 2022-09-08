import '../../service/api/shared/api_object_property.dart';
import 'filter.dart';
import 'i_session_request.dart';

class ApiSelectRecordRequest extends ISessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
        ...super.toJson(),
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.rowNumber: selectedRow,
        ApiObjectProperty.fetch: fetch,
        ApiObjectProperty.reload: reload,
        ApiObjectProperty.filter: filter?.toJson(),
      };
}
