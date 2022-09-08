import '../../service/api/shared/api_object_property.dart';
import '../data/filter_condition.dart';
import 'filter.dart';
import 'i_session_request.dart';

class ApiDeleteRecordRequest extends ISessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
        ...super.toJson(),
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.filter: filter?.toJson(),
        ApiObjectProperty.filterCondition: filterCondition?.toJson(),
        ApiObjectProperty.selectedRow: selectedRow,
        ApiObjectProperty.fetch: fetch,
      };
}
