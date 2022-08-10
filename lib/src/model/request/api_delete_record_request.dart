import '../../service/api/shared/api_object_property.dart';
import '../data/filter_condition.dart';
import 'filter.dart';
import 'i_api_request.dart';

class ApiDeleteRecordRequest extends IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  /// Data provider to change selected row of
  final String dataProvider;

  /// Filter
  final Filter? filter;

  final FilterCondition? filterCondition;

  final int? selectedRow;

  final bool fetch;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDeleteRecordRequest({
    required this.clientId,
    required this.dataProvider,
    this.selectedRow,
    this.filter,
    this.filterCondition,
    this.fetch = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.filter: filter?.toJson(),
        ApiObjectProperty.filterCondition: filterCondition?.toJson(),
        ApiObjectProperty.selectedRow: selectedRow,
        ApiObjectProperty.fetch: fetch,
      };
}
