import '../../../../model/api/requests/i_api_request.dart';
import '../../../../model/api/response/api_response.dart';
import '../../../../model/config/api/api_config.dart';
import '../i_repository.dart';

class OfflineApiRepository implements IRepository {
  @override
  Future<List<ApiResponse>> sendRequest({required IApiRequest pRequest}) {
    // TODO: implement sendRequest
    throw UnimplementedError();
  }

  @override
  void setApiConfig({required ApiConfig config}) {
    // TODO: implement setApiConfig
  }
}
