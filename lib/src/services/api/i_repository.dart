import 'package:http/http.dart';

abstract class IRepository {

  Future<Response> startUp();
  Future<Response> login(String username, String password);
}