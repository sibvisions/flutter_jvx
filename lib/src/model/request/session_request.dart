import '../../service/api/shared/api_object_property.dart';
import 'api_request.dart';

/// Base class for all outgoing api requests
abstract class SessionRequest extends ApiRequest {
  /// Session id
  late String clientId;

  @override
  Map<String, dynamic> toJson() => {ApiObjectProperty.clientId: clientId};
}
