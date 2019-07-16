import 'package:jvx_mobile_v3/services/restClient.dart';

abstract class NetworkService {
  RestClient rest;
  NetworkService(this.rest);
}