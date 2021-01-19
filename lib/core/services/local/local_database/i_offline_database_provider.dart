import '../../../models/api/request.dart';
import '../../../models/api/response.dart';
import 'i_database_provider.dart';

abstract class IOfflineDatabaseProvider extends IDatabaseProvider {
  Future<Response> request(Request request);
}
