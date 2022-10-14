import '../../service/api/shared/api_object_property.dart';
import 'i_api_request.dart';

/// Base class for all outgoing api requests
abstract class ISessionRequest extends IApiRequest {
  /// Session id
  late String clientId;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.clientId: clientId,
      };
}
