import 'package:flutter_client/src/service/api/i_api_service.dart';
import 'package:flutter_client/src/service/service.dart';

///
///  Provides an [IApiService] instance from get.it service
///
mixin ApiServiceMixin {
  final IApiService apiService = services<IApiService>();
}